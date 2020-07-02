# Oracle Enterprise User Security

This Docker based Oracle Engineering environment does setup Oracle Enterprise User Security with an Oracle single tenant database or a multitenant database together with Oracle Unified Directory. Optional it is also possible to create a container for an Oracle Unified Directory Services Manager (OUDSM). All together can be used to verify different use cases for enterprise user security, e.g. user and role concept, deployment, troubleshooting, SQLNet customization and much more.

## Requirements

This environment does require the following Docker images.

- Oracle Database 19c (e.g `oracle/database:19.7.0.0`)
- Oracle Unified Directory 12c (e.g `oracle/oud:12.2.1.4.200204`)
- Oracle Unified Directory 12c Services Manager (e.g `oracle/oudsm:12.2.1.4.0`)

Whereby the current environment was explicitly checked with these versions. Other versions are also possible and make sense for testing and engineering work. Due to the license terms, Oracle does not allow to provide pe-build docker images. Therefore these Docker images have to be build manually based on the build scripts provided in the Github repository [oehrlis/docker](https://github.com/oehrlis/docker). A configuration based on the official Oracle Docker images is basically possible, but has not yet been verified. 

Verify the base Docker images for Oracle Database 19c:

```bash
docker images oracle/database:19.7.0.0
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
oracle/database     19.7.0.0            db2cd81e10e3        4 weeks ago         6.88GB
```

Verify the base Docker images for Oracle Unified Directory 12c (OUD and OUDSM):

```bash
docker images oracle/oud*:12.2.1.4.*
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
oracle/oudsm        12.2.1.4.0          7d1e718eebf9        5 weeks ago         2.43GB
oracle/oud          12.2.1.4.200204     511e11292d7c        5 weeks ago         787MB
oracle/oud          12.2.1.4.0          cb368b2dae43        5 weeks ago         785MB
```

## Architecture

The Docker Compose file does setup the following Services:

- **eusoud** A Docker container with Oracle Unified Directory used to store the Oracle Context for Enterprise User Security. 
- **eusdb** A Docker container with a single tenant Oracle Database i.e *ORACLE_SID=TEUS01* including a SCOTT and TVD_HR example schemas.
- **euscdb** A Docker container with a multitenant Oracle Database i.e *ORACLE_SID=TEUS02* with two PDBs including a SCOTT and TVD_HR example schemas.
- **eusoudsm** A Docker container with a OUDSM console.

It is possible to either setup all or just a part of the containers. As a minimum, the OUD container plus a database container must be started. The environment is configured, that the corresponding database instance or directory instance is created on initialization respectively first start. The respective setup scripts are stored in the different configuration directories e.g. [oud/setup](oud/setup) for the OUD instance, [sdb/setup](sdb/setup) for the database instance, etc.

The persistent data of the database and directory container is stored locally in a directory specified by the environment variable `${DOCKER_VOLUME_BASE}`. The default value is set to the project folder. It can be customized by either setting `${DOCKER_VOLUME_BASE}` explicitly or by modifying the [.env](.env) file.

Default settings and configurations:

- Docker container do use an external bridge network *trivadislabs.com* which has to be defined in advanced. e.g. by `docker network create trivadislabs.com`.
- Default domain for all container is *trivadislabs.com*. This can be configured by setting the environment variable `${DOE_LAB_DOMAIN}`.
- Base DN for the Oracle Unified Directory is set do *dc=trivadislabs,dc=com*. Can be configured manually in the OUD setup scripts e.g. `00_init_environment`.
- The OUD directory is populated with a number of standard users based on a Trivadis LAB company. See also [Overview Trivadis LABs](../doc/Overview_Trivadis_LAB.md).

Each Container service has its own setup scripts. The setup scripts are used during initial startup of the container to create the corresponding OUD instance respectively, database or OUDSM domain. The different setup folders are defined in the `docker-compose.yml` file. Below is an overview of the corresponding setup directories.

- [cdb/setup](cdb/setup) Setup folder for the multitenant database. See the [README.md](cdb/setup/README.md) for more information about the different scripts.
- [common](common) Folder for common setup and configuration files. This folder is primarily used to handover the EUS admin account credentials for the database registration.
- [oud/setup](oud/setup) Setup folder for the OUD instance. See the [README.md](oud/setup/README.md) for more information about the different scripts.
- [oudsm/setup](oudsm/setup) Setup folder for the OUDSM domain. It is currently empty as the OUDSM domain is created by the container itself.
- [sdb/setup](sdb/setup) Setup folder for the single tenant database. See the [README.md](sdb/setup/README.md) for more information about the different scripts.

## Setup of Services

### Minimal Setup

For a minimal setup it is required to start the OUD service *eusoud* and at least one database service either *eusdb* or *euscdb*. The following `docker-compose` command creates and starts an OUD and a database.

```bash
docker-compose up -d eusoud eusdb
```

At the first start both the OUD directory and the database are created. Especially creating the database takes a moment depending on the environment. In the corresponding log file you can check when the initial setup is completed.

- Check the OUD container log and look for the information *OUD instance is ready to use:*.

```bash
docker-compose logs -f eusoud
...
eusoud      |  ---------------------------------------------------------------
eusoud      |    OUD instance is ready to use:
eusoud      |    Instance Name      : oud_eus
eusoud      |    Instance Home (ok) : /u01/instances/oud_eus
eusoud      |    Oracle Home        : /u00/app/oracle/product/fmw12.2.1.4.0
eusoud      |    Instance Status    : up
eusoud      |    LDAP Port          : 1389
eusoud      |    LDAPS Port         : 1636
eusoud      |    Admin Port         : 4444
eusoud      |    Replication Port   : 8989
eusoud      |    REST Admin Port    : 8444
eusoud      |    REST http Port     : 1080
eusoud      |    REST https Port    : 1081
eusoud      |  ---------------------------------------------------------------
...
```

- Check the database container log and look for the information *DATABASE TEUS01 IS READY TO USE!*.

```bash
docker-compose logs -f eusdb
...
eusdb       |  ---------------------------------------------------------------
eusdb       | The Oracle base remains unchanged with value /u00/app/oracle
eusdb       |  ---------------------------------------------------------------
eusdb       |  - DATABASE TEUS01 IS READY TO USE!
eusdb       |  ---------------------------------------------------------------
eusdb       | ---------------------------------------------------------------
eusdb       |  - Tail output of alert log from TEUS01:
eusdb       | ---------------------------------------------------------------
...
```

### Individual Service Setup

It is also possible to create and start an individual container e.g. the one for the OUDSM service.

```bash
docker-compose up -d eusoudsm
```

### Setup all Services

When `docker-compose` is used without any service name, all sevices defined in `docker-compose.yml` are started.

```bash
docker-compose up -d
```

Check the log files

```bash
docker-compose logs -f
```

## Use of Services

All services do export a couple of ports for external access. You can check the corresponding ports by using `docker ps` or `docker-compose ps`. 

```bash
user@host:~/doe/eus/ [ic19300] docker-compose ps
  Name    Command                           State        Ports                                        
--------- --------------------------------- ------------ --------------------------------------------------------
euscdb    /bin/sh -c exec ${ORADBA_I ...    Up (healthy) 0.0.0.0:5522->1521/tcp, 5500/tcp
eusdb     /bin/sh -c exec ${ORADBA_I ...    Up (healthy) 0.0.0.0:5521->1521/tcp, 5500/tcp
eusoud    /bin/sh -c exec ${ORADBA_ ...     Up (healthy) 10443/tcp, 1080/tcp, 1081/tcp, 
                                                         0.0.0.0:5389->1389/tcp, 0.0.0.0:5636->1636/tcp
                                                         0.0.0.0:5444->4444/tcp, 8080/tcp,
                                                         8444/tcp, 8989/tcp
eusoudsm  /bin/sh -c exec ${ORADBA_ ...     Up (healthy) 0.0.0.0:5001->7001/tcp, 0.0.0.0:5002->7002/tcp  
```

Afterwards, the respective service can be accessed with the corresponding tool. e.g LDAP browser, SQL Developer, SQLPLus etc.

- Connect to the database service via SQLPLus as user *king* with an easy connect string.

```bash
user@host:~/doe/eus/ [ic19300] sqlplus king/LAB01schulung@localhost:5521/TEUS01

SQL*Plus: Release 19.0.0.0.0 - Production on Thu Jul 2 20:57:04 2020
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Last Successful login time: Wed Jul 01 2020 16:44:51 +02:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> show user
USER is "KING"
```

- Access OUDSM via your favorite web browser [http://localhost:5001/oudsm](http://localhost:5001/oudsm).
- Access OUD via ldapsearch or LDAP browser.

```bash
user@host:~/doe/eus/ [ic19300] ldapsearch -h localhost -p 5389 -D "cn=eusadmin" \
-w manager -b "dc=trivadislabs,dc=com" -s sub "(uid=king)" 

# Ben King, Senior Management, People, trivadislabs.com
dn: cn=Ben King,ou=Senior Management,ou=People,dc=trivadislabs,dc=com
mail: Ben.King@trivadislabs.com
sn: King
cn: Ben King
departmentNumber: 10
objectclass: top
objectclass: organizationalPerson
objectclass: person
objectclass: inetOrgPerson
objectclass: orcluser
objectclass: orcluserv2
givenName: Ben
title: President
userPassword:: e1NTSEF9cDBtVi91WDVsSXVjcHQ4SFRBcEpVQmJ6QU5xOVZ3cjhhSWRBUUE9PQ==
uid: king
displayName: Ben King
```

## Customization

### Basic Customization

The default values for the environment variable are defined in [.env](.env). You can either update the file or define the corresponding environment variable before creating the containers. Alternatively you can also customize [docker-compose.yml](docker-compose.yml).

### Customize Services

You can customize also the different setup and create scripts. See the corresponding readme files.

## Destroy Environment

To destroy the container just run `docker-compose`. This will stop and remove all services.

```bash
docker-compose down
```

Alternatively you can also stop / remove them individually with `docker`.

```bash
docker stop eusoud
docker rm eusoud
```

Be aware, this will only remove the container. The persistent data e.g. data files or OUD instance will remain in `${DOCKER_VOLUME_BASE}`. You can either reuse them the next time you restart the containers or remove them. Keeping them will speed up the setup for the EUS engineering environment the next time.