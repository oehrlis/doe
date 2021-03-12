SPOOL service_trigger.log

COL service_rw NOPRINT NEW_VALUE service_rw
COL service_ro NOPRINT NEW_VALUE service_ro

SELECT rtrim(sys_context('userenv','con_name') ||'_RW.'|| a.value,'.') service_rw
FROM v$parameter a
WHERE a.name = 'db_domain'
;

SELECT rtrim(sys_context('userenv','con_name') ||'_RO.'|| a.value,'.') service_ro
FROM v$parameter a
WHERE a.name = 'db_domain'
;

PROMPT service_rw is &service_rw
PROMPT service_ro is &service_ro
PROMPT

SET FEED ON
SET ECHO ON

exec DBMS_SERVICE.CREATE_SERVICE ( -
  service_name => '&service_rw', -
  network_name => '&service_rw', -
  failover_method => 'BASIC', -
  failover_type => 'SELECT', -
  failover_retries => 3600, -
  failover_delay => 1);

exec DBMS_SERVICE.CREATE_SERVICE ( -
  service_name => '&service_ro', -
  network_name => '&service_ro', -
  failover_method => 'BASIC', -
  failover_type => 'SELECT', -
  failover_retries => 3600, -
  failover_delay => 1);

DECLARE
  pdb_name      VARCHAR(9);
  db_domain     VARCHAR(128);
  database_role VARCHAR(30);
BEGIN
  SELECT sys_context('userenv','con_name')
    INTO pdb_name
    FROM dual;
  
  SELECT value 
    INTO db_domain 
    FROM v$parameter 
      WHERE name = 'db_domain';
  
  SELECT database_role 
    INTO database_role 
    FROM v$database;

  IF database_role = 'PRIMARY' THEN
    dbms_service.start_service(rtrim(pdb_name||'_RW.'||db_domain,'.'));
  ELSE
    dbms_service.start_service(rtrim(pdb_name||'_RO.'||db_domain,'.'));
  END IF;
END;
/

CREATE OR REPLACE TRIGGER service_trigger
  after startup on database
DECLARE
  pdb_name       VARCHAR(9);
  db_domain     VARCHAR(128);
  database_role VARCHAR(30);
BEGIN
  SELECT sys_context('userenv','con_name')
    INTO pdb_name
    FROM dual;
  
  SELECT value 
    INTO db_domain 
    FROM v$parameter 
      WHERE name = 'db_domain';
  
  SELECT database_role 
    INTO database_role 
    FROM v$database;

  IF database_role = 'PRIMARY' THEN
    dbms_service.start_service(rtrim(pdb_name||'_RW.'||db_domain,'.'));
  ELSE
    dbms_service.start_service(rtrim(pdb_name||'_RO.'||db_domain,'.'));
  END IF;
END;
/

SPOOL OFF
