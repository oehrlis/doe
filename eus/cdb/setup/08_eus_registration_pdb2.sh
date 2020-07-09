#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 08_eus_registration_pdb2.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.06.01
# Revision...: --
# Purpose....: Script to configure the EUS for Database.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at https://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------
export BASEDN=${BASEDN:-"dc=trivadislabs,dc=com"}
export DOMAIN=${DOMAIN:-"trivadislabs.com"} 
export OUD_HOST=${OUD_HOST:-"eusoud.${DOMAIN}"}
export OUD_PORT=${OUD_PORT:-1389}
export OUD_PORT_SSL=${OUD_PORT_SSL:-1636}
export ORACLE_SID=${ORACLE_SID:-"TEUS01"}
export ORACLE_PDB="pdb2"
export TNS_ADMIN=${TNS_ADMIN:-"${ORACLE_BASE}/network/admin"}
export EUS_ADMIN=${EUS_ADMIN:-"$(cat /u01/common/etc/eusadmin_dn.txt)"}
export EUS_PWD_FILE=${EUS_PWD_FILE:-"/u01/common/etc/eusadmin_pwd.txt"}
export SYS_PWD_FILE=${SYS_PWD_FILE:-"${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt"}
export WALLET_PWD_FILE=${WALLET_PWD_FILE:-"${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_wallet_pwd.txt"}
# - configure SQLNet ----------------------------------------------------
echo "Configure SQLNet ldap.ora:"
echo "  BASEDN              :   ${BASEDN}"
echo "  OUD_HOST            :   ${OUD_HOST}"

if [ -f "$TNS_ADMIN/ldap.ora" ]; then
    cp -v $TNS_ADMIN/ldap.ora $TNS_ADMIN/ldap.ora.orig
fi

cat << EOF >$TNS_ADMIN/ldap.ora
DIRECTORY_SERVERS=(${OUD_HOST}:${OUD_PORT}:${OUD_PORT_SSL})
DEFAULT_ADMIN_CONTEXT = "${BASEDN}"
DIRECTORY_SERVER_TYPE = OID
EOF

# reuse existing password file
if [ -f "$WALLET_PWD_FILE" ]; then
    echo "- found wallet password file ${WALLET_PWD_FILE}"
    export ADMIN_PASSWORD=$(cat ${WALLET_PWD_FILE})
# use default password from variable
elif [ -n "${DEFAULT_WALLET_PASSWORD}" ]; then
    echo "- use default wallet password from \${DEFAULT_WALLET_PASSWORD}"
    echo ${DEFAULT_WALLET_PASSWORD}> ${WALLET_PWD_FILE}
    export ADMIN_PASSWORD=$(cat $WALLET_PWD_FILE)
    # still here, then lets create a password
else 
    # Auto generate a password
    echo "- auto generate new wallet password..."
    while true; do
        s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w 10 | head -n 1)
        if [[ ${#s} -ge 8 && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
            echo "- passwort does Match the criteria"
            break
        else
            echo "- password does not Match the criteria, re-generating..."
        fi
    done
    echo "- use auto generated wallet password"
    ADMIN_PASSWORD=$s
    echo "- save wallet password in ${WALLET_PWD_FILE}"
    echo ${ADMIN_PASSWORD}>$WALLET_PWD_FILE
fi

if [ -z "${ORACLE_PDB}" ]; then
    EUS_DBNAME=${ORACLE_SID}
    SERVICE_NAME=${ORACLE_SID}
else
    EUS_DBNAME=${ORACLE_PDB}_${ORACLE_SID}
    SERVICE_NAME=${ORACLE_PDB}
fi

echo "Configure PDB:"
echo "  BASEDN              :   ${BASEDN}"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_PDB          :   ${ORACLE_PDB}"
echo "  EUS_DBNAME          :   ${EUS_DBNAME}"

# check if database is registered
echo "- check if ${ORACLE_SID} does exist in OracleContext ${BASEDN}"
DATABASE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b ${BASEDN} -s sub "(cn=${EUS_DBNAME})" dn 2>/dev/null)
if [ -n "${DATABASE_DN}" ]; then
# wenn vorhanden check dn in wallet
    echo "- reset password for database ${ORACLE_SID} in OracleContext ${BASEDN}"
    $ORACLE_HOME/bin/dbca -silent -configurePluggableDatabase \
        -pdbName ${ORACLE_PDB} -sourceDB ${ORACLE_SID} -sysDBAUserName sys -sysDBAPassword $(cat ${SYS_PWD_FILE}) \
        -regenerateDBPassword true -dirServiceUserName "${EUS_ADMIN}" \
        -dirServicePassword $(cat ${EUS_PWD_FILE}) -walletPassword $(cat ${WALLET_PWD_FILE}) 
else
    echo "- register database ${ORACLE_SID} in OracleContext ${BASEDN}"
    $ORACLE_HOME/bin/dbca -silent -configurePluggableDatabase \
        -pdbName ${ORACLE_PDB} -sourceDB ${ORACLE_SID} -sysDBAUserName sys -sysDBAPassword $(cat ${SYS_PWD_FILE}) \
        -registerWithDirService true -dirServiceUserName "${EUS_ADMIN}" \
        -dirServicePassword $(cat ${EUS_PWD_FILE}) -walletPassword $(cat ${WALLET_PWD_FILE}) 
fi

# - unlock system -------------------------------------------------------
$ORACLE_HOME/bin/sqlplus -S -L /NOLOG <<EOFSQL
CONNECT / AS SYSDBA
ALTER USER system IDENTIFIED BY "$(cat ${SYS_PWD_FILE})" ACCOUNT UNLOCK;
EOFSQL
# - EOF -----------------------------------------------------------------
