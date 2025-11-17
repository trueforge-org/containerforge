#!/usr/bin/env bash

mkdir -p /download
## TODO: likely wont work cleanly
mkdir -p "/run/tomcat.8080"

exec /usr/bin/java -Djava.io.tmpdir="/run/tomcat.8080" -jar /app/davos/davos.jar

