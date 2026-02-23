#!/usr/bin/env bash


export HOME="/tmp"
export APP_URL="${APP_URL:-http://127.0.0.1}"
export API_ENDPOINT="${APP_URL}/api"
export CLIENT_ENDPOINT="${APP_URL}"
export SPOTIFY_PUBLIC="${SPOTIFY_PUBLIC:-dummy_public}"
export SPOTIFY_SECRET="${SPOTIFY_SECRET:-dummy_secret}"

yarn --cwd /app/www/apps/server migrate
cd /app/www/apps/server
exec  yarn start
