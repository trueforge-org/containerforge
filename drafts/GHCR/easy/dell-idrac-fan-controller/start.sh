#!/usr/bin/env bash

# Upstream reads its settings from the environment, so this only changes directory and hands off.
cd /app || exit 1
exec ./supervisor.sh
