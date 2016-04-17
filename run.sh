#!/bin/bash
docker run --name opennms-database -e POSTGRES_PASSWORD=mAAAster -d postgres
docker run -it --link=opennms-database:db -e DB_POSTGRES_PASSWORD=mAAAster --privileged --name opennms-17 stakly/opennms
