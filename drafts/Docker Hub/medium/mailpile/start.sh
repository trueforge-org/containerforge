#!/usr/bin/env bash
set -euo pipefail

# Only the GnuPG home is created here. Mailpile state goes to /config via HOME=/config.
mkdir -p /config/gnupg
chmod 700 /config/gnupg

cd /app/mailpile
# UNVERIFIED: ./mp must run under /app/venv/bin/python (its shebang may point at Python 2).
exec /app/venv/bin/python ./mp --www=0.0.0.0:33411 --wait
