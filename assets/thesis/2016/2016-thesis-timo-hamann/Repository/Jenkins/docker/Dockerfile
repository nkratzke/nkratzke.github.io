FROM jenkins
MAINTAINER Timo Hamann

# Ant konfigurieren
COPY configure_ant.groovy /usr/share/jenkins/ref/init.groovy.d/configure_ant.groovy

# Plugins installieren
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# initiale Konfiguration mit Views setzen
COPY config.xml /usr/share/jenkins/ref/config.xml