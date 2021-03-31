----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 07_config_tde.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2021.03.18
--  Revision..:  
--  Purpose...: Script to enable TDE
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

-- get the admin directory 
COLUMN admin_path NEW_VALUE admin_path NOPRINT
SELECT substr(value, 1, instr(value, '/', -1, 1)-1) admin_path from v$parameter where name ='audit_file_dest';

-- create the wallet folder
host mkdir -p &admin_path/wallet
host mkdir -p &admin_path/wallet/tde
host mkdir -p &admin_path/wallet/tde_seps

-- set the WALLET ROOT parameter
ALTER SYSTEM SET wallet_root='&admin_path/wallet' SCOPE=SPFILE;
STARTUP FORCE;

-- config TDE_CONFIGURATION
ALTER SYSTEM SET TDE_CONFIGURATION='KEYSTORE_CONFIGURATION=FILE' scope=both;

-- create software keystore
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE '&admin_path/wallet/tde' 
IDENTIFIED BY "LAB42-Schulung";
ADMINISTER KEY MANAGEMENT ADD SECRET 'LAB42-Schulung' FOR CLIENT 'TDE_WALLET' 
TO LOCAL AUTO_LOGIN KEYSTORE '&admin_path/wallet/tde_seps';

-- open the wallet
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE;

-- create autologin
ADMINISTER KEY MANAGEMENT CREATE LOCAL AUTO_LOGIN KEYSTORE FROM 
KEYSTORE '&admin_path/wallet/tde' identified by "LAB42-Schulung";

-- list wallet information
SET LINESIZE 160 PAGESIZE 200
COL wrl_type FOR A10
COL wrl_parameter FOR A50
SELECT * FROM v$encryption_wallet;

-- create master key
ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY USING TAG 'initial' 
IDENTIFIED BY EXTERNAL STORE WITH BACKUP USING 'initial_key_backup';

-- list wallet information
SELECT * FROM v$encryption_wallet;

-- list information about TDE TS
SELECT ts#,encryptionalg,encryptedts,blocks_encrypted,blocks_decrypted,con_id 
FROM v$encrypted_tablespaces;

-- EOF ---------------------------------------------------------------------