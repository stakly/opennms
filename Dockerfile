FROM ubuntu:14.04
MAINTAINER Stanislav Lyudvik <root@qw3rty.org>

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV JAVA_HOME=/usr
ENV OPENNMS_HOME=/usr/share/opennms

ENV SKIP_IPLIKE_INSTALL=yes

# Russian repositories
RUN sed -i 's/\(archive\.ubuntu\.com\)/ru.\1/g' /etc/apt/sources.list
RUN apt-get -y update && apt-get -y upgrade

RUN apt-get install -y software-properties-common wget git-core unzip curl openssh-client openssh-server

# Installing Oracle Java
RUN add-apt-repository ppa:webupd8team/java -y && apt-get -y update
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | sudo debconf-set-selections
RUN apt-get install -y oracle-java8-installer oracle-java8-set-default

# Postfix
RUN echo "postfix postfix/mailname string opennms" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -y default-mta

# Installing OpenNMS
RUN add-apt-repository 'deb http://debian.opennms.org opennms-17 main' && \
    wget -O - http://debian.opennms.org/OPENNMS-GPG-KEY | sudo apt-key add - && \
    apt-get update && \
    echo "opennmsdb opennms-db/noinstall string ok" | debconf-set-selections && \
    apt-get -y install opennms

RUN mv /etc/opennms/opennms-datasources.xml /etc/opennms/opennms-datasources.xml.ORIG
COPY opennms-datasources.xml /etc/opennms/
COPY bootstrap.sh /usr/share/opennms/bin/
RUN chmod +x /usr/share/opennms/bin/bootstrap.sh
RUN rm -rf /var/lib/apt/lists/*

# Webapp
EXPOSE 8980 8443
# JMX
EXPOSE 18980
# Karaf RMI
EXPOSE 1099
# Karaf SSH
EXPOSE 8101
# MQ
EXPOSE 61616
# SSH
EXPOSE 1022
# SNMP
EXPOSE 161-162/udp

CMD ["/usr/share/opennms/bin/bootstrap.sh"]

VOLUME  ["/etc/opennms", "/var/lib/opennms"]
