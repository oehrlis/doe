----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 50_create_lockdown_profiles.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @50_create_lockdown_profiles
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
-- 50_create_lockdown_profiles.sql : prepare the PDB pdbsec
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
-- remove existing lockdown profiles
DECLARE
    vcount        INTEGER := 0;
    TYPE table_varchar IS
        TABLE OF VARCHAR2(128);
    profiles   table_varchar := table_varchar('TVD_BASE','TVD_TABLE','TVD_DEFAULT','TVD_JVM','TVD_JVM_OS','TVD_RESTRICTED','TVD_SPARE','TVD_APP','TVD_OLTP','TVD_DWH','TVD_TRACE');

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

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- Create lockdown profile tvd_base 
CREATE LOCKDOWN PROFILE tvd_base;
-- Enable all option except DATABASE QUEUING
ALTER LOCKDOWN PROFILE tvd_base ENABLE OPTION ALL EXCEPT = ('DATABASE QUEUING');
PAUSE
---------------------------------------------------------------------------
-- Create lockdown profile tvd_default based on tvd_base
CREATE LOCKDOWN PROFILE tvd_default FROM tvd_base;
PAUSE
---------------------------------------------------------------------------
-- Disable a couple of feature bundles and features
ALTER LOCKDOWN PROFILE tvd_default DISABLE FEATURE = ('CONNECTIONS');
ALTER LOCKDOWN PROFILE tvd_default DISABLE FEATURE = ('CTX_LOGGING');
ALTER LOCKDOWN PROFILE tvd_default DISABLE FEATURE = ('NETWORK_ACCESS');
ALTER LOCKDOWN PROFILE tvd_default DISABLE FEATURE = ('OS_ACCESS');
ALTER LOCKDOWN PROFILE tvd_default DISABLE FEATURE = ('JAVA_RUNTIME');
ALTER LOCKDOWN PROFILE tvd_default DISABLE FEATURE = ('JAVA');
ALTER LOCKDOWN PROFILE tvd_default DISABLE FEATURE = ('JAVA_OS_ACCESS');
PAUSE
---------------------------------------------------------------------------
-- Enable simple OS access
ALTER LOCKDOWN PROFILE tvd_default ENABLE FEATURE = ('COMMON_SCHEMA_ACCESS');
ALTER LOCKDOWN PROFILE tvd_default ENABLE FEATURE = ('AWR_ACCESS');
PAUSE
---------------------------------------------------------------------------
-- Restrict ALTER DATABASE statement
ALTER LOCKDOWN PROFILE tvd_default DISABLE STATEMENT = ('ALTER DATABASE') USERS=LOCAL;
ALTER LOCKDOWN PROFILE tvd_default DISABLE STATEMENT = ('ALTER DATABASE')
  CLAUSE = ('CLOSE') USERS=LOCAL;
ALTER LOCKDOWN PROFILE tvd_default ENABLE STATEMENT = ('ALTER DATABASE')
  CLAUSE = ('OPEN') USERS=LOCAL;
PAUSE
---------------------------------------------------------------------------
-- disable ALTER SYSTEM in general
ALTER LOCKDOWN PROFILE tvd_default DISABLE STATEMENT = ('ALTER SYSTEM') USERS=LOCAL;
ALTER LOCKDOWN PROFILE tvd_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('OPEN_CURSORS') ;
PAUSE
---------------------------------------------------------------------------
-- enable the tvd_default lockdown profile
ALTER SYSTEM SET pdb_lockdown=tvd_default SCOPE=BOTH;
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- current user, container and lockdown profile
SHOW USER
SHOW CON_NAME
SHOW PARAMETER PDB_LOCKDOWN
PAUSE
---------------------------------------------------------------------------
-- show lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.clause,
        lr.clause_option,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
ORDER BY 1,2,3,4,6;
PAUSE

---------------------------------------------------------------------------
-- 50_create_lockdown_profiles.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------
