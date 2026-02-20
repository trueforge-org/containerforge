
FROM ghcr.io/trueforge-org/python:3.13.12

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
        libsasl2-dev \
        python3-dev \
        libffi-dev && \
    echo "**** install runtime packages ****" && \
    apt-get install -y --no-install-recommends \
        libldap2 \
        libsasl2-2 \
        libffi8 \
        python3 \
        python3-venv && \
    mkdir -p /config && \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install -U --no-cache-dir \
        pip \
        wheel && \
    /app/venv/bin/pip install -U --no-cache-dir \
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
