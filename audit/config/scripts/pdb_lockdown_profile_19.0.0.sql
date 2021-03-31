----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: create_lockdown_profiles_19c.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.09.18
--  Usage.....: @create_lockdown_profiles_19c
--  Purpose...: Script to configure PDB_LOCKDOWN
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- default value
SET SERVEROUTPUT ON

-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

-- check oracle version
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT 0
BEGIN
  IF dbms_db_version.version>=18 THEN
    dbms_output.put_line('Version is for version ' ||dbms_db_version.version ||', keep going...'); 
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'Script is not intent for version '||dbms_db_version.version||' skip...');
  END IF;
END;
/

-- reset SQLERROR
WHENEVER SQLERROR CONTINUE

-- remove existing lockdown profiles
DECLARE
    vcount        INTEGER := 0;
    TYPE table_varchar IS
        TABLE OF VARCHAR2(128);
    profiles   table_varchar := table_varchar('SC_BASE','SC_DEFAULT','SC_JVM','SC_JVM_OS','SC_RESTRICTED','SC_SPARE','SC_APP','SC_OLTP','SC_DWH');

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

-- Create lockdown profile sc_base 
PROMPT CREATE LOCKDOWN PROFILE sc_base
CREATE LOCKDOWN PROFILE sc_base;
-- End locdown profile sc_base --------------------------------------------

-- Create lockdown profile sc_default 
PROMPT CREATE LOCKDOWN PROFILE sc_default
CREATE LOCKDOWN PROFILE sc_default;
-- Enable all option except DATABASE QUEUING
ALTER LOCKDOWN PROFILE sc_default ENABLE OPTION ALL;
-- Disable a couple of feature bundles and features
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('CONNECTIONS');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('CTX_LOGGING');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('NETWORK_ACCESS');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('OS_ACCESS');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('JAVA_RUNTIME');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('JAVA');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('JAVA_OS_ACCESS');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('EXTERNAL_PROCEDURES');

-- Enable common user access
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('COMMON_USER_CONNECT');
-- Enable simple OS access
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('AWR_ACCESS');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('LOB_FILE_ACCESS');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('TRACE_VIEW_ACCESS');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('UTL_FILE');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('EXTERNAL_FILE_ACCESS');
-- Restrict ALTER DATABASE statement 

ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT=('ALTER DATABASE');
-- Relaxe certain ALTER DATABASE clauses 
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('OPEN','CLOSE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('ENABLE RECOVERY');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('SET TIME_ZONE','DEFAULT EDITION');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('DEFAULT TEMPORARY TABLESPACE','DEFAULT TABLESPACE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('TEMPFILE RESIZE','DATAFILE RESIZE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('DATAFILE AUTOEXTEND OFF','DATAFILE AUTOEXTEND ON');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('ENABLE RECOVERY');
-- Restrict ALTER PLUGGABLE DATABASE statement 
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT=('ALTER PLUGGABLE DATABASE');
-- Relaxe certain ALTER PLUGGABLE DATABASE clauses 
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER PLUGGABLE DATABASE') CLAUSE=('OPEN','CLOSE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER PLUGGABLE DATABASE') CLAUSE=('ENABLE RECOVERY');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER PLUGGABLE DATABASE') CLAUSE=('SET TIME_ZONE','DEFAULT EDITION');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER PLUGGABLE DATABASE') CLAUSE=('DEFAULT TEMPORARY TABLESPACE','DEFAULT TABLESPACE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER PLUGGABLE DATABASE') CLAUSE=('TEMPFILE RESIZE','DATAFILE RESIZE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER PLUGGABLE DATABASE') CLAUSE=('DATAFILE AUTOEXTEND OFF','DATAFILE AUTOEXTEND ON');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT=('ALTER PLUGGABLE DATABASE') CLAUSE=('ENABLE RECOVERY');
-- Disable local KEY management
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ADMINISTER KEY MANAGEMENT') USERS=LOCAL;
-- Disable ALTER SESSION in general
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SESSION');
-- allow ALTER SESSION SET clause for common user
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') USERS=COMMON;
-- allow ALTER SESSION SET clause OPTION for all user
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('APPROX_FOR_AGGREGATION') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('APPROX_FOR_COUNT_DISTINCT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('APPROX_FOR_PERCENTILE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('CONTAINER') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('CURRENT_SCHEMA') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('CURSOR_SHARING') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('DDL_LOCK_TIMEOUT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('DEFAULT_COLLATION') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('EDITION') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('ISOLATION_LEVEL = READ COMMITTED') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('ISOLATION_LEVEL = SERIALIZABLE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_CALENDAR') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_COMP') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_CURRENCY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_DATE_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_DATE_LANGUAGE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_DUAL_CURRENCY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_ISO_CURRENCY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_LANGUAGE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_LENGTH_SEMANTICS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_NCHAR_CONV_EXCP') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_NUMERIC_CHARACTERS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_SORT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_TERRITORY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_TIME_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_TIME_TZ_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_TIMESTAMP_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('NLS_TIMESTAMP_TZ_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('OPTIMIZER_IGNORE_HINTS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('OPTIMIZER_IGNORE_PARALLEL_HINTS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('PLSCOPE_SETTINGS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('PLSQL_CCFLAGS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('PLSQL_DEBUG') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('PLSQL_OPTIMIZE_LEVEL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('PLSQL_WARNINGS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('ROW ARCHIVAL VISIBILITY = ACTIVE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('ROW ARCHIVAL VISIBILITY = ALL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('STATISTICS_LEVEL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('SET') OPTION = ('TIME_ZONE') ;
-- allow different ALTER SESSION clause
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('DISABLE PARALLEL QUERY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('ADVISE COMMIT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('DISABLE COMMIT IN PROCEDURE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('FORCE PARALLEL DDL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('DISABLE PARALLEL DML') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('FORCE PARALLEL QUERY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('ENABLE COMMIT IN PROCEDURE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('DISABLE PARALLEL DDL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('ENABLE RESUMABLE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('FORCE PARALLEL DML') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('CLOSE DATABASE LINK') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('ENABLE PARALLEL DML') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('DISABLE RESUMABLE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('ENABLE PARALLEL DDL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SESSION') CLAUSE = ('ENABLE PARALLEL QUERY') ;

-- Disable ALTER SYSTEM in general
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM');
-- Allow ALTER SYSTEM SET clause
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') USERS=COMMON;
-- Allow ALTER SYSTEM KILL SESSION clause
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('KILL SESSION');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('CANCEL SQL');
-- Allow ALTER SYSTEM flush pools
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT  =  ('ALTER SYSTEM') CLAUSE  =  ('FLUSH SHARED_POOL');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT  =  ('ALTER SYSTEM') CLAUSE  =  ('FLUSH BUFFER_CACHE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT  =  ('ALTER SYSTEM') CLAUSE  =  ('FLUSH GLOBAL CONTEXT');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT  =  ('ALTER SYSTEM') CLAUSE  =  ('FLUSH FLASH_CACHE');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT  =  ('ALTER SYSTEM') CLAUSE  =  ('FLUSH REDO');
-- Allow ALTER SESSION SET clause OPTION for all user
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('APPROX_FOR_AGGREGATION') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('APPROX_FOR_COUNT_DISTINCT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('APPROX_FOR_PERCENTILE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('AWR_PDB_AUTOFLUSH_ENABLED') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('CURSOR_SHARING') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('DDL_LOCK_TIMEOUT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('FIXED_DATE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('MAX_IDLE_TIME') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_CALENDAR') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_COMP') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_CURRENCY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_DATE_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_DATE_LANGUAGE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_DUAL_CURRENCY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_ISO_CURRENCY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_LANGUAGE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_LENGTH_SEMANTICS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_NCHAR_CONV_EXCP') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_NUMERIC_CHARACTERS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_SORT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_TERRITORY') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_TIME_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_TIME_TZ_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_TIMESTAMP_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('NLS_TIMESTAMP_TZ_FORMAT') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('OPTIMIZER_IGNORE_HINTS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('OPTIMIZER_IGNORE_PARALLEL_HINTS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('OPTIMIZER_ADAPTIVE_PLANS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('OPTIMIZER_FEATURES_ENABLE') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_FIX_CONTROL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('SESSION_CACHED_CURSORS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PLSCOPE_SETTINGS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PLSQL_CCFLAGS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PLSQL_DEBUG') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PLSQL_OPTIMIZE_LEVEL') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PLSQL_WARNINGS') ;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('RESOURCE_LIMIT');
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('RESOURCE_MANAGER_PLAN');
-- Disable ALTER SESSION SET clause OPTION for all user
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_CELL_OFFLOAD_VECTOR_GROUPBY');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_CLOUD_SERVICE_TYPE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_DATAPUMP_GATHER_STATS_ON_LOAD');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_DATAPUMP_INHERIT_SVCNAME');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_DEFAULT_PCT_FREE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_ENABLE_PARALLEL_DML');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_LDR_IO_SIZE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_MAX_IO_SIZE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_OPTIMIZER_ANSWERING_QUERY_USING_STATS');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_OPTIMIZER_GATHER_STATS_ON_LOAD_ALL');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_OPTIMIZER_GATHER_STATS_ON_LOAD_HIST');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_PARALLEL_CLUSTER_CACHE_POLICY');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_PDB_LOCKDOWN_DDL_CLAUSES');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('_PX_XTGRANULE_SIZE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('"_PDB_INHERIT_CFD"');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('"_PDB_MAX_AUDIT_SIZE"');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('"_PDB_MAX_DIAG_SIZE"');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('DB_FILES');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('MAX_IDLE_BLOCKER_TIME');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PARALLEL_DEGREE_POLICY');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PARALLEL_MIN_DEGREE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('RESULT_CACHE_MAX_RESULT');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('RESULT_CACHE_MODE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('COMMON_USER_PREFIX');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('FORWARD_LISTENER');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('LISTENER_NETWORKS');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('LOCAL_LISTENER');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PDB_FILE_NAME_CONVERT');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PDB_LOCKDOWN') USERS=LOCAL;
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PDB_OS_CREDENTIAL') USERS=LOCAL;
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('PDB_TEMPLATE');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('DB_CREATE_FILE_DEST');
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('UNIFIED_AUDIT_SYSTEMLOG');
-- End locdown profile sc_default -----------------------------------------

-- Create lockdown profile sc_jvm 
PROMPT CREATE LOCKDOWN PROFILE sc_jvm
CREATE LOCKDOWN PROFILE sc_jvm FROM sc_default;
ALTER LOCKDOWN PROFILE sc_jvm ENABLE FEATURE = ('JAVA_RUNTIME');
ALTER LOCKDOWN PROFILE sc_jvm ENABLE FEATURE = ('JAVA');
-- End locdown profile sc_jvm ---------------------------------------------

-- Create lockdown profile sc_jvm_os 
PROMPT CREATE LOCKDOWN PROFILE sc_jvm_os
CREATE LOCKDOWN PROFILE sc_jvm_os FROM sc_default;
ALTER LOCKDOWN PROFILE sc_jvm_os ENABLE FEATURE = ('JAVA_RUNTIME');
ALTER LOCKDOWN PROFILE sc_jvm_os ENABLE FEATURE = ('JAVA');
ALTER LOCKDOWN PROFILE sc_jvm_os ENABLE FEATURE = ('JAVA_OS_ACCESS');
-- End locdown profile sc_jvm_os ------------------------------------------

-- Create lockdown profile sc_restricted 
PROMPT CREATE LOCKDOWN PROFILE sc_restricted
CREATE LOCKDOWN PROFILE sc_restricted FROM sc_default;
ALTER LOCKDOWN PROFILE sc_restricted DISABLE OPTION ALL;
ALTER LOCKDOWN PROFILE sc_restricted DISABLE FEATURE ALL;
ALTER LOCKDOWN PROFILE sc_restricted ENABLE STATEMENT=('ALTER DATABASE') CLAUSE=('OPEN','CLOSE');
-- End locdown profile sc_restricted ---------------------------------------

-- Create lockdown profile SC_SPARE 
PROMPT CREATE LOCKDOWN PROFILE sc_spare
CREATE LOCKDOWN PROFILE sc_spare FROM sc_default;
-- End locdown profile sc_spare --------------------------------------------

-- Create lockdown profile SC_APP 
PROMPT CREATE LOCKDOWN PROFILE sc_app
CREATE LOCKDOWN PROFILE sc_app FROM sc_default;
-- End locdown profile sc_app ----------------------------------------------

-- Create lockdown profile SC_OLTP 
PROMPT CREATE LOCKDOWN PROFILE sc_oltp
CREATE LOCKDOWN PROFILE sc_oltp FROM sc_default;
-- End locdown profile sc_oltp ---------------------------------------------

-- Create lockdown profile SC_DWH 
PROMPT CREATE LOCKDOWN PROFILE sc_dwh
CREATE LOCKDOWN PROFILE sc_dwh FROM sc_default;
-- End locdown profile sc_dwh ----------------------------------------------
-- EOF ---------------------------------------------------------------------