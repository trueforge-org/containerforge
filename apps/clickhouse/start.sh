#!/usr/bin/env bash

CLICKHOUSE_USER="${CLICKHOUSE_USER:-default}"
CLICKHOUSE_DB="${CLICKHOUSE_DB:-default}"

# These end up in XML and SQL, so only allow what needs no escaping
for value in "${CLICKHOUSE_USER}" "${CLICKHOUSE_DB}"; do
    if [[ ! "${value}" =~ ^[A-Za-z0-9_]+$ ]]; then
        echo "CLICKHOUSE_USER and CLICKHOUSE_DB can only contain letters, numbers and underscores"
        exit 1
    fi
done

# The server always listens on all interfaces, so the published ports are reachable
# Without a password, the user only accepts connections from inside this container
export CLICKHOUSE_LISTEN_HOST="::"
export CLICKHOUSE_LISTEN_HOST_IPV4="0.0.0.0"
if [[ -n "${CLICKHOUSE_PASSWORD:-}" ]]; then
    password='<password from_env="CLICKHOUSE_PASSWORD"/>'
    networks='<ip>::/0</ip>'
else
    echo "CLICKHOUSE_PASSWORD is not set: the user [${CLICKHOUSE_USER}] only accepts connections from localhost"
    password='<password></password>'
    networks='<ip>::1</ip><ip>127.0.0.1</ip>'
fi

# Written on every start, so changes also apply to existing data
# The password is read from the environment, so it stays out of this file
cat >/config/users.xml <<EOXML
<clickhouse>
    <profiles>
        <default/>
    </profiles>
    <users>
        <${CLICKHOUSE_USER}>
            ${password}
            <networks>${networks}</networks>
            <profile>default</profile>
            <quota>default</quota>
            <access_management>${CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT:-0}</access_management>
        </${CLICKHOUSE_USER}>
    </users>
    <quotas>
        <default/>
    </quotas>
</clickhouse>
EOXML

# Create the database once the server is up, and stop the server if that fails
# The server replaces this script below, so it receives the signals of the container directly
(
    until clickhouse client --query "SELECT 1" >/dev/null 2>&1; do
        sleep 1
    done
    if ! clickhouse client --query "CREATE DATABASE IF NOT EXISTS \`${CLICKHOUSE_DB}\`"; then
        echo "Creating the database [${CLICKHOUSE_DB}] failed"
        kill -TERM "$$"
    fi
) &

exec clickhouse server --config-file=/etc/clickhouse-server/config.xml
