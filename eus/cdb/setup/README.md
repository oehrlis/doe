# CDB Setup Files

This folder contains all files executed after the CDB instance is initially created. Currently only bash scripts (.sh) SQL files (.sql) are supported.

- [01_enable_unified_audit.sh](01_enable_unified_audit.sh) Enable pure unified audit.
- [02_create_scott_pdb1.sql](02_create_scott_pdb1.sql) Wrapper script for ``utlsampl.sql`` to create the SCOTT schema in PDB1
- [03_create_tvd_hr_pdb1.sql](03_create_tvd_hr_pdb1.sql) Script to create the TVD_HR schema in PDB1. TVD_HR schema corresponds to Oracle's standard HR schema. The data has been adjusted so that it matches the example LDAP data of *trivadislabs.com* 
- [04_eus_config_cdb.sh](04_eus_config_cdb.sh)  Script to create the EUS schemas for global shared and private schemas in CDB.
- [04_eus_config_pdb1.sql](04_eus_config_pdb1.sql) Script to create the EUS schemas for global shared and private schemas in PDB1.
- [05_clone_pdb1_pdb2.sql](05_clone_pdb1_pdb2.sql) Script to clone PDB1 to PDB2.
- [06_keystore_import_trustcert.sh](06_keystore_import_trustcert.sh) Script to import the trust certificate into java keystore.
- [07_prepare_pdb_env.sh](07_prepare_pdb_env.sh) Script to prepare PDB environment and tnsnames eintries.
- [08_eus_registration_cdb.sh](08_eus_registration_cdb.sh) Script to register CDB in OUD instance using `dbca`.
- [08_eus_registration_pdb1.sh](08_eus_registration_pdb1.sh) Script to register CDB in PDB1 instance using `dbca`.
- [08_eus_registration_pdb2.sh](08_eus_registration_pdb2.sh) Script to register CDB in PDB2 instance using `dbca`.
- [09_eus_mapping_cdb.sh](09_eus_mapping_cdb.sh) ipt to create the EUS mapping to different global shared and private schemas as well global roles for CDB.
- [09_eus_mapping_pdb1.sh](09_eus_mapping_pdb1.sh) Script to create the EUS mapping to different global shared and private schemas as well global roles for PDB1.
- [09_eus_mapping_pdb2.sh](09_eus_mapping_pdb2.sh) Script to create the EUS mapping to different global shared and private schemas as well global roles for PDB2.
