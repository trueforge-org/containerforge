#!/usr/bin/env bash

mkdir -p /config/odoo-data /config/addons

if [[ ! -s /config/odoo.conf ]]; then
    cp /defaults/odoo.conf /config/odoo.conf
fi

if [[ -z "${PG_PASSWORD:-}" ]]; then
    echo "WARNING: PG_PASSWORD is not set; database logins will fail." >&2
else
    # UNVERIFIED: libpq reads PGPASSWORD when odoo passes no db_password. Keeps the secret out of odoo.conf and argv.
    export PGPASSWORD="${PG_PASSWORD}"
fi
export PGHOST="${PG_HOST:-postgresql}"
export PGPORT="${PG_PORT:-5432}"
export PGUSER="${PG_USER:-odoo}"

exec odoo --config /config/odoo.conf
