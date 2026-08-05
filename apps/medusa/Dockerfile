


FROM ghcr.io/trueforge-org/python:3.14.6@sha256:7126ada2ea0c2086b0f078af562c413bbbbb44b946aeb70c3175386647e434fe

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV LANG='en_US.UTF-8'

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev \
        python3-venv && \
    echo "**** install packages ****" && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        mediainfo && \
    echo "**** install app ****" && \
    mkdir -p \
        /app/medusa && \
    curl -o \
        /tmp/medusa.tar.gz -L \
        "https://github.com/pymedusa/Medusa/archive/v${VERSION}.tar.gz" && \
    tar xf /tmp/medusa.tar.gz -C \
        /app/medusa --strip-components=1 && \
    cd /app/medusa && \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install -U --no-cache-dir \
        setuptools && \
    /app/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
    echo "**** clean up ****" && \
    apt-get purge -y --auto-remove \
        build-essential \
        python3-dev && \
    rm -rf \
        /var/lib/apt/lists/* \
        $HOME/.cache \
        /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /

ENV PATH="/app/venv/bin:$PATH"



# ports and volumes
EXPOSE 8081
VOLUME /config
