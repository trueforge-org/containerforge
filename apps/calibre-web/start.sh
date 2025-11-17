#!/usr/bin/env bash

# create Google drive client_secrets.json file
if [[ ! -f /config/client_secrets.json ]]; then
    echo "{}" > /config/client_secrets.json
fi

# check if kepubify is present and if so make executable
if [[ -f /usr/bin/kepubify ]] && [[ ! -x /usr/bin/kepubify ]]; then
    chmod +x /usr/bin/kepubify
fi

# Pre-stage some files & directories for permissions purposes
mkdir -p /app/calibre-web/cps/cache

export CALIBRE_DBPATH=/config

if [[ ! -f /config/app.db ]]; then
  echo "First time run, creating app.db..."
  cd /app/calibre-web &&  python3 /app/calibre-web/cps.py -d > /dev/null 2>&1
  # handle app.db updates for kepubify and ext binary path
  # borrowed from crocodilestick because it's a better solution than what i was doing
  sqlite3 /config/app.db <<EOS
    update settings set config_kepubifypath='/usr/bin/kepubify' where config_kepubifypath is NULL or LENGTH(config_kepubifypath)=0;
EOS

  if [[ $? == 0 ]]; then
    echo "Successfully set kepubify paths in '/config/app.db'!"
  elif [[ $? > 0 ]]; then
    echo "Could not set binary paths for '/config/app.db' (see errors above)."
  fi
fi

export CALIBRE_DBPATH=/config
cd /app/calibre-web
exec python3 /app/calibre-web/cps.py

