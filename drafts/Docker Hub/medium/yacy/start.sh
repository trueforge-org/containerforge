#!/usr/bin/env bash

YACY_HOME=/app/yacy_search_server

# DATA is a symlink to /config/DATA; seed it from the shipped defaults, never overwrite
mkdir -p /config/DATA
cp -rn "${YACY_HOME}/DATA-default/." /config/DATA/

# UNVERIFIED: YaCy reads runtime overrides from DATA/SETTINGS/yacy.conf on top of defaults/yacy.init
# UNVERIFIED: an empty adminAccountBase64MD5 may not disable the default admin login; the admin password
# decision is open (see PR notes). The upstream default password "yacy" must not be shipped.
SETTINGS_DIR=/config/DATA/SETTINGS
mkdir -p "${SETTINGS_DIR}"
if [[ ! -s "${SETTINGS_DIR}/yacy.conf" ]]; then
  cat > "${SETTINGS_DIR}/yacy.conf" <<EOF
adminAccountForLocalhost=false
server.https=true
adminAccountBase64MD5=
EOF
fi

# keep JVM temp files out of /config
export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=/tmp"

cd "${YACY_HOME}" || exit 1
exec /bin/sh "${YACY_HOME}/startYACY.sh" -f
