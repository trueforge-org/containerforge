# UMS upstream Dockerfile (main branch)

Source URL(s): https://raw.githubusercontent.com/UniversalMediaServer/UniversalMediaServer/main/src/main/external-resources/docker/Dockerfile (fetched 2026-11-27). Not the 15.9.0 tag; match to tag UNVERIFIED.

## Build
- Single stage `FROM ubuntu:22.04`. `ARG DEBIAN_FRONTEND=noninteractive`.
- `apt-get update` then `apt-get install coreutils ffmpeg mediainfo openjdk-17-jre-headless iputils-ping mplayer fonts-dejavu -y`.
- Build context expects `./app` (UMS application tree, incl. `ums.jar`) and `./profile` + `./app/UMS.conf` (pre-built, not generated here).
- `COPY ./profile /profile`, `COPY ./app/UMS.conf /profile`, `COPY ./app /ums`.

## Runtime
- WORKDIR `/ums` at runtime. No `USER` (runs as root).
- `VOLUME /media`, `VOLUME /profile`.
- `ENV UMS_PROFILE=/profile`.
- `ENV JDK_JAVA_OPTIONS="--add-modules=jdk.incubator.vector --add-opens java.base/sun.nio.ch=ALL-UNNAMED -Dfile.encoding=UTF-8 -Djava.net.preferIPv4Stack=true -Djna.nosys=true"`.
- `ENTRYPOINT [ "java", "-jar", "ums.jar" ]`.

## Ports
- `EXPOSE 1900/udp 5001/tcp 5353/udp 9001/tcp 9002/tcp`
  - Port purposes are not stated in the Dockerfile. Only the EXPOSE list is confirmed.

## Label
- `org.opencontainers.image.title="Universal Media Server"`.

## Gotchas
- Upstream image is Java 17 on Ubuntu 22.04 with apt-installed JRE.
- Discovery ports need multicast, which bridge networking usually blocks.
- Dockerfile copies a pre-built `app/` tree, so the source of that tree is not in this file.
