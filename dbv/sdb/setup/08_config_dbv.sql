----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 09_config_dbv.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2020.07.01
--  Revision..:  
--  Purpose...: Script to install DB Vault and Label Security
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
--
conn / as sysdba

-- create security role level C1
CREATE ROLE sec_access_c1;
GRANT CREATE SESSION TO sec_access_c1;
GRANT tvd_hr_ro TO sec_access_c1;

-- create security role level C2
CREATE ROLE sec_access_c2;
GRANT sec_access_c1 TO sec_access_c2;
GRANT tvd_hr_rw TO sec_access_c2;

-- create security role level C3
CREATE ROLE sec_access_c3;
GRANT sec_access_c2 TO sec_access_c3;

-- create security role level C3+
CREATE ROLE sec_access_c3p;
GRANT sec_access_c3 TO sec_access_c3p;

conn tvd_dv_accmgr/tvd_dv_accmgr
-- create security users level C1-C3+
CREATE USER user_c1 identified by user_c1;
CREATE USER user_c2 identified by user_c2;
CREATE USER user_c3 identified by user_c3;
CREATE USER user_c3p identified by user_c3p;

-- grant roles
conn / as sysdba
GRANT sec_access_c1 TO user_c1;
GRANT sec_access_c2 TO user_c2;
GRANT sec_access_c3 TO user_c3;
GRANT sec_access_c3p TO user_c3p;

-- create realms
conn tvd_dv_owner/tvd_dv_owner
EXEC DBMS_MACADM.DELETE_REALM('TVD HR Security Realm'); 
BEGIN
 DBMS_MACADM.CREATE_REALM(
  realm_name    => 'TVD HR Security Realm', 
  description   => 'Limit Access to TVD HR', 
  enabled       => DBMS_MACUTL.G_YES, 
  audit_options => DBMS_MACUTL.G_REALM_AUDIT_FAIL + DBMS_MACUTL.G_REALM_AUDIT_SUCCESS,
  realm_type    => 1,
 pl_sql_stack  => TRUE);
END; 
/

-- add schema owner to realm
BEGIN
 DBMS_MACADM.ADD_AUTH_TO_REALM(
  realm_name   => 'TVD HR Security Realm', 
  grantee      => 'TVD_HR', 
  auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER);
END;
/

-- add role auth to realm
EXEC DBMS_MACADM.ADD_AUTH_TO_REALM( 'TVD HR Security Realm', 'SEC_ACCESS_C1'); 
EXEC DBMS_MACADM.ADD_AUTH_TO_REALM( 'TVD HR Security Realm', 'SEC_ACCESS_C2'); 
EXEC DBMS_MACADM.ADD_AUTH_TO_REALM( 'TVD HR Security Realm', 'SEC_ACCESS_C3'); 
EXEC DBMS_MACADM.ADD_AUTH_TO_REALM( 'TVD HR Security Realm', 'SEC_ACCESS_C3P'); 

-- add all objects from TVD_HR to realm
BEGIN
 DBMS_MACADM.ADD_OBJECT_TO_REALM(
  realm_name   => 'TVD HR Security Realm', 
  object_owner => 'tvd_hr', 
  object_name  => '%', 
  object_type  => '%'); 
END;
/

-- add role sec_access_c1 to realm
BEGIN
 DBMS_MACADM.ADD_OBJECT_TO_REALM(
  realm_name   => 'TVD HR Security Realm', 
  object_owner => '%', 
  object_name  => 'SEC_ACCESS_C1', 
  object_type  => 'ROLE'); 
END;
/

-- add role sec_access_c2 to realm
BEGIN
 DBMS_MACADM.ADD_OBJECT_TO_REALM(
  realm_name   => 'TVD HR Security Realm', 
  object_owner => '%', 
  object_name  => 'SEC_ACCESS_C2', 
  object_type  => 'ROLE'); 
END;
/

-- add role sec_access_c3 to realm
BEGIN
 DBMS_MACADM.ADD_OBJECT_TO_REALM(
  realm_name   => 'TVD HR Security Realm', 
  object_owner => '%', 
  object_name  => 'SEC_ACCESS_C3', 
  object_type  => 'ROLE'); 
END;
/

-- add role sec_access_c3p to realm
BEGIN
 DBMS_MACADM.ADD_OBJECT_TO_REALM(
  realm_name   => 'TVD HR Security Realm', 
  object_owner => '%', 
  object_name  => 'SEC_ACCESS_C3P', 
  object_type  => 'ROLE'); 
END;
/

conn user_c1/user_c1
SELECT count(*) FROM tvd_hr.employees;

-- Levels
-- EMPLOYEE_ID      => C2
-- FIRST_NAME       => C1
-- LAST_NAME        => C1
-- EMAIL            => C2
-- PHONE_NUMBER     => C2
-- HIRE_DATE        => C2
-- JOB_ID           => C1
-- SALARY           => C3+
-- COMMISSION_PCT   => C3
-- MANAGER_ID       => C2
-- DEPARTMENT_ID    => C2
 
-- -- check as app user
-- CONN app01/app01
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;
-- -- check as schema owner
-- CONN tvd_hr/tvd_hr
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;

-- -- enable mandatory realm
-- conn tvd_dv_owner/tvd_dv_owner
-- BEGIN
--  DBMS_MACADM.UPDATE_REALM(
--   realm_name    => 'TVD_HR C3 Access', 
--   description   => 'Limit Access for C3 Objects', 
--   enabled       => DBMS_MACUTL.G_YES, 
--   audit_options => DBMS_MACUTL.G_REALM_AUDIT_FAIL + DBMS_MACUTL.G_REALM_AUDIT_SUCCESS,
--   realm_type    => 1,
--  pl_sql_stack  => TRUE);
-- END; 
-- /

-- BEGIN
--  DBMS_MACADM.ADD_AUTH_TO_REALM(
--   realm_name   => 'TVD_HR C3 Access', 
--   grantee      => 'TVD_HR', 
--   auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER);
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_AUTH_TO_REALM(
--   realm_name  => 'TVD_HR C3 Access', 
--   grantee     => 'APP01_C3_VIEW'); 
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_AUTH_TO_REALM(
--   realm_name  => 'TVD_HR C3 Access', 
--   grantee     => 'APP02_C3_VIEW'); 
-- END;
-- /

-- -- check as app user
-- CONN app01/app01
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;
-- -- check as schema owner
-- CONN tvd_hr/tvd_hr
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;

-- conn tvd_dv_owner/tvd_dv_owner
-- EXEC DBMS_MACADM.DELETE_REALM('TVD_HR C3+ Access'); 
-- BEGIN
--  DBMS_MACADM.CREATE_REALM(
--   realm_name    => 'TVD_HR C3+ Access', 
--   description   => 'Limit Access for C3+ Objects', 
--   enabled       => DBMS_MACUTL.G_YES, 
--   audit_options => DBMS_MACUTL.G_REALM_AUDIT_FAIL + DBMS_MACUTL.G_REALM_AUDIT_SUCCESS,
--   realm_type    => 0,
--  pl_sql_stack  => TRUE);
-- END; 
-- /

-- BEGIN
--  DBMS_MACADM.ADD_OBJECT_TO_REALM(
--   realm_name   => 'TVD_HR C3+ Access', 
--   object_owner => 'tvd_hr', 
--   object_name  => 'EMPLOYEES_C3P', 
--   object_type  => 'TABLE'); 
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_OBJECT_TO_REALM(
--   realm_name   => 'TVD_HR C3+ Access', 
--   object_owner => 'tvd_hr', 
--   object_name  => 'DEPARTMENTS_C3P', 
--   object_type  => 'TABLE'); 
-- END;
-- /

-- -- check as app user
-- CONN app01/app01
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;
-- -- check as schema owner
-- CONN tvd_hr/tvd_hr
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;

-- conn tvd_dv_owner/tvd_dv_owner
-- BEGIN
--  DBMS_MACADM.UPDATE_REALM(
--   realm_name    => 'TVD_HR C3+ Access', 
--   description   => 'Limit Access for C3+ Objects', 
--   enabled       => DBMS_MACUTL.G_YES, 
--   audit_options => DBMS_MACUTL.G_REALM_AUDIT_FAIL + DBMS_MACUTL.G_REALM_AUDIT_SUCCESS,
--   realm_type    => 1,
--  pl_sql_stack  => TRUE);
-- END; 
-- /

-- BEGIN
--  DBMS_MACADM.ADD_AUTH_TO_REALM(
--   realm_name   => 'TVD_HR C3+ Access', 
--   grantee      => 'TVD_HR', 
--   auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER);
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_AUTH_TO_REALM(
--   realm_name  => 'TVD_HR C3+ Access', 
--   grantee     => 'APP01_C3P_VIEW'); 
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_AUTH_TO_REALM(
--   realm_name  => 'TVD_HR C3+ Access', 
--   grantee     => 'APP02_C3P_VIEW'); 
-- END;
-- /

-- -- check as app user
-- CONN app01/app01
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;

-- -- check as app01c3 user
-- CONN app01c3/app01c3
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;

-- -- check as app01c3 user
-- CONN app01c3p/app01c3p
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;

-- -- check as schema owner
-- CONN tvd_hr/tvd_hr
-- SELECT count(*) FROM tvd_hr.employees;
-- SELECT count(*) FROM tvd_hr.employees_c3;
-- SELECT count(*) FROM tvd_hr.employees_c3p;

-- conn tvd_dv_owner/tvd_dv_owner
-- EXEC DBMS_MACADM.DELETE_REALM('TVD_HR Secure Access'); 
-- BEGIN
--  DBMS_MACADM.CREATE_REALM(
--   realm_name    => 'TVD_HR Secure Access', 
--   description   => 'Configure security for TVD_HR realms', 
--   enabled       => DBMS_MACUTL.G_YES, 
--   audit_options => DBMS_MACUTL.G_REALM_AUDIT_FAIL + DBMS_MACUTL.G_REALM_AUDIT_SUCCESS,
--   realm_type    => 0,
--  pl_sql_stack  => TRUE);
-- END; 
-- /

-- BEGIN
--  DBMS_MACADM.ADD_AUTH_TO_REALM(
--   realm_name   => 'TVD_HR Secure Access', 
--   grantee      => 'TVD_HR', 
--   auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER);
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_OBJECT_TO_REALM(
--   realm_name   => 'TVD_HR Secure Access', 
--   object_owner => '%', 
--   object_name  => 'APP01_C3_VIEW', 
--   object_type  => 'ROLE'); 
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_OBJECT_TO_REALM(
--   realm_name   => 'TVD_HR Secure Access', 
--   object_owner => '%', 
--   object_name  => 'APP01_C3P_VIEW', 
--   object_type  => 'ROLE'); 
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_OBJECT_TO_REALM(
--   realm_name   => 'TVD_HR Secure Access', 
--   object_owner => '%', 
--   object_name  => 'APP02_C3_VIEW', 
--   object_type  => 'ROLE'); 
-- END;
-- /

-- BEGIN
--  DBMS_MACADM.ADD_OBJECT_TO_REALM(
--   realm_name   => 'TVD_HR Secure Access', 
--   object_owner => '%', 
--   object_name  => 'APP02_C3P_VIEW', 
--   object_type  => 'ROLE'); 
-- END;
-- /
-- EOF ---------------------------------------------------------------------

select * from unified_audit_trail;

BEGIN
DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
audit_trail_type         =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
use_last_arch_timestamp  =>  FALSE);
END;
/


select * from AUDITABLE_SYSTEM_ACTIONS where component='Database Vault';
DROP AUDIT POLICY dv_audit;

CREATE AUDIT POLICY dv_audit ACTIONS COMPONENT = DV 
    REALM VIOLATION on "TVD_HR C3 Access",
    REALM SUCCESS on "TVD_HR C3 Access",
    REALM ACCESS on "TVD_HR C3 Access",
    REALM VIOLATION on "TVD_HR C3+ Access",
    REALM SUCCESS on "TVD_HR C3+ Access",
    REALM ACCESS on "TVD_HR C3+ Access",
    REALM VIOLATION on "TVD_HR Secure Access",
    REALM SUCCESS on "TVD_HR Secure Access",
    REALM ACCESS on "TVD_HR Secure Access";

AUDIT POLICY dv_audit;

SELECT name FROM auditable_system_actions WHERE component = 'Database Vault';

