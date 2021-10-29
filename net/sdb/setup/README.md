# SDB Setup Files

This folder contains all files executed after the single tenant database instance is initially created. Currently only bash scripts (.sh) SQL files (.sql) are supported.

- [01_enable_unified_audit.sh](01_enable_unified_audit.sh) Enable pure unified audit.
- [02_create_scott.sql](02_create_scott.sql) Wrapper script for ``utlsampl.sql`` to create the SCOTT schema.
- [03_create_tvd_hr.sql](03_create_tvd_hr.sql) Script to create the TVD_HR schema. TVD_HR schema corresponds to Oracle's standard HR schema. The data has been adjusted so that it matches the example LDAP data of *trivadislabs.com* 
- [04_eus_config.sql](04_eus_config.sql) Script to create the EUS schemas for global shared and private schemas in PDB1.
- [06_keystore_import_trustcert.sh](06_keystore_import_trustcert.sh) Script to import the trust certificate into java keystore.
- [08_eus_registration.sh](08_eus_registration.sh) Script to register database in OUD instance using `dbca`.
- [09_eus_mapping.sh](09_eus_mapping.sh) ipt to create the EUS mapping to different global shared and private schemas as well global roles.