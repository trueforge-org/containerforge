# Upstream Dockerfile: suwayomi/docker-tachidesk @ 7a2bdee0b5aab381f80a9186ef8c73507771050f

Source URL(s) + date: https://raw.githubusercontent.com/suwayomi/docker-tachidesk/7a2bdee0b5aab381f80a9186ef8c73507771050f/Dockerfile (fetched 2026-11-27)

## Build (2 stages)
- Stage `build`: `eclipse-temurin:25.0.5_8-jdk-noble`. Optional abort handler: if `TACHIDESK_ABORT_HANDLER_DOWNLOAD_URL` set, compiles `catch_abort.c` into `/opt/catch_abort.so`.
- Final: `eclipse-temurin:25.0.5_8-jre-noble`.
  - apt: curl, gettext-base, unzip, tini, ca-certificates, p11-kit; rebuilds java cacerts via p11-kit.
  - COPY scripts/kcef_download.sh -> /root/kcef_download.sh.
  - KCEF/CEF deps if `TACHIDESK_KCEF=y` (default y), or empty and TARGETPLATFORM is linux/amd64 or linux/arm64: libxss1, libxext6, libxrender1, libxcomposite1, libxdamage1, libxkbcommon0, libxtst6, libxcursor1, libglib2.0-0t64, libnss3, libdbus-1-3, libpango-1.0-0, libcairo2, libasound2t64, libatk-bridge2.0-0t64, libcups2t64, libdrm2, libgbm1, libegl1, xvfb, CJK fonts, curl jq gawk findutils. Then runs `kcef_download.sh "$TACHIDESK_KCEF_RELEASE_URL" "$TARGETPLATFORM"`.
  - COPY --from=build /opt/*.so /opt/.
  - User: `userdel -r ubuntu`; `groupadd --gid 1000 suwayomi`; `useradd --uid 1000 --gid suwayomi -G audio,video suwayomi`; mkdir /home/suwayomi/.local/share/Tachidesk.
  - COPY scripts/create_server_conf.sh and scripts/startup_script.sh to /home/suwayomi/.
  - `curl -s --create-dirs -L $TACHIDESK_RELEASE_DOWNLOAD_URL -o /home/suwayomi/startup/tachidesk_latest.jar`; `chmod 777 -R /home/suwayomi`; chown suwayomi.

## Build ARGs
| ARG | Purpose |
| --- | --- |
| TACHIDESK_ABORT_HANDLER_DOWNLOAD_URL | catch_abort.c source (build stage) |
| TACHIDESK_KCEF | y / n / empty (auto) |
| TACHIDESK_KCEF_RELEASE_URL | KCEF release for kcef_download.sh |
| TACHIDESK_RELEASE_DOWNLOAD_URL | Suwayomi server jar URL |
| BUILD_DATE, TACHIDESK_RELEASE_TAG, TACHIDESK_FILENAME, TACHIDESK_DOCKER_GIT_COMMIT | OCI labels |

## Runtime
- ENV HOME=/home/suwayomi; MALLOC_ARENA_MAX=2; JDK_JAVA_OPTIONS="-XX:TrimNativeHeapInterval=60000 -XX:G1PeriodicGCInterval=300000 -XX:MaxHeapFreeRatio=30 -XX:MinHeapFreeRatio=10".
- WORKDIR /home/suwayomi; USER suwayomi (uid 1000); EXPOSE 4567.
- ENTRYPOINT ["tini", "--"]; CMD ["/home/suwayomi/startup_script.sh"].
- Labels: org.opencontainers.image.licenses="MPL-2.0", source https://github.com/suwayomi/docker-tachidesk.

## Gotchas
- `chmod 777 -R /home/suwayomi` (world-writable home) so non-default UIDs can write server.conf.
- No HEALTHCHECK, no VOLUME.
- Arch: KCEF auto-enabled only for amd64/arm64.
