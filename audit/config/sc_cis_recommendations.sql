----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: swisscom_cis_controls_execute.sql
--  Author....: Martin Berger (mbg) martin.berger@trivadis.com
--  Editor....: Martin Berger
--  Date......: 2020.09.14
--  Revision..:  
--  Purpose...: Revoke EXECUTE permissions from PUBLIC according CIS benchmark
--  Usage.....: @swisscom_cis_controls_execute
--              
--              
--  Notes.....: CIS benchmark based on Oracle 18c
--  Reference.: has to execute / AS SYSDBA
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

DECLARE
 -- define array
    TYPE network_array IS VARRAY(20) OF VARCHAR2(50);
    TYPE filesystem_array IS VARRAY(20) OF VARCHAR2(50);
    TYPE encryption_array IS VARRAY(20) OF VARCHAR2(50);
    TYPE java_array IS VARRAY(20) OF VARCHAR2(50);
    TYPE jobscheduler_array IS VARRAY(20) OF VARCHAR2(50);
    TYPE sqlinjection_array IS VARRAY(20) OF VARCHAR2(50);
    TYPE nondefault_array IS VARRAY(20) OF VARCHAR2(50);
    v_packages_network          network_array;
    v_packages_filesystem       filesystem_array;
    v_packages_encryption       encryption_array;
    v_packages_java             java_array;
    v_packages_jobscheduler     jobscheduler_array;
    v_packages_sqlinjection     sqlinjection_array;
    v_packages_nondefault       nondefault_array;
    v_count_network             INTEGER;
    v_count_filesystem          INTEGER;
    v_count_encryption          INTEGER;
    v_count_java                INTEGER;
    v_count_jobscheduler        INTEGER;
    v_count_sqlinjection        INTEGER;
    v_count_nondefault          INTEGER;
    v_sql                       VARCHAR2(4000);
    v_exists                    INTEGER := 0;
    v_granted                    INTEGER := 0;

BEGIN
--- set array values
 -- initialize array for network
     v_packages_network := network_array('DBMS_LDAP', 'UTL_INADDR', 'UTL_TCP', 'UTL_MAIL', 'UTL_SMTP','UTL_DBWS', 'UTL_ORAMTS', 'UTL_HTTP', 'HTTPURITYPE'); 
 -- initialize array for filesystem
     v_packages_filesystem := filesystem_array('DBMS_ADVISOR','DBMS_LOB','UTL_FILE');  
 -- initialize array for encryption
     v_packages_encryption := encryption_array('DBMS_CRYPTO','DBMS_OBFUSCATION_TOOLKIT','DBMS_RANDOM');  
 -- initialize array for java
     v_packages_java := java_array('DBMS_JAVA','DBMS_JAVA_TEST');  
  -- initialize array for job scheduler
     v_packages_jobscheduler := jobscheduler_array('DBMS_JOB','DBMS_SCHEDULER');  
  -- initialize array for sql injection
     v_packages_sqlinjection := sqlinjection_array('DBMS_SQL','DBMS_XMLGEN','DBMS_XMLQUERY','DBMS_XMLSAVE','DBMS_XMLSTORE','DBMS_AW','OWA_UTIL','DBMS_REDACT');  
   -- initialize array for non-default
     v_packages_nondefault := nondefault_array('DBMS_BACKUP_RESTORE','DBMS_FILE_TRANSFER','DBMS_XMLQUERY','DBMS_SYS_SQL','DBMS_XMLSTORE','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','DBMS_IJOB','DBMS_PDB_EXEC_SQL');  
 
  
 --- define array length   
 -- network element count                           
    v_count_network := v_packages_network.count;
 -- filesystem element count                           
    v_count_filesystem := v_packages_filesystem.count;
 -- encryption element count                           
    v_count_encryption := v_packages_encryption.count;
 -- java element count                           
    v_count_java := v_packages_java.count;
 -- job scheduler element count                           
    v_count_jobscheduler := v_packages_jobscheduler.count;
 -- sql injection element count                           
    v_count_sqlinjection := v_packages_sqlinjection.count;
 -- non-default element count                           
    v_count_nondefault := v_packages_nondefault.count;

   
--- execute sql
  -- proceed network array revoke 
    FOR i IN 1..v_packages_network.count LOOP
      BEGIN
        -- check for existing object
        SELECT COUNT(1) INTO v_exists FROM dba_objects WHERE object_type in ('PACKAGE','TYPE')  AND owner='SYS' AND object_name = v_packages_network(i);
        -- check if grant is available on existing object
        SELECT COUNT(1) INTO v_granted FROM dba_tab_privs WHERE table_name = v_packages_network(i) AND grantee = 'PUBLIC';       
        IF (v_exists = 1 AND v_granted = 1) THEN
            v_sql := 'REVOKE EXECUTE ON '
            ||sys.dbms_assert.enquote_name(v_packages_network(i))
            || ' FROM'
            || ' PUBLIC';
            -- display statement
            dbms_output.put_line('INFO NETWORK : execute '||v_sql);
            -- execute statement
            EXECUTE IMMEDIATE v_sql;
         END IF; 
         EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
    END LOOP; 

  -- proceed filesystem array revoke 
    FOR i IN 1..v_packages_filesystem.count LOOP
      BEGIN
        -- check for existing object
        SELECT COUNT(1) INTO v_exists FROM dba_objects WHERE object_type in ('PACKAGE','TYPE')  AND owner='SYS' AND object_name = v_packages_filesystem(i);
        -- check if grant is available on existing object
        SELECT COUNT(1) INTO v_granted FROM dba_tab_privs WHERE table_name = v_packages_filesystem(i) AND grantee = 'PUBLIC';       
        IF (v_exists = 1 AND v_granted = 1) THEN
            v_sql := 'REVOKE EXECUTE ON '
            ||sys.dbms_assert.enquote_name(v_packages_filesystem(i))
            || ' FROM'
            || ' PUBLIC';
            -- display statement
            dbms_output.put_line('INFO FILESYSTEM : execute '||v_sql);
            -- execute statement
            EXECUTE IMMEDIATE v_sql;
         END IF; 
         EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
    END LOOP; 
    
  -- proceed encryption array revoke 
    FOR i IN 1..v_packages_encryption.count LOOP
      BEGIN
        -- check for existing object
        SELECT COUNT(1) INTO v_exists FROM dba_objects WHERE object_type in ('PACKAGE','TYPE')  AND owner='SYS' AND object_name = v_packages_encryption(i);
        -- check if grant is available on existing object
        SELECT COUNT(1) INTO v_granted FROM dba_tab_privs WHERE table_name = v_packages_encryption(i) AND grantee = 'PUBLIC';       
        IF (v_exists = 1 AND v_granted = 1) THEN
            v_sql := 'REVOKE EXECUTE ON '
            ||sys.dbms_assert.enquote_name(v_packages_encryption(i))
            || ' FROM'
            || ' PUBLIC';
            -- display statement
            dbms_output.put_line('INFO ENCRYPTION : execute '||v_sql);
            -- execute statement
            EXECUTE IMMEDIATE v_sql;
         END IF; 
         EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
    END LOOP; 

  -- proceed java array revoke 
    FOR i IN 1..v_packages_java.count LOOP
      BEGIN
        -- check for existing object
        SELECT COUNT(1) INTO v_exists FROM dba_objects WHERE object_type in ('PACKAGE','TYPE')  AND owner='SYS' AND object_name = v_packages_java(i);
        -- check if grant is available on existing object
        SELECT COUNT(1) INTO v_granted FROM dba_tab_privs WHERE table_name = v_packages_java(i) AND grantee = 'PUBLIC';       
        IF (v_exists = 1 AND v_granted = 1) THEN
            v_sql := 'REVOKE EXECUTE ON '
            ||sys.dbms_assert.enquote_name(v_packages_java(i))
            || ' FROM'
            || ' PUBLIC';
            -- display statement
            dbms_output.put_line('INFO JAVA : execute '||v_sql);
            -- execute statement
            EXECUTE IMMEDIATE v_sql;
         END IF; 
         EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
    END LOOP;     

  -- proceed jobscheduler array revoke 
    FOR i IN 1..v_packages_jobscheduler.count LOOP
      BEGIN
        -- check for existing object
        SELECT COUNT(1) INTO v_exists FROM dba_objects WHERE object_type in ('PACKAGE','TYPE')  AND owner='SYS' AND object_name = v_packages_jobscheduler(i);
        -- check if grant is available on existing object
        SELECT COUNT(1) INTO v_granted FROM dba_tab_privs WHERE table_name = v_packages_jobscheduler(i) AND grantee = 'PUBLIC';       
        IF (v_exists = 1 AND v_granted = 1) THEN
            v_sql := 'REVOKE EXECUTE ON '
            ||sys.dbms_assert.enquote_name(v_packages_jobscheduler(i))
            || ' FROM'
            || ' PUBLIC';
            -- display statement
            dbms_output.put_line('INFO JOBSCHEDULER : execute '||v_sql);
            -- execute statement
            EXECUTE IMMEDIATE v_sql;
         END IF; 
         EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
    END LOOP;   
    
  -- proceed sqlinjection array revoke 
    FOR i IN 1..v_packages_sqlinjection.count LOOP
      BEGIN
        -- check for existing object
        SELECT COUNT(1) INTO v_exists FROM dba_objects WHERE object_type in ('PACKAGE','TYPE')  AND owner='SYS' AND object_name = v_packages_sqlinjection(i);
        -- check if grant is available on existing object
        SELECT COUNT(1) INTO v_granted FROM dba_tab_privs WHERE table_name = v_packages_sqlinjection(i) AND grantee = 'PUBLIC';       
        IF (v_exists = 1 AND v_granted = 1) THEN
            v_sql := 'REVOKE EXECUTE ON '
            ||sys.dbms_assert.enquote_name(v_packages_sqlinjection(i))
            || ' FROM'
            || ' PUBLIC';
            -- display statement
            dbms_output.put_line('INFO SQLINJECTION : execute '||v_sql);
            -- execute statement
            EXECUTE IMMEDIATE v_sql;
         END IF; 
         EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
    END LOOP;  

  -- proceed nondefault array revoke 
    FOR i IN 1..v_packages_nondefault.count LOOP
      BEGIN
        -- check for existing object
        SELECT COUNT(1) INTO v_exists FROM dba_objects WHERE object_type in ('PACKAGE','TYPE')  AND owner='SYS' AND object_name = v_packages_nondefault(i);
        -- check if grant is available on existing object
        SELECT COUNT(1) INTO v_granted FROM dba_tab_privs WHERE table_name = v_packages_nondefault(i) AND grantee = 'PUBLIC';       
        IF (v_exists = 1 AND v_granted = 1) THEN
            v_sql := 'REVOKE EXECUTE ON '
            ||sys.dbms_assert.enquote_name(v_packages_nondefault(i))
            || ' FROM'
            || ' PUBLIC';
            -- display statement
            dbms_output.put_line('INFO SQLINJECTION : execute '||v_sql);
            -- execute statement
            EXECUTE IMMEDIATE v_sql;
         END IF; 
         EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
    END LOOP;  

END;
/



