#!/usr/bin/env bash


mkdir -p /tmp/davos
exec java -Djava.io.tmpdir="/tmp/davos" -jar /app/davos.jar

