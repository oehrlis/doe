----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 06_install_dbvault.sql
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
-- install label security
@?/rdbms/admin/catols.sql
-- enable label security
exec lbacsys.configure_ols
exec lbacsys.ols_enforcement.enable_ols

-- restart the database
startup force;

-- install DB Vault
@?/rdbms/admin/catmac.sql SYSTEM TEMP
-- EOF ---------------------------------------------------------------------