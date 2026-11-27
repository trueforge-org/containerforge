#!/usr/bin/env bash

# n8n keeps its config (including the encryption key it generates on first start)
# and its SQLite database in N8N_USER_FOLDER=/config. Nothing is written to /app.
# UNVERIFIED: that n8n writes its encryption key to $N8N_USER_FOLDER/config on first start.
mkdir -p /config
cd /config || exit 1

# UNVERIFIED: `n8n start` is the documented command. Confirm the bind address is 0.0.0.0
# (N8N_LISTEN_ADDRESS default not confirmed) so other containers can reach it.
exec /app/n8n/bin/n8n start
