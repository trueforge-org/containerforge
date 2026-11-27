#!/usr/bin/env bash
# Writes the landing page to /tmp/html, because the nginx root stays read-only.
# Adapted from modem7/docker-rickroll scripts/index/80-index.sh. The upstream script was not fetched for this draft,
# so only the env vars in settings.yaml are handled. Not ported: OVERLAY (decoy screens), PRE_TITLE and the cookie banner.
# UNVERIFIED: markup and CSS are written here, not copied from upstream.
set -eu

esc() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' -e "s/'/\&#39;/g"
}

TITLE_V="$(esc "${TITLE:-Rickroll}")"
HEADLINE_V="$(esc "${HEADLINE:-}")"
HEIGHT_V="$(esc "${HEIGHT:-100vh}")"
WIDTH_V="$(esc "${WIDTH:-100%}")"
FIT_V="$(esc "${OBJECT_FIT:-cover}")"
case "${LOOP:-true}" in
    true) LOOP_ATTR=" loop" ;;
    *) LOOP_ATTR="" ;;
esac

echo "[80-index] Writing /tmp/html/index.html"
mkdir -p /tmp/html
cat > /tmp/html/index.html <<EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${TITLE_V}</title>
<style>
html, body { margin: 0; height: 100%; background: #000; color: #fff; font-family: sans-serif; }
.wrap { position: relative; height: ${HEIGHT_V}; width: ${WIDTH_V}; margin: 0 auto; }
video { width: 100%; height: 100%; object-fit: ${FIT_V}; display: block; }
h1 { position: absolute; top: 1rem; width: 100%; text-align: center; margin: 0; text-shadow: 0 0 6px #000; }
</style>
</head>
<body>
<div class="wrap">
<h1>${HEADLINE_V}</h1>
<video src="/video.mp4" autoplay muted playsinline${LOOP_ATTR}></video>
</div>
</body>
</html>
EOF
