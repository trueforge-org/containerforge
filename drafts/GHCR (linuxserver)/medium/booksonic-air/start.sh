#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${BOOKSONIC_AIR_SETTINGS}/transcode"

# Link the transcoders once, as the upstream init does.
for bin in ffmpeg flac lame; do
    if [ ! -e "${BOOKSONIC_AIR_SETTINGS}/transcode/${bin}" ]; then
        ln -sf "/usr/bin/${bin}" "${BOOKSONIC_AIR_SETTINGS}/transcode/"
    fi
done

# Strip a leading slash from CONTEXT_PATH, then build the URL base.
CONTEXT_PATH="${CONTEXT_PATH:-}"
CONTEXT_PATH="${CONTEXT_PATH#/}"
URL_BASE="/${CONTEXT_PATH}"

# Extra JVM arguments: split on spaces, never eval'd.
read -r -a RUN_ARRAY <<< "${JAVA_OPTS:-}"

cd "${BOOKSONIC_AIR_HOME}"
exec java \
    -Dairsonic.defaultMusicFolder=/music \
    -Dairsonic.defaultPlaylistFolder=/playlists \
    -Dairsonic.defaultPodcastFolder=/podcasts \
    -Dairsonic.home="${BOOKSONIC_AIR_SETTINGS}" \
    -Djava.awt.headless=true \
    -Djava.io.tmpdir=/tmp \
    -Dserver.servlet.contextPath="${URL_BASE}" \
    -Dserver.host=0.0.0.0 \
    -Dserver.port=4040 \
    "${RUN_ARRAY[@]}" \
    -jar booksonic.war
