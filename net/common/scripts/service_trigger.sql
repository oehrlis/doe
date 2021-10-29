SPOOL service_trigger.log

COL service_rw NOPRINT NEW_VALUE service_rw
COL service_ro NOPRINT NEW_VALUE service_ro

SELECT rtrim(a.value ||'_RW.'|| b.value,'.') service_rw
FROM v$parameter a, v$parameter b
WHERE a.name  = 'db_name' and b.name = 'db_domain'
;

SELECT rtrim(a.value ||'_RO.'|| b.value,'.') service_ro
FROM v$parameter a, v$parameter b
WHERE a.name  = 'db_name' and b.name = 'db_domain'
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
  db_name       VARCHAR(9);
  db_domain     VARCHAR(128);
  database_role VARCHAR(30);
BEGIN
  SELECT value 
    INTO db_name 
    FROM v$parameter 
      WHERE name = 'db_name';
  
  SELECT value 
    INTO db_domain 
    FROM v$parameter 
      WHERE name = 'db_domain';
  
  SELECT database_role 
    INTO database_role 
    FROM v$database;

  IF database_role = 'PRIMARY' THEN
    dbms_service.start_service(rtrim(db_name||'_RW.'||db_domain,'.'));
  ELSE
    dbms_service.start_service(rtrim(db_name||'_RO.'||db_domain,'.'));
  END IF;
END;
/

CREATE OR REPLACE TRIGGER service_trigger
  after startup on database
DECLARE
  db_name       VARCHAR(9);
  db_domain     VARCHAR(128);
  database_role VARCHAR(30);
BEGIN
  SELECT value 
    INTO db_name 
    FROM v$parameter 
      WHERE name = 'db_name';
  
  SELECT value 
    INTO db_domain 
    FROM v$parameter 
      WHERE name = 'db_domain';
  
  SELECT database_role 
    INTO database_role 
    FROM v$database;

  IF database_role = 'PRIMARY' THEN
    dbms_service.start_service(rtrim(db_name||'_RW.'||db_domain,'.'));
  ELSE
    dbms_service.start_service(rtrim(db_name||'_RO.'||db_domain,'.'));
  END IF;
END;
/

SPOOL OFF
