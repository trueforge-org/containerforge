#!/usr/bin/env bash
set -eu

# Persistent state lives in /config. Ephemeral state lives in /tmp.
mkdir -p \
    /config/etc \
    /config/home \
    /config/data \
    /tmp/backuppc-run

# TODO: seed defaults into /config/etc with `cp -n` once defaults/ exists (not written yet).
# TODO: point BackupPC's $Conf{TopDir} and the web server config at /config/data and /config/etc (UNVERIFIED keys).
# UNVERIFIED: /etc/supervisord.conf is not in the image yet (etc/ not written). This exec fails until it is added.
exec /usr/bin/supervisord -c /etc/supervisord.conf
