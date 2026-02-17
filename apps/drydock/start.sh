#!/usr/bin/env bash
set -e

# ── Privilege-drop logic (runs only on first invocation as root) ──
if [ "$(id -u)" = "0" ]; then
	# Allow opting out of privilege drop for :ro socket compatibility
	if [ "${DD_RUN_AS_ROOT}" = "true" ]; then
		echo "DD_RUN_AS_ROOT is set — skipping privilege drop (running as root)"
	elif [ -S /var/run/docker.sock ]; then
		DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
		if [ "$DOCKER_GID" != "0" ]; then
			# Non-root GID (e.g. Linux docker group): add apps to socket group, drop to apps
			EXISTING_GROUP=$(getent group "$DOCKER_GID" | cut -d: -f1)
			if [ -n "$EXISTING_GROUP" ]; then
				usermod -aG "$EXISTING_GROUP" apps 2>/dev/null || true
			else
				groupadd -g "$DOCKER_GID" docker 2>/dev/null || true
				usermod -aG docker apps 2>/dev/null || true
			fi
			exec gosu apps "$0" "$@"
		fi
		# GID is 0 (Docker Desktop / OrbStack): stay as root — matches Portainer/Watchtower/Dozzle
	else
		# No socket mounted: drop to apps
		exec gosu apps "$0" "$@"
	fi
fi

# ── Application start ──
# if the first argument starts with `-`, prepend `node dist/index`
if [[ ${1#-} != "$1" ]]; then
	set -- node dist/index "$@"
fi

if [[ $1 == "node" ]] && [[ $2 == dist/index* ]] && [[ ${DD_LOG_FORMAT} != "json" ]]; then
	exec "$@" | ./node_modules/.bin/pino-pretty
else
	exec "$@"
fi
