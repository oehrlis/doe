alter lockdown profile p1 disable statement=('ALTER SYSTEM');
alter lockdown profile p1 enable statement=('ALTER SYSTEM') clause=('SET')
  users=common;


alter lockdown profile p1 enable statement=('ALTER SYSTEM') 
  clause=('KILL SESSION');


alter lockdown profile p1 enable statement=('ALTER SYSTEM') clause=('SET')
 option=('APPROX_FOR_AGGREGATION', 
         'APPROX_FOR_COUNT_DISTINCT',
         'APPROX_FOR_PERCENTILE',
         'AWR_PDB_AUTOFLUSH_ENABLED',
         'NLS_LANGUAGE',
         'NLS_TERRITORY',
         'NLS_SORT',
         'NLS_DATE_LANGUAGE',
         'NLS_DATE_FORMAT',
         'NLS_CURRENCY', 
         'NLS_NUMERIC_CHARACTERS', 
         'NLS_ISO_CURRENCY',
         'NLS_CALENDAR',
         'NLS_TIME_FORMAT', 
         'NLS_TIME_TZ_FORMAT',
         'NLS_TIMESTAMP_FORMAT', 
         'NLS_TIMESTAMP_TZ_FORMAT',
         'NLS_DUAL_CURRENCY', 
         'NLS_COMP', 
         'NLS_NCHAR_CONV_EXCP',
         'NLS_LENGTH_SEMANTICS',
         'OPTIMIZER_IGNORE_HINTS',
         'OPTIMIZER_IGNORE_PARALLEL_HINTS',
         'PLSQL_WARNINGS', 
         'PLSQL_OPTIMIZE_LEVEL', 
         'PLSQL_CCFLAGS',
         'PLSQL_DEBUG',
         'PLSCOPE_SETTINGS',
         'FIXED_DATE');


alter lockdown profile p1 disable statement=('ALTER SESSION');
alter lockdown profile p1 enable statement=('ALTER SESSION') clause=('SET')
  users=common;


alter lockdown profile p1 enable statement=('ALTER SESSION') clause=('SET')
 option=('APPROX_FOR_AGGREGATION', 
         'APPROX_FOR_COUNT_DISTINCT',
         'APPROX_FOR_PERCENTILE',
         'CONTAINER',
         'CURRENT_SCHEMA',
         'EDITION',
         'NLS_LANGUAGE',
         'NLS_TERRITORY',
         'NLS_SORT',
         'NLS_DATE_LANGUAGE',
         'NLS_DATE_FORMAT',
         'NLS_CURRENCY', 
         'NLS_NUMERIC_CHARACTERS', 
         'NLS_ISO_CURRENCY',
         'NLS_CALENDAR', 
         'NLS_TIME_FORMAT', 
         'NLS_TIME_TZ_FORMAT',
         'NLS_TIMESTAMP_FORMAT', 
         'NLS_TIMESTAMP_TZ_FORMAT',
         'NLS_DUAL_CURRENCY', 
         'NLS_COMP', 
         'NLS_NCHAR_CONV_EXCP',
         'NLS_LENGTH_SEMANTICS',
         'OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES',
         'OPTIMIZER_IGNORE_HINTS',
         'OPTIMIZER_IGNORE_PARALLEL_HINTS', 
         'PLSQL_WARNINGS', 
         'PLSQL_OPTIMIZE_LEVEL', 
         'PLSQL_CCFLAGS',
         'PLSQL_DEBUG', 
         'PLSCOPE_SETTINGS',
         'ROW ARCHIVAL VISIBILITY = ACTIVE',
         'ROW ARCHIVAL VISIBILITY = ALL',
         'STATISTICS_LEVEL',
         'TIME_ZONE',
         'DEFAULT_COLLATION',
         'ISOLATION_LEVEL = SERIALIZABLE',
         'ISOLATION_LEVEL = READ COMMITTED');

alter lockdown profile p1 enable statement=('ALTER SESSION')
  clause=('ADVISE COMMIT',
          'ADVISE ROLLBACK',
          'ADVISE NOTHING',
          'CLOSE DATABASE LINK',
          'ENABLE COMMIT IN PROCEDURE',
          'DISABLE COMMIT IN PROCEDURE',
          'ENABLE PARALLEL QUERY',
          'ENABLE PARALLEL DDL',
          'ENABLE PARALLEL DML',
          'DISABLE PARALLEL QUERY',
          'DISABLE PARALLEL DDL',
          'DISABLE PARALLEL DML',
          'FORCE PARALLEL QUERY',
          'FORCE PARALLEL DDL',
          'FORCE PARALLEL DML',
          'ENABLE RESUMABLE',
          'DISABLE RESUMABLE');
          
          
alter lockdown profile p1 disable statement=('ALTER PLUGGABLE DATABASE') users=local;
alter lockdown profile p1 enable statement=('ALTER PLUGGABLE DATABASE')
  clause=('DEFAULT EDITION', 'SET TIME_ZONE', 'DATAFILE RESIZE', 
          'DATAFILE AUTOEXTEND ON', 'DATAFILE AUTOEXTEND OFF', 
          'OPEN', 'CLOSE', 'PROPERTY');

alter lockdown profile p1 disable statement=('ALTER DATABASE') users=local;
alter lockdown profile p1 enable statement=('ALTER DATABASE')
  clause=('DEFAULT EDITION', 'SET TIME_ZONE', 'DATAFILE RESIZE', 
          'DATAFILE AUTOEXTEND ON', 'DATAFILE AUTOEXTEND OFF', 
          'OPEN', 'CLOSE', 'PROPERTY');


alter lockdown profile p1 disable statement=('CREATE TABLESPACE') users=local;
alter lockdown profile p1 disable statement=('ALTER TABLESPACE') users=local;
alter lockdown profile p1 disable statement=('DROP TABLESPACE') users=local;

alter lockdown profile p1 disable statement=('ADMINISTER KEY MANAGEMENT') 
  users=local;

alter lockdown profile p1 disable statement=('CREATE DATABASE LINK') 
  users=local;


alter lockdown profile p1 disable statement=('CREATE PROFILE') 
  users=local;
alter lockdown profile p1 disable statement=('ALTER PROFILE') 
  users=local;