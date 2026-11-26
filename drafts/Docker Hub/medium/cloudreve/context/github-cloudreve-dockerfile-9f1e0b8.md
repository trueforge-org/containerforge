# cloudreve/Cloudreve Dockerfile @ 9f1e0b8

Source: https://raw.githubusercontent.com/cloudreve/Cloudreve/9f1e0b8333f5c7304a09e1dcb3f9c170dddd63f3/Dockerfile (fetched 2026-11-26)

## Base / ENV
- `FROM alpine:latest` (single stage); no ARG
- WORKDIR /cloudreve
- ENV CR_ENABLE_ARIA2=1; CR_SETTING_DEFAULT_thumb_ffmpeg_enabled=1; CR_SETTING_DEFAULT_thumb_vips_enabled=1; CR_SETTING_DEFAULT_thumb_libreoffice_enabled=1; CR_SETTING_DEFAULT_media_meta_ffprobe=1; CR_SETTING_DEFAULT_thumb_libraw_enabled=1

## Steps
- `apk update`; `apk add --no-cache` tzdata vips-tools ffmpeg libreoffice aria2 supervisor font-noto font-noto-cjk libheif libraw-tools
- timezone: copy /usr/share/zoneinfo/Asia/Shanghai -> /etc/localtime; write /etc/timezone
- `mkdir -p ./data/temp/aria2`; `chmod -R 766 ./data/temp/aria2`
- COPY .build/aria2.supervisor.conf and .build/entrypoint.sh -> ./
- COPY prebuilt `cloudreve` binary -> ./cloudreve (no download URLs)
- chmod +x ./cloudreve ./entrypoint.sh

## Runtime
- EXPOSE 5212 443 6888 6888/udp
- VOLUME /cloudreve/data
- ENTRYPOINT ["sh", "./entrypoint.sh"]; no CMD; USER not set (root)
