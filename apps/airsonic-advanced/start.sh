#!/usr/bin/env bash

mkdir -p "${AIRSONIC_ADVANCED_SETTINGS}"/transcode

fi

if [[ ! -e "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/ffmpeg || ! -e  "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/flac || ! -e "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/lame  ]]; then
    ln -sf /usr/bin/ffmpeg "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/
    ln -sf /usr/bin/flac "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/
    ln -sf /usr/bin/lame "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/
fi

# strip leading slash if present in set variable
if [[ -n "$CONTEXT_PATH" ]]; then
    CONTEXT_PATH="${CONTEXT_PATH#/}"
fi

# set url base to / if variable not set, readding leading slash if variable is set.
URL_BASE="/${CONTEXT_PATH}"

# add option to pass runtime arguments
IFS=" " read -r -a RUN_ARRAY <<< "$JAVA_OPTS"

cd "${AIRSONIC_ADVANCED_HOME}"
exec java \
                -Dlog4j2.formatMsgNoLookups=true \
                -Dairsonic.defaultMusicFolder=/music \
                -Dairsonic.defaultPlaylistFolder=/playlists \
                -Dairsonic.defaultPodcastFolder=/podcasts \
                -Dairsonic.home="${AIRSONIC_ADVANCED_SETTINGS}" \
                -Djava.awt.headless=true \
                -Djava.io.tmpdir="/run/tomcat.4040" \
                -Dserver.servlet.context-path="${URL_BASE}" \
                -Dserver.host=0.0.0.0 \
                -Dserver.port=4040 \
                "${RUN_ARRAY[@]}" \
                -jar airsonic.war
