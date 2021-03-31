----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 15_create_pdb_os_credential.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.10.22
--  Usage.....: @15_create_pdb_os_credential.sql
--  Purpose...: Script to create a PDB_OS_CREDENTIAL for PDB
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
--SPOOL {{ deployment_location }}/23_create_pdb_os_credential_{{oracle_pdb_name}}.log
SET SERVEROUTPUT ON
SET LINESIZE 160 PAGESIZE 200

---------------------------------------------------------------------------
-- Cleanup and remove old credentials if they do exists
DECLARE
    vcount        INTEGER := 0;
    TYPE table_varchar IS
        TABLE OF VARCHAR2(128);
    --credentials   table_varchar := table_varchar('PDB_OS_USER_{{oracle_pdb_name}}');
    credentials   table_varchar := table_varchar('PDB_OS_USER_PDBSEC');
BEGIN
    FOR i IN 1..credentials.count LOOP
        SELECT
            COUNT(1)
        INTO vcount
        FROM
            dba_credentials
        WHERE
            credential_name = credentials(i);

        IF vcount != 0 THEN
            dbms_credential.drop_credential(credential_name => credentials(i));
        END IF;
    END LOOP;
END;
/

---------------------------------------------------------------------------
-- Create a pdb specific credential
BEGIN
    dbms_credential.create_credential(
    --   credential_name => 'PDB_OS_USER_{{oracle_pdb_name}}',
    --   username => '{{pdb_os_user}}_{{ oracle_pdb_name | lower}}',
    --   password => '{{pdb_os_user_pwd}}_{{ oracle_pdb_name | lower}}');
      credential_name => 'PDB_OS_USER_PDBSEC',
      username => 'orapdbsec',
      password => 'LAB01schulung');
END;
/

---------------------------------------------------------------------------
-- Run in PDB
-- Change PDB_OS_CREDENTIAL in PDB
--ALTER SESSION SET CONTAINER={{oracle_pdb_name}};
ALTER SESSION SET CONTAINER=pdbsec;
SHOW CON_NAME
--ALTER SYSTEM SET pdb_os_credential='PDB_OS_USER_{{oracle_pdb_name}}' scope=spfile;
ALTER SYSTEM SET pdb_os_credential='PDB_OS_USER_PDBSEC' scope=spfile;
STARTUP FORCE;

SPOOL OFF
-- EOF ---------------------------------------------------------------------