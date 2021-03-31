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
-- 51_verify_lockdown_profiles.sql : prepare the PDB pdbsec
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- remove java permissions
DECLARE
    vcount INTEGER :=0;
BEGIN
    FOR java_pol IN (SELECT * FROM DBA_JAVA_POLICY WHERE GRANTEE=upper('&pdb_admin_user'))
LOOP
    dbms_java.revoke_permission(
        grantee=>java_pol.grantee,
        permission_type=>java_pol.type_schema ||':' ||java_pol.type_name,
        permission_name=>java_pol.name,
        permission_action=>java_pol.action);
    dbms_java.delete_permission(java_pol.seq);
END LOOP;
END;
/

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- check the current pdb_lockdown
SHOW PARAMETER pdb_lockdown
-- check the lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
WHERE lr.rule LIKE 'JAVA%'
ORDER BY 1,2,3,4,6;
PAUSE

---------------------------------------------------------------------------
-- Test JVM by creating a simple java source
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED JavaCalc AS
public class JavaCalc
{
    public static void main(String args []) {
        int a = Integer.parseInt(args[0]);
        int b = Integer.parseInt(args[1]);
        System.out.println ("Simple JVM test...");
        System.out.println ("Calculating "+ a + "*" + b + "=" + (a * b));
   }
}
/
show errors java source "JavaCalc"
PAUSE
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- Create lockdown profile tvd_jvm 
CREATE LOCKDOWN PROFILE tvd_jvm FROM tvd_default;
---------------------------------------------------------------------------
-- enable java runtime
ALTER LOCKDOWN PROFILE tvd_jvm ENABLE FEATURE = ('JAVA_RUNTIME');
---------------------------------------------------------------------------
-- enable the tvd_trace lockdown profile
ALTER SYSTEM SET pdb_lockdown=tvd_jvm SCOPE=BOTH;
PAUSE
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- check the current pdb_lockdown
SHOW PARAMETER pdb_lockdown
-- check the lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
WHERE lr.rule LIKE 'JAVA%'
ORDER BY 1,2,3,4,6;
PAUSE
---------------------------------------------------------------------------
-- Test JVM by creating a simple java source
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED JavaCalc AS
public class JavaCalc
{
    public static void main(String args []) {
        int a = Integer.parseInt(args[0]);
        int b = Integer.parseInt(args[1]);
        System.out.println ("Simple JVM test...");
        System.out.println ("Calculating "+ a + "*" + b + "=" + (a * b));
   }
}
/
show errors java source "JavaCalc"
PAUSE
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- enable java runtime
ALTER LOCKDOWN PROFILE tvd_jvm ENABLE FEATURE = ('JAVA');
PAUSE
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- check the current pdb_lockdown
SHOW PARAMETER pdb_lockdown
-- check the lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
WHERE lr.rule LIKE 'JAVA%'
ORDER BY 1,2,3,4,6;
PAUSE
---------------------------------------------------------------------------
-- Test JVM by creating a simple java source
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED JavaCalc AS
public class JavaCalc
{
    public static void main(String args []) {
        int a = Integer.parseInt(args[0]);
        int b = Integer.parseInt(args[1]);
        System.out.println ("Simple JVM test...");
        System.out.println ("Calculating "+ a + "*" + b + "=" + (a * b));
   }
}
/
show errors java source "JavaCalc"
PAUSE
---------------------------------------------------------------------------
-- Create a PL/SQL procedure to run the java class
CREATE OR REPLACE PROCEDURE JavaCalcSP (wid IN varchar2,wpos IN
varchar2)
AS LANGUAGE JAVA 
NAME 'JavaCalc.main(java.lang.String[])';
/
show errors;
PAUSE
---------------------------------------------------------------------------
-- Do a few tests
SET SERVEROUTPUT ON SIZE 1000000
EXEC dbms_java.set_output(1000000);
EXEC JavaCalcSP(2,21);
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- enable java runtime
ALTER LOCKDOWN PROFILE tvd_jvm DISABLE FEATURE = ('JAVA');
PAUSE
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- check the current pdb_lockdown
SHOW PARAMETER pdb_lockdown
-- check the lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
WHERE lr.rule LIKE 'JAVA%'
ORDER BY 1,2,3,4,6;
PAUSE
---------------------------------------------------------------------------
-- Do a few tests
SET SERVEROUTPUT ON SIZE 1000000
EXEC dbms_java.set_output(1000000);
EXEC JavaCalcSP(2,21);

SET ECHO OFF
CONNECT / as SYSDBA
ALTER SYSTEM SET pdb_lockdown=tvd_default SCOPE=BOTH;
DROP LOCKDOWN PROFILE tvd_jvm;
---------------------------------------------------------------------------
-- 51_lockdown_trace_view.sql : finished
---------------------------------------------------------------------------
-- EOF ---------------------------------------------------------------------
