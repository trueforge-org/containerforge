# jlesage/docker-jdownloader-2 Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-jdownloader-2/v26.09.1/Dockerfile · fetched 2026-11-27

## Build
- Stage jd2: `FROM --platform=$BUILDPLATFORM alpine:3.24`, curl https://installer.jdownloader.org/JDownloader.jar -> /defaults/JDownloader.jar
- Final base: `jlesage/baseimage-gui:alpine-3.24-v4.14.0`
- ARG DOCKER_IMAGE_VERSION (set into set-cont-env)
- Packages (add-pkg): java-common, openjdk8-jre (JRE 8 chosen for size), jq, ttf-dejavu, curl, ffmpeg, rtmpdump, moreutils
- Icon: install_app_icon.sh from jlesage/docker-templates jdownloader-2-icon.png
- COPY rootfs/ / ; set-cont-env APP_NAME "JDownloader 2"

## Env vars (ENV, public)
| Var | Default |
| --- | --- |
| MYJDOWNLOADER_EMAIL | empty |
| MYJDOWNLOADER_PASSWORD | empty |
| MYJDOWNLOADER_DEVICE_NAME | empty |
| JDOWNLOADER_HEADLESS | 0 |
| JDOWNLOADER_MAX_MEM | empty |

## Ports / volumes
- EXPOSE 3129 (MyJDownloader direct connection)
- VOLUME /output (config dir is baseimage default)

## Gotchas
- ARM 32-bit Alpine JRE is hard to obtain (noted upstream).
- Version pinned via DOCKER_IMAGE_VERSION build arg.
- Not captured: rootfs/ init scripts (for config paths and user handling).
