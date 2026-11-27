#!/usr/bin/env bash

# Flags are assembled from the env vars declared in settings.yaml.
args=(
  "--http-endpoint=:${HTTP_ENDPOINT_PORT:-8080}"
  "--leader-election=${LEADER_ELECTION:-true}"
)
if [[ -n "${LEADER_ELECTION_NAMESPACE:-}" ]]; then
  args+=("--leader-election-namespace=${LEADER_ELECTION_NAMESPACE}")
fi

cd /app/snapshot-controller
exec /app/snapshot-controller/snapshot-controller "${args[@]}"
