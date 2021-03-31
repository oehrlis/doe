----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 15_set_init_parameter.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.08.19
--  Usage.....: @15_set_init_parameter
--  Purpose...: Set some init.ora parameter
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
---------------------------------------------------------------------------

-- Define the default values 
DEFINE def_pdb_db_name    = "pdbaud"

---------------------------------------------------------------------------
-- define default values for parameter if argument 1,2 or 3 is empty
-- Parameter 1 : pdb_db_name
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE pdb_db_name    = &1 &def_pdb_db_name

-- change pdb_db_name to upper case
COLUMN pdb_db_name NEW_VALUE pdb_db_name NOPRINT
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;

-- get a PDB path based on CDB datafile 1
COLUMN cdb_path NEW_VALUE cdb_path NOPRINT
SELECT substr(file_name, 1, instr(file_name, '/', -1, 1)) cdb_path FROM dba_data_files WHERE file_id=1;

-- alter the SQL*Plus environment
SET PAGESIZE 200 LINESIZE 160
COL PROPERTY_NAME FOR A30
COL PROPERTY_VALUE FOR A30
SET FEEDBACK ON
SET ECHO ON
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
ALTER SYSTEM SET pdb_lockdown=sc_default SCOPE=BOTH;
ALTER SYSTEM SET db_create_file_dest="&cdb_path" SCOPE=BOTH;

SET ECHO OFF
-- EOF ---------------------------------------------------------------------
