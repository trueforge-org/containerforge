#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

# Seed the config only when it is missing, so user edits are kept.
cp -n /defaults/nitter.conf /config/nitter.conf

# /app is read-only at runtime. Build a scratch run directory in /tmp that links to the read-only app files and the /config config.
# UNVERIFIED: that nitter reads nitter.conf and public/ from its working directory. If it takes a flag instead, use that.
run_dir=/tmp/nitter-run
rm -rf "${run_dir}"
mkdir -p "${run_dir}"
ln -s /app/nitter/nitter "${run_dir}/nitter"
ln -s /app/nitter/public "${run_dir}/public"
ln -s /config/nitter.conf "${run_dir}/nitter.conf"

cd "${run_dir}"
exec ./nitter "$@"
