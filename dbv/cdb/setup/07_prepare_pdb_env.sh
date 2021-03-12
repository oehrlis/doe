#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 07_prepare_pdb_env.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.06.01
# Revision...: 
# Purpose....: Script to add a tnsname entry and other stuff for the PDB pdbsec 
#              pdbaud pdb1 pdb2 pdb3.
# Notes......: ...
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at https://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
# - just add/update any kind of customized environment variable here
PDBS="pdb1 pdb2 pdb3"
PDB_DOMAIN=$(grep -i NAMES.DEFAULT_DOMAIN $TNS_ADMIN/sqlnet.ora|cut -d= -f2)
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
ORACLE_BASE=${ORACLE_BASE:-"/u00/app/oracle"}
TNS_ADMIN=${TNS_ADMIN:-"${ORACLE_BASE}/network/admin"}
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Prepare PDB Environment ============================================="

# add the tnsnames entries for a couple of PDBs
for i in ${PDBS}; do
    PDB_NAME=${i^^}
    PDB_TNSNAME="${PDB_NAME}.${PDB_DOMAIN}"
    PATH_PREFIX="/u01/oradata/${PDB_NAME}/directories"
    echo "- Configure ${PDB_NAME} -----------------------------------------------"
    if [ $( grep -ic $PDB_TNSNAME ${TNS_ADMIN}/tnsnames.ora) -eq 0 ]; then
        echo "- Add $PDB_TNSNAME to ${TNS_ADMIN}/tnsnames.ora."
        echo "${PDB_TNSNAME}=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$(hostname))(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=${PDB_NAME})))">>${TNS_ADMIN}/tnsnames.ora
        mkdir -vp ${PATH_PREFIX}
    else
        echo "- TNS name entry ${PDB_TNSNAME} does exists."
    fi
done

echo "= Finish PDB Environment =============================================="
# --- EOF --------------------------------------------------------------------