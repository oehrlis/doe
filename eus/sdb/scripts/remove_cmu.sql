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

-- reset parameter for Kerberos authentication
PROMPT INFO: reset parameter for Kerberos authentication 
ALTER SYSTEM RESET os_authent_prefix SCOPE=spfile;
ALTER SYSTEM RESET remote_os_authent SCOPE=spfile;

-- reset parameter for CMU authentication and autorisation
PROMPT INFO: reset parameter for CMU authentication and autorisation
ALTER SYSTEM RESET ldap_directory_access ;
ALTER SYSTEM RESET ldap_directory_sysauth scope=spfile;

-- remove CMU configuration
PROMPT INFO: remove CMU configuration directory
ALTER DATABASE PROPERTY REMOVE CMU_WALLET;

-- drop Oracle Directory Object for CMU configuration
DROP DIRECTORY cmu_conf_dir;

-- drop logon trigger cmu_logon
PROMPT INFO: drop logon trigger cmu_logon
DROP TRIGGER sys.cmu_logon ;

PROMPT *************************************************************************
PROMPT Please restart the database to make sure that the parameter adjustments
PROMPT are implemented. The following CMU changes have been removed / reset:
PROMPT - os_authent_prefix
PROMPT - remote_os_authent
PROMPT - ldap_directory_access
PROMPT - ldap_directory_sysauth
PROMPT - remove CMU config directory CMU_CONF_DIR
PROMPT - drop logon trigger cmu_logon 
PROMPT *************************************************************************
-- - EOF --------------------------------------------------------------
