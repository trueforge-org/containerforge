#!/usr/bin/env bash
set -euo pipefail

# Runtime files (pid, mutex, scoreboard) go to /tmp. /etc/apache2 and /var are read-only at runtime.
mkdir -p /tmp/apache-run

# exec so apache2 is PID 1 (tini handoff) and gets signals. -DFOREGROUND keeps it in the foreground.
exec apache2 -DFOREGROUND -f /etc/apache2/apache2.conf
