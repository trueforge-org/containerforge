#!/usr/bin/env bash
set -euo pipefail

# PWM configuration persists in /config/pwm. Tomcat logs, work and temp dirs are symlinked into /tmp.
mkdir -p /config/pwm /tmp/tomcat/logs /tmp/tomcat/work /tmp/tomcat/temp

# UNVERIFIED: whether pwm needs a configuration password on every start (plan section 7). If it does, read it from an env var named in the pwm docs, not invented here.
export CATALINA_TMPDIR=/tmp

exec /app/tomcat/bin/catalina.sh run
