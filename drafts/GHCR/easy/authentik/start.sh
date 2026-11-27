#!/usr/bin/env bash
set -euo pipefail

export TMPDIR=/tmp

# Stateless outpost: nothing to seed. Its config comes from the environment.
# UNVERIFIED: the env names for the server URL and token are not confirmed (see settings.yaml).
# UNVERIFIED: the listen address. Check the log for the 3389 bind, and check reachability from another container.
exec /app/ldap
