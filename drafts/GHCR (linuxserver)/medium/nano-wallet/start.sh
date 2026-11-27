#!/usr/bin/env bash
set -euo pipefail

# Nothing to seed: the wallet is client-side and nginx config is read-only under /etc.
# /tmp is an empty tmpfs under --read-only, so create the nginx temp dirs on each start.
mkdir -p /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi

exec nginx -c /etc/nano-wallet/nginx.conf -g "daemon off;"
