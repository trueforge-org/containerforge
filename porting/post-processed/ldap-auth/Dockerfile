
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:436649ee533b748645c1e3ad8e4a1fc3fd2d9d4f0b1cc937bf742a5c3a7f32e5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libldap2-dev \
        python3-dev \
        libffi-dev && \
    echo "**** install runtime packages ****" && \
    apt-get install -y --no-install-recommends \
        libldap2 \
        libffi8 \
        python3 && \
    python3 -m venv /config/venv && \
    /config/venv/bin/pip install -U --no-cache-dir \
        pip \
        wheel && \
    /config/venv/bin/pip install -U --no-cache-dir \
        cryptography \
        legacy-cgi \
        python-ldap=="${VERSION}" && \
    echo "**** cleanup ****" && \
    apt-get remove -y --purge \
        build-essential \
        libldap2-dev \
        python3-dev \
        libffi-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        $HOME/.cache

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8888 9000

WORKDIR /config
VOLUME /config
