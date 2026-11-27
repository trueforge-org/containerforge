#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Etc/UTC}"
: "${ZM_DB_HOST:=mariadb}"
: "${ZM_DB_NAME:=zm}"
: "${ZM_DB_USER:=zmuser}"
: "${ZM_DB_PASS:=zmpass}"

# ephemeral runtime dirs (apache and zoneminder)
mkdir -p /tmp/apache2/lock /tmp/apache2/log /tmp/zm/log /tmp/zm/socks

# persistent config and event storage, created only when missing
mkdir -p /config/zm/conf.d /config/zm/events /config/zm/images

# seed defaults once, never overwrite existing user config
for src in /usr/share/zoneminder/conf.d-default /defaults/zm.conf.d; do
  [[ -d "${src}" ]] || continue
  for f in "${src}"/*.conf; do
    [[ -e "${f}" ]] || continue
    dst="/config/zm/conf.d/$(basename "${f}")"
    [[ -e "${dst}" ]] || cp "${f}" "${dst}"
  done
done

# DB settings are applied on every start so changing env vars works on existing data.
# The file is mode 600. Values are written with printf, not interpolated into sed.
(
  umask 077
  {
    printf 'ZM_DB_HOST=%s\n' "${ZM_DB_HOST}"
    printf 'ZM_DB_NAME=%s\n' "${ZM_DB_NAME}"
    printf 'ZM_DB_USER=%s\n' "${ZM_DB_USER}"
    printf 'ZM_DB_PASS=%s\n' "${ZM_DB_PASS}"
  } > /config/zm/conf.d/99-env.conf
)

# Background DB init: wait for mariadb, import schema on first run, start zmpkg.
# Apache must keep listening even while the DB is unavailable.
init_zm() {
  local -a db=(-h "${ZM_DB_HOST}" -u "${ZM_DB_USER}")
  until MYSQL_PWD="${ZM_DB_PASS}" mariadb-admin ping --silent "${db[@]}" >/dev/null 2>&1; do
    echo "waiting for database ${ZM_DB_HOST}"
    sleep 5
  done

  if ! MYSQL_PWD="${ZM_DB_PASS}" mariadb "${db[@]}" "${ZM_DB_NAME}" -N -B \
      -e 'SELECT 1 FROM Config LIMIT 1' >/dev/null 2>&1; then
    echo "importing zoneminder schema into ${ZM_DB_NAME}"
    MYSQL_PWD="${ZM_DB_PASS}" mariadb "${db[@]}" "${ZM_DB_NAME}" \
      < /usr/share/zoneminder/db/zm_create.sql
  fi

  # TODO: schema upgrades on version change via zmupdate.pl (UNVERIFIED flags)
  /usr/bin/zmpkg.pl start || echo "zmpkg.pl start failed, see logs"
}
init_zm &

# shellcheck source=/dev/null
source /etc/apache2/envvars
exec apache2 -DFOREGROUND
