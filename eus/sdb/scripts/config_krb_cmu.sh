#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: config_krb_cmu.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2021.09.28
# Revision...: 
# Purpose....: Script to configure Kerberos and Centrally Managed Users
# Notes......: --
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------------
# - Customization -------------------------------------------------------------
ORA_WALLET_PASSWORD=${ORA_WALLET_PASSWORD:-""}
ORA_KRB5_KEYTAB_FILE=${ORA_KRB5_KEYTAB_FILE:-"$(hostname).standard.six-group.net.keytab"}
ORA_CMU_USER=${ORA_CMU_USER:-"A"}
ORA_CMU_USER_DN=${ORA_CMU_USER_DN:-"b"}
ORA_CMU_PASSWORD=${ORA_CMU_PASSWORD:-"c"}
ORA_CMU_ROOT_CERT=${ORA_CMU_ROOT_CERT:-"$TNS_ADMIN/CARootCert.pam"}
# - End of Customization ------------------------------------------------------

# - Default Values ------------------------------------------------------------
# source genric environment variables and functions
SCRIPT_NAME=$(basename ${BASH_SOURCE[0]})
SCRIPT_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_BASE=$(dirname ${SCRIPT_BIN_DIR})
DATE_STAMP=$(date '+%Y%m%d')
# define logfile and logging
export LOG_BASE=${LOG_BASE:-"${SCRIPT_BIN_DIR}"} # Use script directory as default logbase
TIMESTAMP=$(date "+%Y.%m.%d_%H%M%S")
readonly LOGFILE="$LOG_BASE/$(basename $SCRIPT_NAME .sh)_$TIMESTAMP.log"
# - EOF Default Values --------------------------------------------------------


# - Functions ---------------------------------------------------------------
function command_exists () {
# Purpose....: check if a command exists. 
# ---------------------------------------------------------------------------
    command -v $1 >/dev/null 2>&1;
}

function gen_password {
# Purpose....: generate a password string
# -----------------------------------------------------------------------
    Length=${1:-16}

    # make sure, that the password length is not shorter than 4 characters
    if [ ${Length} -lt 4 ]; then
        Length=4
    fi

    # generate password
    if [ $(command -v pwgen) ]; then 
        pwgen -s -1 ${Length}
    else 
        while true; do
            # use urandom to generate a random string
            s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w ${Length} | head -n 1)
            # check if the password meet the requirements
            if [[ ${#s} -ge ${Length} && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
                echo "$s"
                break
            fi
        done
    fi
}
# - EOF Functions -----------------------------------------------------------

# - Initialization ------------------------------------------------------------
# Define a bunch of bash option see 
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
set -o nounset                              # stop script after 1st cmd failed
set -o errexit                              # exit when 1st unset variable found
set -o pipefail                             # pipefail exit after 1st piped commands failed

# initialize logfile
touch $LOGFILE 2>/dev/null
exec &> >(tee -a "$LOGFILE")                # Open standard out at `$LOG_FILE` for write.  
exec 2>&1  
echo "INFO: Start ${SCRIPT_NAME} on host $(hostname) at $(date)"

# load config
if [ -f "$SCRIPT_BIN_DIR/$SCRIPT_NAME.conf" ]; then
    echo "INFO: source config file"
    . $SCRIPT_BIN_DIR/$SCRIPT_NAME.conf
fi

echo "INFO: Current settings ---------------------------------------------------"
echo "SCRIPT_NAME                       : $SCRIPT_NAME"
echo "SCRIPT_BIN_DIR                    : $SCRIPT_BIN_DIR"
echo "SCRIPT_BASE                       : $SCRIPT_BASE"
echo "ORA_WALLET_PASSWORD               : $ORA_WALLET_PASSWORD"
echo "ORA_KRB5_KEYTAB_FILE              : $ORA_KRB5_KEYTAB_FILE"
echo "ORA_CMU_USER                      : $ORA_CMU_USER"
echo "ORA_CMU_USER_DN                   : $ORA_CMU_USER_DN"
echo "ORA_CMU_PASSWORD                  : <ORA_CMU_PASSWORD>"
echo "ORA_CMU_ROOT_CERT                 : $ORA_CMU_ROOT_CERT"

# if exist make a copy of the existing krb5.conf file
if [ -f "$TNS_ADMIN/krb5.keytab" ]; then
    echo "INFO: save existing krb5.keytab file as krb5.keytab.${DATE_STAMP}"
    cp $TNS_ADMIN/krb5.keytab $TNS_ADMIN/krb5.keytab.${DATE_STAMP}
    ln -fs $TNS_ADMIN/$(hostname).standard.six-group.net.keytab $TNS_ADMIN/krb5.keytab
fi

# if exist make a copy of the existing krb5.conf file
if [ -f "$TNS_ADMIN/krb5.conf" ]; then
    echo "INFO: save existing krb5.conf file as krb5.conf.${DATE_STAMP}"
    cp $TNS_ADMIN/krb5.conf $TNS_ADMIN/krb5.conf.${DATE_STAMP}
fi

# create a new krb5.conf
echo "INFO: create new krb5.conf file"
cat << EOF >$TNS_ADMIN/krb5.conf
# ---------------------------------------------------------------------
# Trivadis AG, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------
# Name.......: krb5.conf
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2021.09.28
# Revision...: --
# Purpose....: Oracle Kerberos Configuration File
# Notes......: --
# Reference..: Oracle Database Security 19c
# ---------------------------------------------------------------------
# Modified...:
# YYYY.MM.DD  Visa  Change
# ----------- ----- ---------------------------------------------------
# 2021.09.28  soe   Initial version
# ---------------------------------------------------------------------
[libdefaults]
forwardable = true
default_realm = BASE.DOM
 
[realms]
  BASE.DOM = {
    kdc = base.dom
  }
 
[domain_realm]
.standard.six-group.net = BASE.DOM
standard.six-group.net = BASE.DOM
.BASE.DOM = BASE.DOM
BASE.DOM = BASE.DOM
.base.dom = BASE.DOM
base.dom = BASE.DOM
.six-group.com = BASE.DOM
six-group.com = BASE.DOM
# ---------------------------------------------------------------------
EOF

# Update sqlnet.ora
if [ -f "$TNS_ADMIN/sqlnet.ora" ]; then
    echo "INFO: save existing sqlnet.ora file as sqlnet.ora.${DATE_STAMP}"
    cp $TNS_ADMIN/sqlnet.ora $TNS_ADMIN/sqlnet.ora.${DATE_STAMP}
    echo "INFO: remove KRB5 config in sqlnet.ora file"
    sed -i '/AUTHENTICATION/d' $TNS_ADMIN/sqlnet.ora
    sed -i '/KERBEROS5/d' $TNS_ADMIN/sqlnet.ora

    echo "INFO: update sqlnet.ora file"
    cat << EOF >>$TNS_ADMIN/sqlnet.ora

# ---------------------------------------------------------------------
# Kerberos settings
# ---------------------------------------------------------------------
SQLNET.AUTHENTICATION_SERVICES=(BEQ,KERBEROS5PRE,KERBEROS5)
SQLNET.AUTHENTICATION_KERBEROS5_SERVICE = oracle
SQLNET.FALLBACK_AUTHENTICATION = TRUE
SQLNET.KERBEROS5_KEYTAB = $TNS_ADMIN/krb5.keytab
SQLNET.KERBEROS5_CONF = $TNS_ADMIN/krb5.conf
SQLNET.KERBEROS5_CONF_MIT=TRUE
# - EOF ---------------------------------------------------------------
EOF

else
    echo "ERR : Could not find an sqlnet.ora ($TNS_ADMIN/sqlnet.ora)"
    echo "ERR : Please create manually an sqlnet.ora"
    exit 1
fi
# create CMU config folder
echo "INFO: create CMU configuration folder $TNS_ADMIN/cmu"
mkdir -p $TNS_ADMIN/cmu

# if exist make a copy of the existing dsi.ora file
if [ -f "$TNS_ADMIN/cmu/dsi.ora" ]; then
    echo "INFO: save existing dsi.ora file as dsi.ora.${DATE_STAMP}"
    cp $TNS_ADMIN/cmu/dsi.ora $TNS_ADMIN/cmu/dsi.ora.${DATE_STAMP}
fi
# create a new dsi.ora file
echo "INFO: create new dsi.ora file"
cat << EOF >$TNS_ADMIN/cmu/dsi.ora
# ---------------------------------------------------------------------
# Trivadis AG, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------
# Name.......: dsi.ora
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2021.09.28
# Revision...: --
# Purpose....: Oracle Centrally Managed Users Configuration File
# Notes......: --
# Reference..: Oracle Database Security 19c
# ---------------------------------------------------------------------
# Modified...:
# YYYY.MM.DD  Visa  Change
# ----------- ----- ---------------------------------------------------
# 2021.09.28  soe   Initial version
# ---------------------------------------------------------------------
DSI_DIRECTORY_SERVERS = (base.dom::636)
DSI_DEFAULT_ADMIN_CONTEXT = "DC=base,DC=dom"
DSI_DIRECTORY_SERVER_TYPE = AD
# ---------------------------------------------------------------------
EOF

# create Oracle CMU Wallet password
if [ -z ${ORA_WALLET_PASSWORD} ]; then
    # Auto generate a wallet password
    echo "INFO: auto generate new Oracle CMU Wallet password..."
    ORA_WALLET_PASSWORD=$(gen_password 16)
    echo $ORA_WALLET_PASSWORD>$TNS_ADMIN/cmu/wallet_pwd_${DATE_STAMP}.txt
fi

# create Oracle Wallet
orapki wallet create -wallet $TNS_ADMIN/cmu -pwd $ORA_WALLET_PASSWORD -auto_login

if [ -n "$ORA_CMU_USER" ]; then
    echo "INFO: add username $ORA_CMU_USER to the Oracle CMU Wallet"
    echo $ORA_WALLET_PASSWORD|mkstore -wrl $TNS_ADMIN/cmu -createEntry ORACLE.SECURITY.USERNAME $ORA_CMU_USER
else
    echo "WARN: can not add username to the Oracle CMU Wallet"
fi

if [ -n "$ORA_CMU_USER_DN" ]; then
    echo "INFO: add username DN $ORA_CMU_USER_DN to the Oracle CMU Wallet"
    echo $ORA_WALLET_PASSWORD|mkstore -wrl $TNS_ADMIN/cmu -createEntry ORACLE.SECURITY.DN $ORA_CMU_USER_DN
else
    echo "WARN: can not add username DN to the Oracle CMU Wallet"
fi

if [ -n "$ORA_CMU_PASSWORD" ]; then
    echo "INFO: add password to the Oracle CMU Wallet"
    echo $ORA_WALLET_PASSWORD|mkstore -wrl $TNS_ADMIN/cmu -createEntry ORACLE.SECURITY.PASSWORD $ORA_CMU_PASSWORD
else
    echo "WARN: can not add password to the Oracle CMU Wallet"
fi

if [ -f "$ORA_CMU_ROOT_CERT" ]; then
    echo "INFO: add root certificate $TNS_ADMIN/CARootCert.pam to the Oracle CMU Wallet"
    orapki wallet add -wallet $TNS_ADMIN/cmu -pwd $ORA_WALLET_PASSWORD -trusted_cert -cert $TNS_ADMIN/CARootCert.pam
else
    echo "WARN: can not root certificate to the Oracle CMU Wallet"
fi

echo "INFO: Wallet Information"
echo $ORA_WALLET_PASSWORD|mkstore -wrl $TNS_ADMIN/cmu
orapki wallet display -wallet  $TNS_ADMIN/cmu -pwd $ORA_WALLET_PASSWORD
 
# print information
echo "INFO: CMU and Kerberos OS configuration finished."
echo "      it is recommended to restart the listener and databases"
echo "      to make sure new SQLNet configuration is used."
echo ""
echo "INFO: Finish ${SCRIPT_NAME} on host $(hostname) at $(date)"
# --- EOF ---------------------------------------------------------------------
