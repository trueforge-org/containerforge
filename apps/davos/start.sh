#!/usr/bin/env bash



exec java -Djava.io.tmpdir="/run/tomcat.8080" -jar /app/davos/davos.jar

