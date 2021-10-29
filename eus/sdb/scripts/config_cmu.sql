-- ---------------------------------------------------------------------
-- Trivadis AG, Platform Factory - Transactional Data Platform
-- Saegereistrasse 29, 8152 Glattbrugg, Switzerland
-- ---------------------------------------------------------------------
-- Name.......: sinfo.sql
-- Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
-- Editor.....: Stefan Oehrli
-- Date.......: 2021.05.11
-- Revision...: --
-- Purpose....: Shows information about the connected user
-- Notes......: --
-- Reference..: Trivadis TVD-BasEnv sql scripts
-- --------------------------------------------------------------------
-- Modified...:
-- YYYY.MM.DD  Visa Change
-- ----------- ---- ---------------------------------------------------
-- 2021.05.11  soe  Initial version based on sinfo.sql
-- --------------------------------------------------------------------
SET ECHO OFF
SET serveroutput ON SIZE 10000

-- adjust parameter for Kerberos authentication
PROMPT INFO: adjust parameter for Kerberos authentication 
ALTER SYSTEM SET os_authent_prefix='' SCOPE=spfile;
ALTER SYSTEM SET remote_os_authent=FALSE SCOPE=spfile;

-- adjust parameter for CMU authentication and autorisation
PROMPT INFO: adjust parameter for CMU authentication and autorisation
ALTER SYSTEM SET ldap_directory_access='PASSWORD';
ALTER SYSTEM SET ldap_directory_sysauth ='YES' scope=spfile;

-- Create Oracle Directory Object for CMU configuration
PROMPT INFO: create Oracle Directory Object for CMU configuration
COLUMN oracle_base NEW_VALUE oracle_base NOPRINT
SELECT directory_path oracle_base FROM dba_directories WHERE directory_name='ORACLE_BASE';
CREATE OR REPLACE DIRECTORY cmu_conf_dir AS '&oracle_base/network/admin/cmu';

-- define CMU configuration
PROMPT INFO: define CMU configuration directory
ALTER DATABASE PROPERTY SET cmu_wallet='CMU_CONF_DIR';

-- create logon trigger cmu_logon to set CLIENT_INFO
PROMPT INFO: create logon trigger cmu_logon to set CLIENT_INFO
CREATE OR REPLACE TRIGGER sys.cmu_logon AFTER LOGON ON DATABASE
DECLARE
  v_externalname varchar2(64) := '';
BEGIN
  SELECT substr(sys_context('userenv','enterprise_identity'),1,63) INTO v_externalname 
  FROM dual;
  IF v_externalname IS NOT NULL
  THEN
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO (v_externalname );
  END IF;
END;
/

PROMPT *************************************************************************
PROMPT Please restart the database to make sure that the parameter adjustments
PROMPT are implemented. The following changes have been implemented:
PROMPT - os_authent_prefix='' 
PROMPT - remote_os_authent=FALSE 
PROMPT - ldap_directory_access='PASSWORD'
PROMPT - ldap_directory_sysauth ='YES' 
PROMPT - create CMU config directory CMU_CONF_DIR
PROMPT - New a logon trigger cmu_logon to set CLIENT_INFO
PROMPT *************************************************************************
-- - EOF --------------------------------------------------------------
