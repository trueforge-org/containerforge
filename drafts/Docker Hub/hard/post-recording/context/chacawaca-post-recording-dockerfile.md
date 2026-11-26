# chacawaca/post-recording Dockerfile

Source: https://github.com/chacawaca/docker-post-recording/blob/971031f2ba851a003d762c1ee9aa523100a90b4b/Dockerfile (raw URL, pinned commit 971031f2), fetched 2026-11-26

## Build
- Base: `FROM ubuntu:20.04`. WORKDIR /tmp.
- apt (single RUN): coreutils findutils expect tcl8.6 mediainfo libfreetype6 libutf8proc2 libtesseract4 libpng16-16 expat libva-drm2 i965-va-driver libxcb-shape0 libssl1.1, then build deps: python3 git build-essential libargtable2-dev autoconf libtool-bin libsdl1.2-dev libavutil-dev libavformat-dev libavcodec-dev nginx.
- User: `useradd -u 911 -U -d /config -s /bin/false abc`; `usermod -G users abc`; mkdir /config /output.
- Comskip: `git clone git://github.com/erikkaashoek/Comskip` (git:// protocol) -> ./autogen.sh, ./configure, make.
- Comchap: `git clone https://github.com/BrettSheleski/comchap.git` -> make.
- Cleanup: apt autoremove/clean, rm -rf /tmp/* /var/lib/apt/lists/*.
- Multi-stage COPY (external images): `gizmotronic/ccextractor` /usr/local/bin; `chacawaca/ffmpeg` /usr/local/; `linuxserver/plex` /etc/cont-init.d/50-gid-video.
- s6-overlay: `ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.1/s6-overlay-amd64-installer /tmp/` then run it with `/` as target (amd64 only).
- `COPY rootfs/ /`.

## Env (ENV block)
| Var | Default |
| --- | --- |
| SUBTITLES | 0 |
| DELETE_TS | 1 |
| SOURCE_EXT | ts |
| PUID | 99 |
| PGID | 100 |
| UMASK | 000 |
| CONVERSION_FORMAT | mp4 |
| POST_PROCESS | comchap |
| NVIDIA_VISIBLE_DEVICES | all |
| NVIDIA_DRIVER_CAPABILITIES | all |
| SOURCE_STABLE_TIME | 10 |
| SOURCE_MIN_DURATION | 10 |
| LANG / LC_ALL | C.UTF-8 |

## Entrypoint
- `ENTRYPOINT ["/init"]` (s6-overlay). No EXPOSE, no ports.

## Gotchas
- Pulls binaries from third-party images (ffmpeg, ccextractor, plex) instead of building them.
- Requires s6-overlay v2 installer; the Dockerfile runs as root during build.
- Ubuntu 20.04 base and libssl1.1 are EOL-era dependencies.
