#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 00_prepare_env.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.07.07
# Revision...: 
# Purpose....: Script to prepare environment e.g. domain name etc
# Notes......: ...
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at https://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
export DOMAIN=${DOMAIN:-"trivadislabs.com"} 
export BASEDN=${BASEDN:-"dc=$(echo $DOMAIN|cut -d. -f1),dc=$(echo $DOMAIN|cut -d. -f2)"} 
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
ORACLE_BASE=${ORACLE_BASE:-"/u00/app/oracle"}
TNS_ADMIN=${TNS_ADMIN:-"${ORACLE_BASE}/network/admin"}
DEFAULT_HOST=$(hostname 2>/dev/null ||cat /etc/hostname ||echo $HOSTNAME)

# get the fqdn hostname if necessary
if [[ ${DEFAULT_HOST//[^.]} != "" ]]; then 
    HOST=$DEFAULT_HOST
else 
    HOST=$DEFAULT_HOST.$DOMAIN
fi

# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Prepare SQLNet Environment =========================================="

if [ -f "$TNS_ADMIN/sqlnet.ora" ]; then
    echo "- update sqlnet.ora ---------------------------------------------------"
    sed -i "/^NAMES.DEFAULT_DOMAIN=/{h;s/=.*/=$DOMAIN/};\${x;/^$/{s//NAMES.DEFAULT_DOMAIN=$DOMAIN/;H};x}" $TNS_ADMIN/sqlnet.ora
fi

echo "- update listener.ora -----------------------------------------------"
if [ -f "$TNS_ADMIN/listener.ora" ]; then
    cp -v $TNS_ADMIN/listener.ora $TNS_ADMIN/listener.ora.orig
    sed -i "s/(HOST =.*)/(HOST = $HOST )/" $TNS_ADMIN/listener.ora
    $ORACLE_HOME/bin/lsnrctl reload
fi

echo "- update ldap.ora ---------------------------------------------------"
if [ -f "$TNS_ADMIN/ldap.ora" ]; then
    cp -v $TNS_ADMIN/ldap.ora $TNS_ADMIN/ldap.ora.orig
fi

cat << EOF >$TNS_ADMIN/ldap.ora
DIRECTORY_SERVERS=(eusoud.${DOMAIN}:1389:1636)
DEFAULT_ADMIN_CONTEXT = "${BASEDN}"
DIRECTORY_SERVER_TYPE = OID
EOF

echo "= Finish update SQLNet Environment ===================================="
# --- EOF --------------------------------------------------------------------