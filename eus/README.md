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

The persistant data of the database and directory container is stored locally in a directory specified by the environment variable `${DOCKER_VOLUME_BASE}`. The default value is set to the project folder. It can be customized by either setting `${DOCKER_VOLUME_BASE}` explicitly or by modifying the [.env](.env) file.

## Setup of Services

### Minimal Setup

```bash
docker-compose up -d eusoud eusdb
```

### Individual Service Setup

```bash
docker-compose up -d eusoudsm
```

### Setup all Services

```bash
docker-compose up -d
```

## Use of Services

```bash
soe@gaia:~/Development/github.com/oehrlis/doe/eus/ [ic19300] docker-compose ps
  Name                Command                  State       Ports                                        
-----------------------------------------------------------------------------------------------------------------
euscdb     /bin/sh -c exec ${ORADBA_I ...   Up (healthy)   0.0.0.0:5522->1521/tcp, 5500/tcp
eusdb      /bin/sh -c exec ${ORADBA_I ...   Up (healthy)   0.0.0.0:5521->1521/tcp, 5500/tcp
eusoud     /bin/sh -c exec "${ORADBA_ ...   Up (healthy)   10443/tcp, 1080/tcp, 1081/tcp, 0.0.0.0:5389->1389/tcp, 
                                                           0.0.0.0:5636->1636/tcp 0.0.0.0:5444->4444/tcp, 
                                                           8080/tcp, 8444/tcp, 8989/tcp
eusoudsm   /bin/sh -c exec "${ORADBA_ ...   Up (healthy)   0.0.0.0:5001->7001/tcp, 0.0.0.0:5002->7002/tcp  
```

## Customization

### Basic Customization

### Customize Services

## Destroy Environment

