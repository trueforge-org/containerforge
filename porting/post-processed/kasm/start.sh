#!/usr/bin/env bash


# Create directories
if [[ ! -d "/opt/docker" ]]; then
    mkdir -p /opt/docker
fi

# Workaround for running in a rootless docker environment
sed -i '/set -e/d' /etc/init.d/docker

# Login to Dockerhub
if [[ -n "${DOCKER_HUB_USERNAME}" ]]; then
    docker login --username "${DOCKER_HUB_USERNAME}" --password "${DOCKER_HUB_PASSWORD}"
fi

# Generate self cert for wizard
if [[ ! -f "/opt/kasm/certs/kasm_wizard.crt" ]]; then
    mkdir -p /opt/kasm/certs
    openssl req -x509 -nodes -days 1825 -newkey rsa:2048 \
        -keyout /opt/kasm/certs/kasm_wizard.key \
        -out /opt/kasm/certs/kasm_wizard.crt \
        -subj "/C=US/ST=VA/L=None/O=None/OU=DoFu/CN=$(hostname)/emailAddress=none@none.none"
fi

# Create plugin directory
if [[ ! -L "/var/lib/docker-plugins" ]]; then
    mkdir -p /opt/docker-plugins
    ln -s /opt/docker-plugins /var/lib/docker-plugins
    mkdir -p /var/lib/docker-plugins/rclone/config
    mkdir -p /var/lib/docker-plugins/rclone/cache
fi

_term() {
    if [ -f "/opt/kasm/bin/stop" ]; then
        echo "Caught SIGTERM signal!"
        echo "Stopping Kasm Containers"
        /opt/kasm/bin/stop
        pid=$(pidof stop)
        # terminate when the stop process dies
        tail --pid=${pid} -f /dev/null
    fi
}

## TODO: deal with multiple execs in a single container
exec /usr/local/bin/dockerd-entrypoint.sh -l error --data-root /opt/docker

# Wait for docker to be up
while true; do
    if [[ -S "/var/run/docker.sock" ]]; then
        break
    fi
    sleep 1
done

# Don't do anything if wizard is disabled
if [[ -f "/opt/NO_WIZARD" ]]; then
    sleep infinity
fi

cd /wizard || exit 1
/usr/bin/node index.js

