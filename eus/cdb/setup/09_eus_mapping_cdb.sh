#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 09_eus_mapping.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.07.01
# Revision...: --
# Purpose....: Script to create EUS for Database.
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
export TNS_ADMIN=${TNS_ADMIN:-"${ORACLE_BASE}/network/admin"}
export OUD_PORT=${OUD_PORT:-"1389"}
export ORACLE_SID=${ORACLE_SID:-"TEUS01"}
export ORACLE_PDB=""
export EUS_ADMIN=${EUS_ADMIN:-"$(cat /u01/common/etc/eusadmin_dn.txt)"}
export EUS_PWD_FILE=${EUS_PWD_FILE:-"/u01/common/etc/eusadmin_pwd.txt"}
export SYSTEM_PWD_FILE=${SYSTEM_PWD_FILE:-"${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt"}

if [ -z "${ORACLE_PDB}" ]; then
    EUS_DBNAME=${ORACLE_SID}
    SERVICE_NAME=${ORACLE_SID}
else
    EUS_DBNAME=${ORACLE_PDB}_${ORACLE_SID}
    SERVICE_NAME=${ORACLE_PDB}
fi
# - configure EUS mappings ---------------------------------------------
echo "Create Mappings for Database ${ORACLE_SID} in OUD using:"
echo "  OUD_HOST            :   ${OUD_HOST}"
echo "  OUD_PORT            :   ${OUD_PORT}"
echo "  HOSTNAME            :   ${HOSTNAME}"
echo "  BASEDN              :   ${BASEDN}"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  SERVICE_NAME        :   ${SERVICE_NAME}"
echo "  ORACLE_PDB          :   ${ORACLE_PDB}"
echo "  EUS_DBNAME          :   ${EUS_DBNAME}"
echo "  EUS_ADMIN           :   ${EUS_ADMIN}"
echo "  EUS_PWD_FILE        :   ${EUS_PWD_FILE}"
echo "  SYSTEM_PWD_FILE     :   ${SYSTEM_PWD_FILE}"

# - create mappings ----------------------------------------------------

# check mapping
MAP_DN="ou=People,${BASEDN}"
MAPPING_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(orclDBDistinguishedName=${MAP_DN})(objectClass=orclDBSubtreeLevelMapping))" dn |grep -i $ORACLE_SID)
if [ -z "${MAPPING_DN}" ]; then
    echo " Create subtree mapping for ${EUS_DBNAME} on ${MAP_DN} to EUS_USERS"
    eusm createMapping database_name="${EUS_DBNAME}" \
    map_type=SUBTREE map_dn="${MAP_DN}" schema="C##EUS_USERS" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE})  
else
    echo " skip subtree mapping for ${EUS_DBNAME} on ${MAP_DN} to EUS_USERS"
fi

eusm listMappings database_name="${EUS_DBNAME}" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE})  

eusm listEnterpriseRoles domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

eusm listEnterpriseRoleInfo enterprise_role="HR Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

eusm listEnterpriseRoleInfo enterprise_role="HR Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

eusm listEnterpriseRoleInfo enterprise_role="Common Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

eusm listEnterpriseRoleInfo enterprise_role="Common Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
# - EOF -----------------------------------------------------------------
