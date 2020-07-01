----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 04_eus_config_cdb.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.12.10
--  Revision..:  
--  Purpose...: Script to create the EUS schemas for global shared and 
--              private schemas
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100 

-- Define the default values 
-- remove existing lockdown profiles
DECLARE
    vcount        INTEGER := 0;
    TYPE table_varchar IS
        TABLE OF VARCHAR2(128);
    users   table_varchar := table_varchar('C##EUS_USERS');
    roles   table_varchar := table_varchar('COMMON_CLERK','HR_CLERK','COMMON_MGR','HR_MGR');
BEGIN  
    FOR i IN 1..users.count LOOP
        SELECT COUNT(1) INTO vcount FROM dba_users WHERE username = users(i);
        IF vcount != 0 THEN
            EXECUTE IMMEDIATE ('DROP USER '||users(i));
        END IF; 
    END LOOP;

    -- FOR i IN 1..roles.count LOOP
    --     SELECT COUNT(1) INTO vcount FROM dba_roles WHERE role = roles(i);
    --     IF vcount != 0 THEN
    --         EXECUTE IMMEDIATE ('DROP ROLE '||roles(i));
    --     END IF; 
    -- END LOOP;
END;
/

-- general global shared schema
CREATE USER c##eus_users IDENTIFIED GLOBALLY;
GRANT connect TO EUS_USERS;
GRANT SELECT ON v_$session TO eus_users;

-- enterprise role for common clerks
-- CREATE ROLE common_clerk IDENTIFIED GLOBALLY;
-- GRANT tvd_hr_ro TO common_clerk;

-- -- enterprise role for HR clerks
-- CREATE ROLE hr_clerk IDENTIFIED GLOBALLY;
-- GRANT tvd_hr_ro TO hr_clerk;

-- -- enterprise role for common managers
-- CREATE ROLE common_mgr IDENTIFIED GLOBALLY;
-- GRANT tvd_hr_ro TO common_mgr;

-- -- enterprise role for HR managers
-- CREATE ROLE hr_mgr IDENTIFIED GLOBALLY;
-- GRANT tvd_hr_rw TO hr_mgr;

-- grant proxy connect for enterprise users
-- ALTER USER tvd_hr GRANT CONNECT THROUGH ENTERPRISE USERS;
-- EOF ---------------------------------------------------------------------