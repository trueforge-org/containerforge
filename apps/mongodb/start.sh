#!/usr/bin/env bash

DATADIR="/config/db"
mkdir -p "${DATADIR}"

# Without a root password, no user is created. MongoDB listens on all interfaces with
# authentication on, so remote clients can connect but cannot run anything, and only
# connections from localhost may create the first user (localhost exception)
if [[ -z "${MONGODB_ROOT_PASSWORD:-}" ]]; then
    echo "MONGODB_ROOT_PASSWORD is not set: authentication is on without users, so only localhost can create a user"
    exec mongod --dbpath "${DATADIR}" --bind_ip_all --auth
fi

# Apply the users on every start, so changing a password also works on existing data
# During this, authentication is off and MongoDB only listens on localhost
mongod --dbpath "${DATADIR}" --bind_ip 127.0.0.1 --noauth >/dev/null &
setup_pid="$!"

until mongosh --quiet --norc --host 127.0.0.1 --eval 'db.runCommand({ ping: 1 })' >/dev/null 2>&1; do
    if ! kill -0 "${setup_pid}" 2>/dev/null; then
        echo "MongoDB stopped during setup"
        exit 1
    fi
    sleep 1
done

if ! mongosh --quiet --norc --host 127.0.0.1 /scripts/setup-users.js; then
    echo "Setting up the MongoDB users failed"
    kill "${setup_pid}"
    wait "${setup_pid}"
    exit 1
fi

kill "${setup_pid}"
wait "${setup_pid}"

exec mongod --dbpath "${DATADIR}" --bind_ip_all --auth
