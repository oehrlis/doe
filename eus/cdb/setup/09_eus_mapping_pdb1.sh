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
export ORACLE_PDB="pdb1"
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
MAPPING_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(orclDBDistinguishedName=${MAP_DN})(objectClass=orclDBSubtreeLevelMapping))" dn )
if [ -z "${MAPPING_DN}" ]; then
    echo " Create subtree mapping for ${EUS_DBNAME} on ${MAP_DN} to EUS_USERS"
    eusm createMapping domain_name="OracleDefaultDomain" \
    map_type=SUBTREE map_dn="${MAP_DN}" schema=EUS_USERS \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE})  
else
    echo " skip subtree mapping for ${EUS_DBNAME} on ${MAP_DN} to EUS_USERS"
fi

eusm listMappings domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE})  

MAP_DN="cn=Ben King,ou=Senior Management,ou=People,${BASEDN}"
MAPPING_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "cn=$EUS_DBNAME,cn=OracleContext,${BASEDN}" -s sub "(&(orclDBDistinguishedName=${MAP_DN})(objectClass=orclDBEntryLevelMapping))" dn )
if [ -z "${MAPPING_DN}" ]; then
    echo " Create entry mapping for ${EUS_DBNAME} on ${MAP_DN} to KING"
    eusm createMapping database_name="$EUS_DBNAME" \
        map_type=ENTRY schema=KING \
        map_dn="${MAP_DN}" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE})  
else
    echo " skip entry mapping for ${EUS_DBNAME} on ${MAP_DN} to KING"
fi

eusm listMappings database_name=${EUS_DBNAME} \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE})  

# - create enterprise roles --------------------------------------------
ROLES=("HR Clerk" "HR Management" "Common Clerk" "Common Management")
for role in "${ROLES[@]}"; do
    ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${role})(objectClass=orclDBEnterpriseRole))" dn)
    if [ -z "${ENT_ROLE_DN}" ]; then
        echo "- create enterprise role ${role}"
        eusm createRole enterprise_role="${role}" \
            domain_name="OracleDefaultDomain" \
            realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
            ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
    else
        echo "- skip creating enterprise role mapping ${role}"
    fi
done

eusm listEnterpriseRoles domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

# - add global roles -------------------------------------------------

ROLES=("HR Clerk" "HR Management" "Common Clerk" "Common Management")
for role in "${ROLES[@]}"; do
    ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=HR Clerk)(objectClass=orclDBEnterpriseRole))" orcldbserverrole|grep -i ${EUS_DBNAME})
    if [ -z "${ENT_ROLE_DN}" ]; then
        echo "- add global enterprise role ${role}"
        eusm addGlobalRole enterprise_role="${role}" \
            domain_name="OracleDefaultDomain" database_name="$EUS_DBNAME" \
            global_role="hr_clerk" dbuser="system" dbuser_password=$(cat ${SYSTEM_PWD_FILE}) \
            dbconnect_string="${HOSTNAME}:1521/$SERVICE_NAME" \
            realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
            ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
    else
        echo "- skip global enterprise role ${role}"
    fi
done
echo " Add global roles HR Clerk and Management"

ENT_ROLE="HR Clerk"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" orcldbserverrole|grep -i ${EUS_DBNAME})
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- add global role to enterprise role ${role}"
    eusm addGlobalRole enterprise_role="${ENT_ROLE}" \
        domain_name="OracleDefaultDomain" database_name="$EUS_DBNAME" \
        global_role="hr_clerk" dbuser="system" dbuser_password=$(cat ${SYSTEM_PWD_FILE}) \
        dbconnect_string="${HOSTNAME}:1521/$SERVICE_NAME" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip assign global to enterprise role ${ENT_ROLE}"
fi

ENT_ROLE="HR Management"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" orcldbserverrole|grep -i ${EUS_DBNAME})
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- add global role hr_clerk to enterprise role ${ENT_ROLE}"
    eusm addGlobalRole enterprise_role="${ENT_ROLE}" \
        domain_name="OracleDefaultDomain" database_name="$EUS_DBNAME" \
        global_role="hr_clerk" dbuser="system" dbuser_password=$(cat ${SYSTEM_PWD_FILE}) \
        dbconnect_string="${HOSTNAME}:1521/$SERVICE_NAME" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
    echo "- add global role hr_mgr to enterprise role ${ENT_ROLE}"
    eusm addGlobalRole enterprise_role="${ENT_ROLE}" \
        domain_name="OracleDefaultDomain" database_name="$EUS_DBNAME" \
        global_role="hr_mgr" dbuser="system" dbuser_password=$(cat ${SYSTEM_PWD_FILE}) \
        dbconnect_string="${HOSTNAME}:1521/$SERVICE_NAME" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip assign global to enterprise role ${ENT_ROLE}"
fi

ENT_ROLE="Common Clerk"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" orcldbserverrole|grep -i ${EUS_DBNAME})
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- add global role common_clerk to enterprise role ${role}"
    eusm addGlobalRole enterprise_role="${ENT_ROLE}" \
        domain_name="OracleDefaultDomain" database_name="$EUS_DBNAME" \
        global_role="common_clerk" dbuser="system" dbuser_password=$(cat ${SYSTEM_PWD_FILE}) \
        dbconnect_string="${HOSTNAME}:1521/$SERVICE_NAME" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip assign global to enterprise role ${ENT_ROLE}"
fi

ENT_ROLE="Common Management"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" orcldbserverrole|grep -i ${EUS_DBNAME})
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- add global role common_clerk to enterprise role ${ENT_ROLE}"
    eusm addGlobalRole enterprise_role="${ENT_ROLE}" \
        domain_name="OracleDefaultDomain" database_name="$EUS_DBNAME" \
        global_role="common_clerk" dbuser="system" dbuser_password=$(cat ${SYSTEM_PWD_FILE}) \
        dbconnect_string="${HOSTNAME}:1521/$SERVICE_NAME" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
    echo "- add global role common_mgr to enterprise role ${ENT_ROLE}"
    eusm addGlobalRole enterprise_role="${ENT_ROLE}" \
        domain_name="OracleDefaultDomain" database_name="$EUS_DBNAME" \
        global_role="common_mgr" dbuser="system" dbuser_password=$(cat ${SYSTEM_PWD_FILE}) \
        dbconnect_string="${HOSTNAME}:1521/$SERVICE_NAME" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip assign global to enterprise role ${ENT_ROLE}"
fi

# - grant enterprise roles -------------------------------------------------
ENT_ROLE="HR Clerk"
UNIQUEMEMBER="CN=Trivadis LAB HR,OU=Groups,${BASEDN}"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" uniqueMember|grep -i "${UNIQUEMEMBER}")
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- grant enterprise role ${ENT_ROLE} to ${UNIQUEMEMBER}"
    eusm grantRole enterprise_role="${ENT_ROLE}" \
    domain_name="OracleDefaultDomain" \
    group_dn="${UNIQUEMEMBER}" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip grant enterprise role ${ENT_ROLE} toto ${UNIQUEMEMBER}"
fi

ENT_ROLE="HR Management"
UNIQUEMEMBER="CN=Honey Rider,OU=Human Resources,OU=People,${BASEDN}"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" uniqueMember|grep -i "${UNIQUEMEMBER}")
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- grant enterprise role ${ENT_ROLE} to ${UNIQUEMEMBER}"
    eusm grantRole enterprise_role="HR Management" \
        domain_name="OracleDefaultDomain" \
        user_dn="${UNIQUEMEMBER}" \
        realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
        ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip grant enterprise role ${ENT_ROLE} to ${UNIQUEMEMBER}"
fi

eusm listEnterpriseRoleInfo enterprise_role="HR Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

eusm listEnterpriseRoleInfo enterprise_role="HR Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

ENT_ROLE="Common Clerk"
UNIQUEMEMBER="CN=Trivadis LAB Users,OU=Groups,${BASEDN}"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" uniqueMember|grep -i "${UNIQUEMEMBER}")
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- grant enterprise role ${ENT_ROLE} to ${UNIQUEMEMBER}"
    eusm grantRole enterprise_role="${ENT_ROLE}" \
    domain_name="OracleDefaultDomain" \
    group_dn="${UNIQUEMEMBER}" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip grant enterprise role ${ENT_ROLE} toto ${UNIQUEMEMBER}"
fi

ENT_ROLE="Common Management"
UNIQUEMEMBER="CN=Trivadis LAB Management,OU=Groups,${BASEDN}"
ENT_ROLE_DN=$(ldapsearch -h ${OUD_HOST} -p ${OUD_PORT} -D ${EUS_ADMIN} -w $(cat ${EUS_PWD_FILE}) -b "${BASEDN}" -s sub "(&(cn=${ENT_ROLE})(objectClass=orclDBEnterpriseRole))" uniqueMember|grep -i "${UNIQUEMEMBER}")
if [ -z "${ENT_ROLE_DN}" ]; then
    echo "- grant enterprise role ${ENT_ROLE} to ${UNIQUEMEMBER}"
    eusm grantRole enterprise_role="${ENT_ROLE}" \
    domain_name="OracleDefaultDomain" \
    group_dn="${UNIQUEMEMBER}" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
else
    echo "- skip grant enterprise role ${ENT_ROLE} toto ${UNIQUEMEMBER}"
fi

eusm listEnterpriseRoleInfo enterprise_role="Common Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 

eusm listEnterpriseRoleInfo enterprise_role="Common Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="${BASEDN}" ldap_host=${OUD_HOST} ldap_port=${OUD_PORT} \
    ldap_user_dn="${EUS_ADMIN}" ldap_user_password=$(cat ${EUS_PWD_FILE}) 
# - EOF -----------------------------------------------------------------
