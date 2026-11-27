#!/usr/bin/env bash
set -eu

umask "${UMASK:-002}"

# Keychain state lives under /config (GNUPGHOME and PASSWORD_STORE_DIR are set in the Dockerfile)
mkdir -p /config/.gnupg /config/.password-store
chmod 700 /config/.gnupg

# Create the GPG key once, on first start. Never overwrite an existing key.
# UNVERIFIED: defaults/gpgparams is a draft; upstream entrypoint.sh has not been read yet
if ! gpg --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec'; then
  gpg --batch --gen-key /defaults/gpgparams
fi

# Initialise the password store once, on first start
if [ ! -f /config/.password-store/.gpg-id ]; then
  KEY_ID="$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr/ {print $10; exit}')"
  pass init "${KEY_ID}"
fi

# UNVERIFIED: bridge mode flag and listen addresses come from upstream entrypoint.sh (not read yet).
# The bridge must listen on 0.0.0.0 to be reachable from other containers.
exec /app/protonmail-bridge/proton-bridge --noninteractive
