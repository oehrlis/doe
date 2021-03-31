# Engineering Work 2021.03.12

- Create DB Link

```SQL
CREATE PUBLIC DATABASE LINK pdb2 CONNECT TO system IDENTIFIED BY manager USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=secdb.trivadislabs.com)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=PDB2)))';

CREATE PUBLIC DATABASE LINK pdb1 CONNECT TO system IDENTIFIED BY manager USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=secdb.trivadislabs.com)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=PDB1)))';

CREATE PUBLIC DATABASE LINK teus01.trivadislabs.com CONNECT TO system IDENTIFIED BY manager USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=eusdb.trivadislabs.com)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=TEUS01.trivadislabs.com)))';
```

- Test DB Link

```SQL
COL instance_name FOR A20
COL host_name FOR A40
SELECT instance_name,host_name FROM v$instance;

INSTANCE_NAME        HOST_NAME
-------------------- ----------------------------------
TSEC01               secdb.trivadislabs.com

SQL> SELECT instance_name,host_name FROM v$instance@teus01.trivadislabs.com;

INSTANCE_NAME        HOST_NAME
-------------------- ----------------------------------------
TEUS01               eusdb.trivadislabs.com
```

- check lockdown rule

```SQL
COL rule_type FOR A15
COL rule FOR A20
SELECT rule_type, rule, STATUS, USERS FROM v$lockdown_rules WHERE rule LIKE '%NET%';

RULE_TYPE       RULE                 STATUS  USERS
--------------- -------------------- ------- ------
FEATURE         NETWORK_ACCESS       DISABLE ALL
```
