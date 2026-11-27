#!/usr/bin/env bash
set -euo pipefail

cd /config

# Seed the baked starter only when the blog is missing. Refuse to overwrite a partial blog.
if [ ! -f /config/_config.yml ]; then
  if [ -e /config/package.json ] || [ -e /config/source ]; then
    echo "ERROR: /config has blog files but no _config.yml; refusing to overwrite them." >&2
    exit 1
  fi
  cp -a /app/hexo-starter/. /config/
fi

# Optional plugins, space separated npm names. Needs network on each start where set.
if [ -n "${HEXO_PLUGINS:-}" ]; then
  read -r -a plugins <<< "${HEXO_PLUGINS}"
  npm install --no-audit --no-fund --prefix /config "${plugins[@]}"
fi

# db.json and public/ are regenerated on each start.
hexo clean --cwd /config
exec hexo server --cwd /config -p 8080 --draft
