#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CONFIG_HOME=/config/.config
export XDG_DATA_HOME=/config/.local/share

GAME_DIR=/config/gamefiles
SAVES_DIR=/config/saved
BACKUP_DIR=/config/backups
STEAMCMD_DIR=/config/Steam/steamcmd
SAVEGAMES_LINK=/config/.config/Epic/FactoryGame/Saved/SaveGames
GAME_APP_ID=1690800

mkdir -p "$GAME_DIR" "$SAVES_DIR" "$BACKUP_DIR" /config/logs/steam \
  /config/.config/Epic/FactoryGame/Saved

# seed SteamCMD into /config only when missing
if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
  mkdir -p "$STEAMCMD_DIR/linux32"
  cp /usr/local/share/steamcmd/steamcmd.sh "$STEAMCMD_DIR/"
  if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
    cp /usr/local/share/steamcmd/linux32/steamcmd "$STEAMCMD_DIR/linux32/"
  fi
fi

# saves: point the server's SaveGames directory at /config/saved
if [ -d "$SAVEGAMES_LINK" ] && [ ! -L "$SAVEGAMES_LINK" ]; then
  if [ -n "$(ls -A "$SAVEGAMES_LINK")" ]; then
    backup="$BACKUP_DIR/SaveGames-$(date +%Y%m%d%H%M%S)"
    cp -a "$SAVEGAMES_LINK" "$backup"
    if [ -z "$(ls -A "$SAVES_DIR")" ]; then
      cp -a "$SAVEGAMES_LINK"/. "$SAVES_DIR"/
    fi
  fi
  rm -rf "$SAVEGAMES_LINK"
fi
ln -sfn "$SAVES_DIR" "$SAVEGAMES_LINK"

# numeric settings: fall back to the default when the value is not a number
num() {
  if [[ "$2" =~ ^[0-9]+$ ]]; then
    echo "$2"
  else
    echo "satisfactory: $1 must be numeric, using $3" >&2
    echo "$3"
  fi
}
SERVERGAMEPORT="$(num SERVERGAMEPORT "${SERVERGAMEPORT:-7777}" 7777)"
SERVERMESSAGINGPORT="$(num SERVERMESSAGINGPORT "${SERVERMESSAGINGPORT:-8888}" 8888)"
MAXPLAYERS="$(num MAXPLAYERS "${MAXPLAYERS:-4}" 4)"
MAXTICKRATE="$(num MAXTICKRATE "${MAXTICKRATE:-30}" 30)"
MAXOBJECTS="$(num MAXOBJECTS "${MAXOBJECTS:-2162688}" 2162688)"
AUTOSAVENUM="$(num AUTOSAVENUM "${AUTOSAVENUM:-5}" 5)"
TIMEOUT="$(num TIMEOUT "${TIMEOUT:-30}" 30)"

# update on every start unless SKIPUPDATE=true, and always when the game is missing
if [ "${SKIPUPDATE:-false}" != "true" ] || [ ! -f "$GAME_DIR/FactoryServer.sh" ]; then
  free_gb=$(df -Pk /config | awk 'NR==2 {print int($4 / 1024 / 1024)}')
  if [ "$free_gb" -lt 8 ]; then
    echo "satisfactory: warning, only ${free_gb} GB free in /config; the server needs about 8 GB" >&2
  fi

  # branch: STEAMBETAID wins, else STEAMBETA=true means experimental, else public
  beta_args=""
  if [ -n "${STEAMBETAID:-}" ]; then
    beta_args="-beta ${STEAMBETAID}"
    [ -n "${STEAMBETAKEY:-}" ] && beta_args="${beta_args} -betapassword ${STEAMBETAKEY}"
  elif [ "${STEAMBETA:-false}" = "true" ]; then
    beta_args="-beta experimental"
  fi

  # the script file keeps the beta key out of the process list and the log
  script="$(mktemp /tmp/steamcmd.XXXXXX)"
  chmod 600 "$script"
  {
    echo "@ShutdownOnFailedCommand 1"
    echo "login anonymous"
    echo "force_install_dir $GAME_DIR"
    echo "app_update $GAME_APP_ID $beta_args validate"
    echo "quit"
  } > "$script"
  rc=0
  "$STEAMCMD_DIR/steamcmd.sh" +runscript "$script" || rc=$?
  rm -f "$script"
  if [ "$rc" -ne 0 ]; then
    if [ -f "$GAME_DIR/FactoryServer.sh" ]; then
      echo "satisfactory: update failed (exit $rc), starting the installed version" >&2
    else
      echo "satisfactory: download failed (exit $rc) and no installed server found" >&2
      exit 1
    fi
  fi
fi

cd "$GAME_DIR"
chmod +x FactoryServer.sh

ini_args=(
  "-ini:Engine:[/Script/FactoryGame.FGSaveSession]:mNumRotatingAutosaves=$AUTOSAVENUM"
  "-ini:Engine:[/Script/Engine.GarbageCollectionSettings]:gc.MaxObjectsInEditor=$MAXOBJECTS"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:LanServerMaxTickRate=$MAXTICKRATE"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:NetServerMaxTickRate=$MAXTICKRATE"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:ConnectionTimeout=$TIMEOUT"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:InitialConnectTimeout=$TIMEOUT"
  "-ini:Engine:[ConsoleVariables]:wp.Runtime.EnableServerStreaming=$([ "${SERVERSTREAMING:-true}" = "true" ] && echo 1 || echo 0)"
  "-ini:Game:[/Script/Engine.GameSession]:ConnectionTimeout=$TIMEOUT"
  "-ini:Game:[/Script/Engine.GameSession]:InitialConnectTimeout=$TIMEOUT"
  "-ini:Game:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS"
  "-ini:GameUserSettings:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS"
)

extra_args=()
if [ "${DISABLESEASONALEVENTS:-false}" = "true" ]; then
  extra_args+=("-DisableSeasonalEvents")
fi
if [ -n "${MULTIHOME:-}" ]; then
  extra_args+=("-multihome=${MULTIHOME}")
fi

exec ./FactoryServer.sh \
  -Port="$SERVERGAMEPORT" \
  -ReliablePort="$SERVERMESSAGINGPORT" \
  -ExternalReliablePort="$SERVERMESSAGINGPORT" \
  "${ini_args[@]}" \
  "${extra_args[@]}"
