# DOE - Docker based Oracle Engineering

This repository contains *Docker-based Oracle Engineering* environments and sample setups for testing various Oracle features and use cases. For the setup of the different environments appropriate Oracle Docker images are required. These images have to be created in advance based on the *unofficial* build scripts from [oehrlis/docker](https://github.com/oehrlis/docker) or based on the official [Oracle Docker images](https://github.com/oracle/docker-images). Which images are required is described in the corresponding Use Case.

Currently the following environment and use cases are covered:

- [**eus - Oracle Enterprise User Security**](eus)  Environment with Oracle Database 19c and Oracle Unified Directory 12c. This Setup does include 4 Docker containers for Oracle Database 19c single tenant, Oracle Database 19c multi tenant, Oracle Unified Directory as well an Oracle Unified Directory Service Manager.

The following environments and use cases are planned or still in progress:

- [audit](audit) Oracle Databases with Oracle Unified Audit
- [cmu](cmu) Oracle Database 19c with centrally managed users and MS Active Directory integration. The MS Active Directory is not part of this project and must be built separately according to [oehrlis/docker](https://github.com/oehrlis/trivadislabs.com).
- [eusad](eusad) Oracle Enterprise User Security Environment with an Oracle Unified Directory AD Proxy. The MS Active Directory is not part of this project and must be built separately according to [oehrlis/docker](https://github.com/oehrlis/trivadislabs.com).

## Pre-built Images with Commercial Software

Due to the licensing conditions of Oracle there are no pre-built images with commercial software available. Nevertheless the Dockerfiles in this repository depend on Oracle Linux image with is either available via [Oracle Container Registry](https://container-registry.oracle.com) server or on the [Docker Store](https://store.docker.com/search?certification_status=certified&q=oracle&source=verified&type=image).

## Support

There is no official support for the Dockerfiles and build scripts within this repository. They basically are provided as they are. Nevertheless, a [GitHub issue](https://github.com/oehrlis/doe/issues) can be opened for questions and problems around the Dockerfiles and build script.

For support and certification information, please consult the documentation for each product. eg. [Oracle Unified Directory 12.2.1.3.0](https://https://docs.oracle.com/middleware/12213/oud/docs.htm) and [Oracle Directory Server Enterprise Edition](https://docs.oracle.com/cd/E29127_01/index.htm) Alternatiely you may visit the [OTN Community OUD & ODSEE Space](https://community.oracle.com/community/fusion_middleware/identity_management/oracle_directory_server_enterprise_edition_sun_dsee) to get community support. Official Oracle product support is available through [My Oracle Support](https://support.oracle.com/). 

## License

To download and run Oracle Database, Oracle Unified Directory, Oracle Directory Server Enterprise Edition and Oracle JDK, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.
