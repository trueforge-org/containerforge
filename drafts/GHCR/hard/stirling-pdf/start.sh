#!/bin/sh
set -eu

# Upstream symlinks /app/{configs,customFiles,logs,pipeline,storage} to root-level
# paths. Here the same directories live on the persistent /config volume.
# UNVERIFIED: the JAR resolves these relative to the working directory (/config).
for dir in configs customFiles logs pipeline storage; do
    mkdir -p "/config/${dir}"
done

# Temp and heap dumps stay on the ephemeral /tmp, never on /config.
mkdir -p /tmp/stirling-pdf

cd /config

exec java \
    -XX:+ExitOnOutOfMemoryError \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:HeapDumpPath=/tmp/stirling-pdf \
    -Djava.awt.headless=true \
    -jar /app/Stirling-PDF.jar
