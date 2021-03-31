----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 07_enable_dbv.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2021.03.18
--  Revision..:  
--  Purpose...: Script to enable DB Vault and Label Security
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

-- create DV User
CREATE USER tvd_dv_owner IDENTIFIED BY tvd_dv_owner;
CREATE USER tvd_dv_accmgr IDENTIFIED BY tvd_dv_accmgr;

-- config DBV
EXEC dvsys.configure_dv('TVD_DV_OWNER','TVD_DV_ACCMGR');

-- enable DBV
conn tvd_dv_owner/tvd_dv_owner
EXEC dbms_macadm.enable_dv;

-- restart DB
CONN / AS sysdba
STARTUP FORCE;
-- EOF ---------------------------------------------------------------------
