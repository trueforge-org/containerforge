#!/usr/bin/env bash
set -euo pipefail

# Persistent XWiki permanent directory.
PERM_DIR=/config/xwiki
# Tomcat runs from an ephemeral CATALINA_BASE in /tmp. The XWiki configure step writes into
# WEB-INF, and the image rootfs is read-only, so the webapp is copied to /tmp on every start.
TOMCAT_BASE=/tmp/xwiki-tomcat
TMP_DIR=/tmp/xwiki-tmp
TEMPLATE_DIR=/defaults

DB_USER="${DB_USER:-xwiki}"
DB_PASSWORD="${DB_PASSWORD:-xwiki}"
DB_DATABASE="${DB_DATABASE:-xwiki}"
DB_HOST="${DB_HOST:-postgresql}"
DB_PORT="${DB_PORT:-5432}"
JDBC_PARAMS="${JDBC_PARAMS:-}"
CONTEXT_PATH="${CONTEXT_PATH:-ROOT}"
CONTEXT_PATH="${CONTEXT_PATH#/}"
CONTEXT_PATH="${CONTEXT_PATH:-ROOT}"

# Escape the characters that are special in XML text.
xml_escape() {
    local s="$1"
    s="${s//&/"&amp;"}"
    s="${s//</"&lt;"}"
    s="${s//>/"&gt;"}"
    s="${s//\"/"&quot;"}"
    printf '%s' "$s"
}

# Set key=value in a Java properties file, replacing an existing line.
set_property() {
    local file="$1" key="$2" value="$3"
    touch "${file}"
    { grep -v "^${key}=" "${file}" || true; printf '%s=%s\n' "${key}" "${value}"; } > "${file}.tmp"
    mv "${file}.tmp" "${file}"
}

mkdir -p "${PERM_DIR}/data"
rm -rf "${TOMCAT_BASE}" "${TMP_DIR}"
mkdir -p "${TOMCAT_BASE}/webapps" "${TOMCAT_BASE}/logs" "${TOMCAT_BASE}/temp" "${TOMCAT_BASE}/work" "${TMP_DIR}"
cp -a /usr/local/tomcat/conf "${TOMCAT_BASE}/conf"

WEBAPP="${TOMCAT_BASE}/webapps/${CONTEXT_PATH}"
WEB_INF="${WEBAPP}/WEB-INF"
cp -a /usr/local/tomcat/webapps-src/ROOT "${WEBAPP}"

# Restore the saved XWiki configuration from the persistent directory, if present.
for file in xwiki.cfg xwiki.properties; do
    if [[ -s "${PERM_DIR}/${file}" ]]; then
        cp "${PERM_DIR}/${file}" "${WEB_INF}/${file}"
    fi
done

set_property "${WEB_INF}/xwiki.properties" environment.permanentDirectory "${PERM_DIR}/data"
set_property "${WEB_INF}/xwiki.cfg" environment.permanentDirectory "${PERM_DIR}/data"

# Render the database connection from the template. The password stays in shell variables,
# so it never appears in the process list.
DB_HOST_VALUE="${DB_HOST}:${DB_PORT}"
DB_PARAMS="${JDBC_PARAMS}"
if [[ -n "${DB_PARAMS}" && "${DB_PARAMS}" != \?* ]]; then
    DB_PARAMS="?${DB_PARAMS}"
fi

content="$(<"${TEMPLATE_DIR}/hibernate.cfg.xml")"
content="${content//replacecontainer/"$(xml_escape "${DB_HOST_VALUE}")"}"
content="${content//replacedatabasereplacejdbcparams/"$(xml_escape "${DB_DATABASE}${DB_PARAMS}")"}"
content="${content//replaceuser/"$(xml_escape "${DB_USER}")"}"
content="${content//replacepassword/"$(xml_escape "${DB_PASSWORD}")"}"
printf '%s\n' "${content}" > "${WEB_INF}/hibernate.cfg.xml"
unset content DB_PASSWORD

# Tomcat binds to all interfaces by default and listens on 8080.
export CATALINA_BASE="${TOMCAT_BASE}"
export CATALINA_TMPDIR="${TMP_DIR}"
export CATALINA_OPTS="-Xmx1024m -Djava.io.tmpdir=${TMP_DIR} -Dfile.encoding=UTF-8"

cd "${TOMCAT_BASE}"
exec /usr/local/tomcat/bin/catalina.sh run
