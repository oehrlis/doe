set linesize 180 pagesize 200
set feedback on
set echo on
col USER_NAME for a20
col POLICY_NAME for a30
col ENTITY_NAME for a40
col EVENT_TIMESTAMP for a30 
col OS_USERNAME for a11
col DBUSERNAME for a10
col ACTION_NAME for a25
col RETURN_CODE for 999999999999
col SYSTEM_PRIVILEGE_USED for a20
col UNIFIED_AUDIT_POLICIES for a40

-- purge audit trail
BEGIN
  dbms_audit_mgmt.clean_audit_trail(
    audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
    container => dbms_audit_mgmt.container_all,
    use_last_arch_timestamp => false);
END;
/  

conn / as sysdba
alter session set container=pdb1;

col USER_NAME for a20
col POLICY_NAME for a30
col ENTITY_NAME for a20
select * from audit_unified_enabled_policies order by 2,1;


conn scott/tiger@tua200.trivadislabs.com:1521/pdb1
conn system/manager@tua200.trivadislabs.com:1521/pdb1
conn c##test/manager@tua200.trivadislabs.com:1521/pdb1
conn / as sysdba
alter session set container=pdb1;
SELECT event_timestamp,con_id,os_username,dbusername,action_name,return_code,system_privilege_used,unified_audit_policies 
FROM cdb_unified_audit_trail 
ORDER BY event_timestamp;


SELECT event_timestamp,con_id,os_username,dbusername,action_name,return_code,system_privilege_used,unified_audit_policies 
FROM cdb_unified_audit_trail 
ORDER BY event_timestamp;