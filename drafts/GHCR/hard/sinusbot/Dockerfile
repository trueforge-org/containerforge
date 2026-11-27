FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# The vendor tarball is a closed-source amd64 binary. Refuse any other arch.
# UNVERIFIED: no checksum is published for the tarball, so none is checked here.
RUN set -eux; \
    if [ "${TARGETARCH}" != "amd64" ]; then \
        echo "sinusbot is amd64 only (got ${TARGETARCH})" >&2; \
        exit 1; \
    fi

# Upstream generates en_US.UTF-8. C.UTF-8 is used instead. UNVERIFIED that the bot needs en_US.
ENV HOME=/tmp/home \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# UNVERIFIED: package names on 26.04 (t64 renames), mapped from upstream's bookworm list.
# TeamSpeak client, TTS, yt-dlp, deno and the Xvfb/x11vnc stack are left out (see plan section 9).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        libasound2t64 \
        libatomic1 \
        libegl1 \
        libglib2.0-0 \
        libnss3 \
        libpci3 \
        libxcomposite1 \
        libxcursor1 \
        libxkbcommon0; \
    rm -rf /var/lib/apt/lists/*

# Tarball at a fixed vendor URL. Extracted under /app, which is read-only at runtime.
# Upstream install.sh renames scripts -> default_scripts and symlinks data, config and private.dat.
# The same symlinks are made here, pointing into /config, so the state lives on the volume.
# UNVERIFIED: tarball layout (scripts/, config.ini.dist, private.dat) was not read.
RUN set -eux; \
    mkdir -p /app/sinusbot; \
    curl -fsSL -o /tmp/sinusbot.tar.bz2 \
        "https://michael.frie.se/sinusbot-${VERSION}-amd64.tar.bz2"; \
    tar -xjf /tmp/sinusbot.tar.bz2 -C /app/sinusbot; \
    rm -f /tmp/sinusbot.tar.bz2; \
    cd /app/sinusbot; \
    if [ -d scripts ]; then mv scripts default_scripts; fi; \
    ln -sfn /config/data /app/sinusbot/data; \
    ln -sfn /config/scripts /app/sinusbot/scripts; \
    ln -sfn /config/config.ini /app/sinusbot/config.ini; \
    ln -sfn /config/data/private.dat /app/sinusbot/private.dat; \
    chmod -R a+rX /app/sinusbot; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8087
VOLUME /config

WORKDIR /app/sinusbot
