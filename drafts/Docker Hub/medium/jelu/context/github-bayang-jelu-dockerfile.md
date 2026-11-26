# bayang/jelu: Dockerfile (commit 2aba1840)
Source URL(s): https://github.com/bayang/jelu/blob/2aba1840c9d823851a5d219dcf9802e1a194a4e2/Dockerfile = raw at same sha (fetched 2026-11-26, 117 lines)

## Base / env
- FROM eclipse-temurin:17-jre-noble; WORKDIR app
- ARG TARGETPLATFORM; ENV TARGETPLATFORM default linux/amd64
- ENV JELU_DATABASE_PATH=/database/, JELU_FILES_IMAGES=/files/images/, JELU_FILES_IMPORTS=/files/imports/, JELU_METADATA_CALIBRE_PATH=/usr/bin/fetch-ebook-metadata, LC_ALL=en_US.UTF-8, QTWEBENGINE_DISABLE_SANDBOX=1

## Build (per TARGETPLATFORM branch)
- linux/amd64 and linux/arm64: apt install wget xz-utils, Qt/xcb/NSS/fonts libs, python3-xdg, binutils, poppler-utils, libqpdf29t64, fcitx-rime, speech-dispatcher
  - Calibre 8.4.0 tarball: https://download.calibre-ebook.com/8.4.0/calibre-8.4.0-x86_64.txz (amd64) or calibre-8.4.0-arm64.txz (arm64) -> /opt/calibre; calibre_postinstall; strip libQt6Core
  - Goodreads plugin v1.8.2 zip from github.com/kiwidude68/calibre_plugins releases, added via calibre-customize
- other platforms: apt install calibre (distro package) + same goodreads plugin
- ARG DEPENDENCY=build/dependency: COPY dependencies/, spring-boot-loader/, snapshot-dependencies/ into WORKDIR, application/jelu-*.jar -> jelu.jar
- Build context must contain build/dependency (Spring Boot layered jar output; built outside this Dockerfile)

## Runtime
- ENTRYPOINT ["java", "-jar", "jelu.jar", "--spring.config.additional-location=optional:file:/config/"]
- EXPOSE 11111
- No USER, no HEALTHCHECK, no VOLUME (runs as root)

## Gotchas
- Calibre is a large dependency (fetch-ebook-metadata used for ISBN/title metadata).
- amd64/arm64 Calibre tarballs pinned to 8.4.0 in Dockerfile.
