#!/usr/bin/env bash
set -eu

# Persistent data lives in /config. Ephemeral state (nginx temp files, unix socket, local cache) lives in /tmp.
# /app is read-only at runtime and is never written to.
mkdir -p \
    "${IMAGES_DIR:-/config/images/}" \
    "${CACHE_DIR:-/config/cache/}" \
    "${LOCAL_CACHE_DIR:-/tmp/local_cache/}" \
    /tmp/nginx

# Single-thread and malloc limits from upstream app/entrypoint.sh (commit 9a44956).
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 \
    VECLIB_MAXIMUM_THREADS=1 NUMEXPR_NUM_THREADS=1 \
    MALLOC_MMAP_THRESHOLD_=65536 MALLOC_TRIM_THRESHOLD_=131072

# nginx daemonizes and serves :5000, proxying to uvicorn on /tmp/imgpush.sock.
nginx -c /etc/nginx/imgpush.conf

# UNVERIFIED: whether app.py writes anywhere besides IMAGES_DIR, CACHE_DIR, LOCAL_CACHE_DIR and /tmp.
cd /app/imgpush
exec /app/imgpush-venv/bin/uvicorn app:app \
    --uds /tmp/imgpush.sock \
    --access-log \
    --workers "${WORKERS:-2}" \
    --limit-max-requests 200
