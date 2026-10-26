
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

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
    /app/venv/bin/pip install -U --no-cache-dir \
        -r https://raw.githubusercontent.com/ProgVal/Limnoria/master/requirements.txt && \
    /app/venv/bin/pip install -U --no-cache-dir \
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


# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
