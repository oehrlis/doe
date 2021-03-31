----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 42_create_scheduler_job.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @42_create_scheduler_job.sql
--  Purpose...: Script to configure external OS jobs
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
COLUMN dir_path NEW_VALUE dir_path FORMAT a80
COLUMN directory_name FORMAT a25
COLUMN directory_path FORMAT a80
COLUMN log_id FORMAT 999999
COLUMN log_date FORMAT a19
COLUMN owner FORMAT a8
COLUMN job_name FORMAT a14
COLUMN status FORMAT a9
COLUMN user_name FORMAT a10
COLUMN credential_owner FORMAT a16
COLUMN credential_name FORMAT a20
COLUMN additional_info FORMAT a30
COLUMN output FORMAT a20
COLUMN id FORMAT a80
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;
SET PAGESIZE 200 LINESIZE 160

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- 42_create_scheduler_job.sql : create DBMS_SCHEDULER external OS jobs 
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- purge the job log
exec DBMS_SCHEDULER.PURGE_LOG();
-- create a directory for the scheduler job
CREATE OR REPLACE DIRECTORY scheduler AS 'scheduler';
-- get the absolute directory path
SELECT directory_name,directory_path dir_path FROM dba_directories
WHERE origin_con_id=(SELECT con_id FROM v$pdbs where name=upper('&pdb_db_name')) AND directory_name='SCHEDULER';
PAUSE

---------------------------------------------------------------------------
-- check OS script
HOST rm &dir_path/run_id.log; touch &dir_path/run_id.log
HOST ls -al &dir_path/run_id.sh
HOST cat &dir_path/run_id.sh
PAUSE
---------------------------------------------------------------------------
-- create scheduler job
BEGIN
   dbms_scheduler.create_job(
   job_name => 'id_local_cred',
   job_type => 'EXECUTABLE',
   job_action => '&dir_path/run_id.sh',
   start_date => SYSDATE,
   enabled => FALSE,
   repeat_interval => NULL);
END;
/
PAUSE
---------------------------------------------------------------------------
-- create a local credentials for the job id_local_cred
BEGIN
    dbms_credential.create_credential(
      credential_name => 'PDBSEC_LOCAL_OS_USER',
      username => 'orapdbsec',
      password => 'LAB01schulung');
END;
/
PAUSE
---------------------------------------------------------------------------
-- assign the local credentials to the job id_local_cred
BEGIN
    dbms_scheduler.set_attribute('id_local_cred','credential_name','PDBSEC_LOCAL_OS_USER');
END;
/
PAUSE
---------------------------------------------------------------------------
-- run the job id_local_cred
BEGIN
    dbms_scheduler.run_job(job_name => 'id_local_cred', use_current_session=> TRUE);
END;
/
PAUSE
---------------------------------------------------------------------------
-- select dba_scheduler_job_log
SELECT log_id,
    to_char(log_date,'DD.MM.YY HH24:MI:SS') log_date,
    job_name,status,
    user_name,credential_owner,
    credential_name,additional_info
FROM dba_scheduler_job_log 
WHERE job_name LIKE 'ID_%'
ORDER by log_id,log_date; 
---------------------------------------------------------------------------
-- select dba_scheduler_job_run_details
SELECT log_id,
    to_char(log_date,'DD.MM.YY HH24:MI:SS') log_date,
    job_name,status,
    credential_owner,
    credential_name,additional_info
FROM dba_scheduler_job_run_details WHERE job_name LIKE 'ID_%'
ORDER by log_id,log_date; 
PAUSE
---------------------------------------------------------------------------
-- check log file
HOST cat &dir_path/run_id.log
---------------------------------------------------------------------------
-- Show current setting for PDB_OS_CREDENTIAL
SHOW PARAMETER PDB_OS_CREDENTIAL
PAUSE
---------------------------------------------------------------------------
-- create a second job
BEGIN
   dbms_scheduler.create_job(
   job_name => 'id_no_cred',
   job_type => 'EXECUTABLE',
   job_action => '&dir_path/run_id.sh',
   start_date => SYSDATE,
   enabled => FALSE,
   repeat_interval => NULL);
END;
/
PAUSE
---------------------------------------------------------------------------
-- run the job id_no_cred without assigning any credentials
BEGIN
    dbms_scheduler.run_job(job_name => 'id_no_cred', use_current_session=> TRUE);
END;
/
PAUSE
---------------------------------------------------------------------------
-- select dba_scheduler_job_log
SELECT log_id,
    to_char(log_date,'DD.MM.YY HH24:MI:SS') log_date,
    job_name,status,
    user_name,credential_owner,
    credential_name,additional_info
FROM dba_scheduler_job_log 
WHERE job_name LIKE 'ID_%'
ORDER by log_id,log_date;
---------------------------------------------------------------------------
-- select dba_scheduler_job_run_details
SELECT log_id,
    to_char(log_date,'DD.MM.YY HH24:MI:SS') log_date,
    job_name,status,
    credential_owner,
    credential_name,additional_info
FROM dba_scheduler_job_run_details WHERE job_name LIKE 'ID_%'
ORDER by log_id,log_date; 
---------------------------------------------------------------------------
-- check log file
HOST cat &dir_path/run_id.log
PAUSE
---------------------------------------------------------------------------
-- check externaljob.ora file
HOST ls -al $ORACLE_HOME/rdbms/admin/externaljob.ora
HOST grep -iv '^#' $ORACLE_HOME/rdbms/admin/externaljob.ora
PAUSE
---------------------------------------------------------------------------
-- Change PDB_OS_CREDENTIAL in pdbsec
CONNECT / as SYSDBA
ALTER SESSION SET CONTAINER=pdbsec;
SHOW CON_NAME
ALTER SYSTEM SET pdb_os_credential=PDBSEC_OS_USER scope=spfile;
STARTUP FORCE;
SHOW PARAMETER PDB_OS_CREDENTIAL
PAUSE
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- create a third job
BEGIN
   dbms_scheduler.create_job(
   job_name => 'id_pdb_os_cred',
   job_type => 'EXECUTABLE',
   job_action => '&dir_path/run_id.sh',
   start_date => SYSDATE,
   enabled => FALSE,
   repeat_interval => NULL);
END;
/
PAUSE
---------------------------------------------------------------------------
-- run the job id_no_cred without assigning any credentials
BEGIN
    dbms_scheduler.run_job(job_name => 'id_pdb_os_cred', use_current_session=> TRUE);
END;
/
PAUSE
---------------------------------------------------------------------------
-- select dba_scheduler_job_log
SELECT log_id,
    to_char(log_date,'DD.MM.YY HH24:MI:SS') log_date,
    job_name,status,
    user_name,credential_owner,
    credential_name,additional_info
FROM dba_scheduler_job_log 
WHERE job_name LIKE 'ID_%'
ORDER by log_id,log_date;
---------------------------------------------------------------------------
-- select dba_scheduler_job_run_details
SELECT log_id,
    to_char(log_date,'DD.MM.YY HH24:MI:SS') log_date,
    job_name,status,
    credential_owner,
    credential_name,additional_info
FROM dba_scheduler_job_run_details WHERE job_name LIKE 'ID_%'
ORDER by log_id,log_date; 
PAUSE
---------------------------------------------------------------------------
-- check log file
HOST cat &dir_path/run_id.log
PAUSE
SET ECHO OFF
SET FEEDBACK OFF
---------------------------------------------------------------------------
-- clean up
EXEC dbms_scheduler.drop_job(job_name => 'id_local_cred');
EXEC dbms_scheduler.drop_job(job_name => 'id_pdb_os_cred');
EXEC dbms_scheduler.drop_job(job_name => 'id_no_cred');
EXEC dbms_credential.drop_credential(credential_name => 'PDBSEC_LOCAL_OS_USER');
---------------------------------------------------------------------------
-- Change PDB_OS_CREDENTIAL back in pdbsec
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=&pdb_db_name;
ALTER SYSTEM RESET pdb_os_credential scope=spfile;
STARTUP FORCE;
---------------------------------------------------------------------------
-- 42_create_scheduler_job.sql : finished
---------------------------------------------------------------------------
SHOW PARAMETER PDB_OS_CREDENTIAL
SET FEEDBACK ON
-- EOF ---------------------------------------------------------------------