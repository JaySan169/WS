#!/bin/sh

wget http://www.eu.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz
tar xzf apache-maven-3.5.0-bin.tar.gz
mkdir /opt/maven
mv apache-maven-3.5.0/ /opt/maven/
alternatives --install /usr/bin/mvn mvn /opt/maven/apache-maven-3.5.0/bin/mvn 1
alternatives --config mvn