
FROM ghcr.io/trueforge-org/python:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG LIMNORIA_RELEASE

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cargo \
        libffi-dev \
        libssl-dev \
        python3-venv && \
    echo "**** install runtime packages ****" && \
    echo "**** install app ****" && \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install -U --no-cache-dir \
        pip \
        wheel && \
    /app/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
        -r https://raw.githubusercontent.com/ProgVal/Limnoria/master/requirements.txt && \
    /app/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
        limnoria=="${VERSION}" && \
    echo "**** cleanup ****" && \
    apt-get purge -y --auto-remove \
        build-essential \
        cargo \
        libffi-dev \
        libssl-dev && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        $HOME/.cache \
        $HOME/.cargo

# copy local files
USER apps
COPY --chmod=0755 . /
COPY ./root /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
