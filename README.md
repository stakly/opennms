# Dockerized OpenNMS 17
This repository contains **Dockerfile** of [OpenNMS](http://www.opennms.org/) for [Docker](https://www.docker.io/)'s [automated build](https://registry.hub.docker.com/u/stakly/opennms/) published to the public [Docker Registry](https://hub.docker.com/).

### Build
```sh
# ./build.sh
```

### Run
1. Start first the dockerized Postgres container
```sh
# docker run --name opennms-database -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

2. Pull the OpenNMS image and run the container linked to the postgres database
```sh
# docker pull stakly/opennms
# docker run --link=opennms-database:db -e DB_POSTGRES_PASSWORD=mysecretpassword --privileged --name opennms -d stakly/opennms
```
