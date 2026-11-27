#!/usr/bin/env bash

# Fenrus creates Fenrus.db and its encryption key in data/, which links to /config/data
mkdir -p /config/data

port="${PORT:-3000}"
protocol="${PROTOCOL:-http}"

cd /app/fenrus || exit 1
echo "Starting Fenrus at ${protocol}://+:${port}"
exec dotnet Fenrus.dll --urls="${protocol}://+:${port}"
