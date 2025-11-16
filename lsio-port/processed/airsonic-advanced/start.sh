# ===== From ./processed/airsonic-advanced/root/etc/s6-overlay//s6-rc.d/init-airsonic-advanced-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p "${AIRSONIC_ADVANCED_SETTINGS}"/transcode
mkdir -p "/run/tomcat.4040"

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    lsiown -R abc:abc /config "${AIRSONIC_ADVANCED_SETTINGS}" /run/tomcat.4040
fi

if [[ ! -e "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/ffmpeg || ! -e  "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/flac || ! -e "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/lame  ]]; then
    ln -sf /usr/bin/ffmpeg "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/
    ln -sf /usr/bin/flac "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/
    ln -sf /usr/bin/lame "${AIRSONIC_ADVANCED_SETTINGS}"/transcode/
fi

# ===== From ./processed/airsonic-advanced/root/etc/s6-overlay//s6-rc.d/svc-airsonic-advanced/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# strip leading slash if present in set variable
if [[ -n "$CONTEXT_PATH" ]]; then
    CONTEXT_PATH="${CONTEXT_PATH#/}"
fi

# set url base to / if variable not set, readding leading slash if variable is set.
URL_BASE="/${CONTEXT_PATH}"

# add option to pass runtime arguments
IFS=" " read -r -a RUN_ARRAY <<< "$JAVA_OPTS"

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 4040" \
        cd "${AIRSONIC_ADVANCED_HOME}" s6-setuidgid abc \
            java \
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
else
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 4040" \
        cd "${AIRSONIC_ADVANCED_HOME}" \
            java \
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
fi

