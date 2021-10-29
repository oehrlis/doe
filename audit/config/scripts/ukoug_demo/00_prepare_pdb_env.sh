#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 00_prepare_pdb_env.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to add a tnsname entry for the PDB PDBSEC.
# Notes......: ...
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
# - just add/update any kind of customized environment variable here
PDB_NAME="pdbsec"
PATH_PREFIX="/u01/oradata/PDBSEC/directories"
EXT_TABLE_PATH="${PATH_PREFIX}/ext_table"
SCHEDULER_PATH="${PATH_PREFIX}/scheduler"
PDB_TNSNAME="${PDB_NAME}.$(hostname -d)"
ORACLE_BASE=${ORACLE_BASE:-"/u00/app/oracle"}
TNS_ADMIN=${TNS_ADMIN:-"${ORACLE_BASE}/network/admin"}
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
#. /vagrant_common/scripts/00_init_environment.sh
#export DEFAULT_PASSWORD=${default_password:-"LAB01schulung"}
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Prepare PDB Environment ============================================="

# add the tnsnames entry
if [ $( grep -ic $PDB_TNSNAME ${TNS_ADMIN}/tnsnames.ora) -eq 0 ]; then
    echo "Add $PDB_TNSNAME to ${TNS_ADMIN}/tnsnames.ora."
    echo "${PDB_TNSNAME}=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$(hostname))(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=${PDB_NAME})))">>${TNS_ADMIN}/tnsnames.ora
else
    echo "TNS name entry ${PDB_TNSNAME} does exists."
fi

echo "- create PATH_PREFIX folder ${PATH_PREFIX}"
mkdir -p ${PATH_PREFIX}
chmod 755 /u01/oradata
chmod -R 755 ${PATH_PREFIX}

echo "- create script for external table preprocessor"
mkdir -p "${EXT_TABLE_PATH}"
echo "/usr/bin/date | /usr/bin/tee -a ${EXT_TABLE_PATH}/run_id.log"  >${EXT_TABLE_PATH}/run_id.sh
echo "/usr/bin/id   | /usr/bin/tee -a ${EXT_TABLE_PATH}/run_id.log"  >>${EXT_TABLE_PATH}/run_id.sh
chmod 755 ${EXT_TABLE_PATH}/run_id.sh
rm -f ${EXT_TABLE_PATH}/*.log
touch ${EXT_TABLE_PATH}/run_id.log
chmod 666 ${EXT_TABLE_PATH}/run_id.log

echo "- create script for DBMS_SCHEDULER"
mkdir -p "${SCHEDULER_PATH}"
echo "#!/bin/bash"                                                      >${SCHEDULER_PATH}/run_id.sh
echo "/usr/bin/date | /usr/bin/tee -a >>${SCHEDULER_PATH}/run_id.log"   >>${SCHEDULER_PATH}/run_id.sh
echo "/usr/bin/id   | /usr/bin/tee -a >>${SCHEDULER_PATH}/run_id.log"   >>${SCHEDULER_PATH}/run_id.sh
echo "exit"                                                        >>${SCHEDULER_PATH}/run_id.sh
chmod 755 ${SCHEDULER_PATH}/run_id.sh
rm -f ${SCHEDULER_PATH}/*.log
touch ${SCHEDULER_PATH}/run_id.log
chmod 666 ${SCHEDULER_PATH}/run_id.log
echo "= Finish PDB Environment =============================================="
# --- EOF --------------------------------------------------------------------