#!/bin/bash

OPENNMS_HOME=/usr/share/opennms

if [ ! -d ${OPENNMS_HOME} ]; then
	echo "OpenNMS home directory doesn't exist in ${OPENNMS_HOME}"
	exit 1
fi

if [ -z "$DB_PORT_5432_TCP" ]; then
	echo >&2 'error: missing DB_PORT_5432_TCP environment variable'
	echo >&2 ' Use --link some_postgres_container:postgres'
	exit 1
fi

if [ -z "$DB_POSTGRES_PASSWORD" ]; then
	echo >&2 'error: missing DB_POSTGRES_PASSWORD environment variable'
	echo >&2 '  Use -e DB_POSTGRES_PASSWORD=mysecretpassword'
	exit 1
fi
if ! [ -e .opennms_inited ]; then
	sed -i s/PG_HOST/$DB_PORT_5432_TCP_ADDR/g $OPENNMS_HOME/etc/opennms-datasources.xml
	sed -i s/PG_PORT/$DB_PORT_5432_TCP_PORT/g $OPENNMS_HOME/etc/opennms-datasources.xml
	sed -i s/PG_PASSWORD/$DB_POSTGRES_PASSWORD/g $OPENNMS_HOME/etc/opennms-datasources.xml

	# Expose the Karaf shell
	sed -i s/sshHost.*/sshHost=0.0.0.0/g "${OPENNMS_HOME}/etc/org.apache.karaf.shell.cfg"

	#cd ${OPENNMS_HOME}/bin
	${OPENNMS_HOME}/bin/runjava -s
	${OPENNMS_HOME}/bin/install -dis
	if [ $? -eq 0 ]; then
		#PGPASSWORD=$DB_POSTGRES_PASSWORD /usr/sbin/install_iplike.sh -x $DB_PORT_5432_TCP_ADDR -p $DB_PORT_5432_TCP_PORT
		touch .opennms_inited
	else
		echo >&2 'error: opennms installation failed'
		exit 1
	fi
fi

${OPENNMS_HOME}/bin/opennms -f start
