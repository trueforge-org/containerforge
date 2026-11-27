#!/usr/bin/env bash

mkdir -p /config

# UNVERIFIED: the system property name for the agent port, and whether Jenkins
# reads JENKINS_SLAVE_AGENT_PORT directly. Confirm on the run.
# shellcheck disable=SC2086
exec java \
    -Djava.io.tmpdir=/tmp \
    -Djenkins.model.Jenkins.slaveAgentPort="${JENKINS_SLAVE_AGENT_PORT:-50000}" \
    ${JAVA_OPTS} \
    -jar /app/jenkins.war \
    --httpPort=8080 \
    --httpListenAddress=0.0.0.0
