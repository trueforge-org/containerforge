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

# Without a password, nothing but this container can connect
if [[ -n "${CLICKHOUSE_PASSWORD:-}" ]]; then
    password='<password from_env="CLICKHOUSE_PASSWORD"/>'
    export CLICKHOUSE_LISTEN_HOST="::"
    export CLICKHOUSE_LISTEN_HOST_IPV4="0.0.0.0"
else
    echo "CLICKHOUSE_PASSWORD is not set: ClickHouse only listens on localhost"
    password='<password></password>'
    export CLICKHOUSE_LISTEN_HOST="::1"
    export CLICKHOUSE_LISTEN_HOST_IPV4="127.0.0.1"
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
            <networks><ip>::/0</ip></networks>
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
