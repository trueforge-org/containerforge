#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

ARK_APPID=376030
ARK_ROOT=/config/server
CFG=/config/.arkmanager.cfg

mkdir -p \
  "${ARK_ROOT}" \
  /config/backup \
  /config/staging \
  /config/log \
  /config/arkmanager \
  /config/Steam/steamcmd/linux32 \
  /tmp/arktools

# Seed SteamCMD into /config once, as the steamcmd base does.
if [ ! -f /config/Steam/steamcmd/steamcmd.sh ]; then
  if [ -f /usr/local/share/steamcmd/steamcmd.sh ]; then
    cp /usr/local/share/steamcmd/steamcmd.sh /config/Steam/steamcmd/
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
      cp /usr/local/share/steamcmd/linux32/steamcmd /config/Steam/steamcmd/linux32/
    fi
  else
    echo "Error: steamcmd.sh not found in /usr/local/share/steamcmd." >&2
    exit 1
  fi
fi

# Quote a value for a shell-sourced arkmanager config (escape \ " $ and backtick).
quote() {
  local v="$1"
  v="${v//\\/\\\\}"
  v="${v//\"/\\\"}"
  v="${v//\$/\\\$}"
  v="${v//\`/\\\`}"
  printf '"%s"' "$v"
}

# Admin password: use the env value, or generate one once and reuse it on later starts.
if [ -z "${am_ark_ServerAdminPassword:-}" ]; then
  if [ ! -s /config/arkmanager/admin_password ]; then
    (umask 077; od -An -N12 -tx1 /dev/urandom | tr -d ' \n' > /config/arkmanager/admin_password)
  fi
  am_ark_ServerAdminPassword="$(cat /config/arkmanager/admin_password)"
  export am_ark_ServerAdminPassword
  echo "[arksurvivalevolved] No admin password set: see /config/arkmanager/admin_password" >&2
fi

# Build the user config on every start. Umask keeps the password file private.
(
  umask 077
  cat /defaults/arkmanager.cfg
  printf 'arkserverroot=%s\n' "$(quote "${ARK_ROOT}")"
  printf 'arkbackupdir=%s\n' "$(quote /config/backup)"
  printf 'arkStagingDir=%s\n' "$(quote /config/staging)"
  printf 'steamcmd_appinfocache=%s\n' "$(quote /config/Steam/appinfocache.bin)"
  printf 'steamcmd_workshoplog=%s\n' "$(quote /config/Steam/workshop.log)"
  # Pass every am_* variable through, stripping the am_ prefix (as upstream run.sh does).
  while IFS= read -r name; do
    key="${name#am_}"
    [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
    printf '%s=%s\n' "$key" "$(quote "${!name}")"
  done < <(compgen -e | grep '^am_' || true)
) > "${CFG}.tmp"
mv "${CFG}.tmp" "${CFG}"

# Install on first start, or update when requested. A failed install stops the script.
if [ ! -f "${ARK_ROOT}/steamapps/appmanifest_${ARK_APPID}.acf" ]; then
  arkmanager install
elif [ "${am_arkAutoUpdateOnStart:-false}" = "true" ]; then
  arkmanager update --force --no-autostart
fi

# Remove stale lock and pid files left by an unclean stop.
find "${ARK_ROOT}/ShooterGame/Saved" -maxdepth 2 \( -name '*.lock' -o -name '*.pid' \) -delete 2>/dev/null || true

# arkmanager runs the server in the foreground; forward TERM/INT/QUIT to a graceful stop (world save).
arkmanager start --no-background --verbose &
pid=$!
trap 'arkmanager stop || true; wait "$pid" || true' TERM INT QUIT
wait "$pid"
