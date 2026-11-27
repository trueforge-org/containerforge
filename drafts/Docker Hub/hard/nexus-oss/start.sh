#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/etc /config/log /config/javaprefs

# NEXUS_CONTEXT sets the context path. Only that key is rewritten, other settings are kept.
if [[ -n "${NEXUS_CONTEXT:-}" ]]; then
  touch /config/etc/nexus.properties
  grep -v '^nexus-context-path=' /config/etc/nexus.properties > /tmp/nexus.properties.new || true
  printf 'nexus-context-path=/%s\n' "${NEXUS_CONTEXT#/}" >> /tmp/nexus.properties.new
  cat /tmp/nexus.properties.new > /config/etc/nexus.properties
  rm -f /tmp/nexus.properties.new
fi

# Later -D flags win over bin/nexus.vmoptions. Temp files and the JVM log go to /tmp.
# UNVERIFIED: that the install4j launcher honours this precedence; check the first run.
export INSTALL4J_ADD_VM_PARAMS="${INSTALL4J_ADD_VM_PARAMS:--Xms1g -Xmx2g} -Djava.io.tmpdir=/tmp -XX:LogFile=/tmp/jvm.log -Djava.util.prefs.userRoot=/config/javaprefs"

cd /app/nexus
exec /app/nexus/bin/nexus run
