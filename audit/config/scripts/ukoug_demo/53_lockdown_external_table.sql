----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 51_lockdown_trace_view.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.12.02
--  Usage.....: @51_lockdown_trace_view
--  Purpose...: Script to create lockdown profiles
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- default values
DEFINE def_pdb_admin_user = "pdbadmin"
DEFINE def_pdb_admin_pwd  = "LAB01schulung"
DEFINE def_pdb_db_name    = "pdbsec"

-- define a default value for parameter if argument 1,2 or 3 is empty
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
COLUMN 2 NEW_VALUE 2 NOPRINT
COLUMN 3 NEW_VALUE 3 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
SELECT '' "2" FROM dual WHERE ROWNUM = 0;
SELECT '' "3" FROM dual WHERE ROWNUM = 0;
DEFINE pdb_db_name    = &1 &def_pdb_db_name
DEFINE pdb_admin_user = &2 &def_pdb_admin_user
DEFINE pdb_admin_pwd  = &3 &def_pdb_admin_pwd
COLUMN pdb_db_name NEW_VALUE pdb_db_name NOPRINT
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;
-- define environment stuff
COLUMN tablespace_name FORMAT a25
COLUMN file_name FORMAT a100
-- define environment stuff
COLUMN rule_type FORMAT A10
COLUMN rule FORMAT A25
COLUMN clause FORMAT A10
COLUMN clause_option FORMAT A20
COLUMN pdb_name FORMAT A10
SET PAGESIZE 200 LINESIZE 160

---------------------------------------------------------------------------
-- 51_lockdown_trace_view.sql : prepare the PDB pdbsec
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
-- remove existing lockdown profiles
DECLARE
    vcount        INTEGER := 0;
    TYPE table_varchar IS
        TABLE OF VARCHAR2(128);
    profiles   table_varchar := table_varchar('TVD_TABLE');

BEGIN  
    FOR i IN 1..profiles.count LOOP
        SELECT
            COUNT(1)
        INTO vcount
        FROM
            dba_lockdown_profiles
        WHERE
            profile_name = profiles(i);
        IF vcount != 0 THEN
            EXECUTE IMMEDIATE ('DROP LOCKDOWN PROFILE '||profiles(i));
        END IF; 
    END LOOP;
END;
/

-- Cleanup and remove old credentials if they do exists
ALTER SESSION SET CONTAINER=&pdb_db_name;
ALTER SESSION SET CURRENT_SCHEMA=&pdb_admin_user;
DECLARE
  vcount INTEGER :=0;
BEGIN
  SELECT count(1) INTO vcount FROM dba_tables WHERE table_name = 'ID';
  IF vcount != 0 THEN
    EXECUTE IMMEDIATE ('DROP TABLE id');
  END IF;
END;
/
SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- check the lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
--WHERE lr.rule IN ('OS_ACCESS','TRACE_VIEW_ACCESS')
ORDER BY 1,2,3,4,6;
-- check the current pdb_lockdown
SHOW PARAMETER pdb_lockdown
PAUSE

---------------------------------------------------------------------------
-- create a directory for the external table pre-processor
CREATE OR REPLACE DIRECTORY ext_table AS 'ext_table';
-- create an external table
CREATE TABLE id (id VARCHAR2(2000)) 
  ORGANIZATION EXTERNAL( 
    TYPE ORACLE_LOADER 
    DEFAULT DIRECTORY ext_table 
    ACCESS PARAMETERS( 
      RECORDS DELIMITED BY NEWLINE 
      PREPROCESSOR ext_table:'run_id.sh') 
    LOCATION(ext_table:'run_id.sh') 
  ); 
-- query the external table
SELECT * FROM id;
PAUSE
---------------------------------------------------------------------------
-- Clean up
SET ECHO OFF
CONNECT / as SYSDBA
ALTER SYSTEM SET pdb_lockdown=tvd_default SCOPE=BOTH;
--DROP LOCKDOWN PROFILE tvd_table;
---------------------------------------------------------------------------
-- 51_lockdown_trace_view.sql : finished
---------------------------------------------------------------------------
-- EOF ---------------------------------------------------------------------
