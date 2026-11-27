#!/usr/bin/env bash

# Upstream keeps its data in ~/.openra. HOME=/config maps that to /config/.openra.
mkdir -p /config/.openra/Logs /config/.openra/maps

cd /app/openra
echo "Starting OpenRA dedicated server on port 1234"
# UNVERIFIED: the launcher's path and whether it needs arguments. Upstream's CMD runs it with none.
# UNVERIFIED: the server binds to all interfaces. Check with `ss -ltn` and a connect from outside the container.
exec ./launch-dedicated.sh
