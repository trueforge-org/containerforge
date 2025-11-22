#!/usr/bin/env bash

set -e

exec /app/watchtower --http-api-metrics $@
