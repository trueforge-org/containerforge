# Docker Hub: apache/tika
Source URL(s): https://hub.docker.com/v2/repositories/apache/tika/ , .../tags?page_size=10 (fetched 2026-11-27)

- "Container images for Apache Tika Server (https://github.com/apache/tika-docker)"
- Pulls 78,648,139; stars 56; status active; last_updated 2026-11-25
- Tags: 160 total. Recent: latest (2026-11-20), 4.3.0-SNAPSHOT(-full), 3.4.0.0 and 3.4.0.0-full (2026-11-24), 3.3.3.1(-full), latest-full, 4.2.0-2-full, 4.2.0-full
- Arch (per tag): amd64, arm64, s390x
- Two variants: minimal (no suffix) and -full (adds GDAL and Tesseract OCR parsers, OCR languages en/fr/de/it/es)
- Chart pins 3.4.0.0 (digest 9f3e5bb9...)

## Run
- `docker run -d -p 127.0.0.1:9998:9998 apache/tika:<version>` (readme recommends localhost binding)

## Build (see github-apache-tika-docker-minimal-dockerfile.md)
- Stage fetch_tika: downloads tika-server-standard-${TIKA_VERSION}.jar (dlcdn, then archive, then downloads.apache.org) and .asc; verifies GPG with KEYS when CHECK_SIG=true
- Stage runtime: JRE ARG JRE default openjdk-17-jre-headless (minimal), ca-certificates
- ENTRYPOINT ["/bin/sh","-c","exec java -cp \"/tika-server-standard-${TIKA_VERSION}.jar:/tika-extras/*\" org.apache.tika.server.core.TikaServerCli -h 0.0.0.0 $0 $@"]

## Env
- TIKA_VERSION (set in image)

## Ports
- EXPOSE 9998

## User/UID
- USER $UID_GID with ARG UID_GID default 35002:35002 (numeric, not a name)

## Gotchas
- Readme recommends binding to 127.0.0.1 (Docker iptables exposure)
- Minimal Dockerfile base ubuntu:jammy (in repo); image is multi-arch
