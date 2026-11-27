FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS ui

ARG VERSION

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV YARN_CACHE_FOLDER=/tmp/yarn \
    NODE_OPTIONS=--openssl-legacy-provider

# UNVERIFIED: the ubuntu base ships Node and yarn; vue-cli 4 / webpack 4 need the legacy OpenSSL provider on modern Node.
# UNVERIFIED: whether that flag still works on the Node in the base. Fallback: an older Node stage.
RUN mkdir -p /build/chronos && \
    curl -fsSL "https://github.com/simse/chronos/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /build/chronos --strip-components=1 && \
    cd /build/chronos/chronos-ui && \
    yarn install && \
    yarn build && \
    rm -rf /build/chronos/chronos-ui/node_modules /tmp/*

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV CHRONOS_PATH=/config \
    PYTHONPATH=/app/chronos \
    PIP_CACHE_DIR=/tmp/pip \
    PYTHONDONTWRITEBYTECODE=1

COPY --from=ui /build/chronos /app/chronos

# hadolint ignore=DL3008
# Upstream pins are 2019-2020 era (Python 3.7). Relax them so wheels exist for this Python.
# UNVERIFIED: the relaxed set imports and runs on Python 3.15. Drop dev-only pins and the -e . line.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev && \
    sed -E -e '/^-e /d' -e '/^(black|mock|pytest|py|pluggy|typed-ast)==/d' -e 's/==/>=/' \
        /app/chronos/requirements.txt > /tmp/requirements.txt && \
    /app/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
    install -D -m 0644 /app/chronos/LICENSE /usr/share/licenses/chronos/LICENSE && \
    apt-get purge -y --auto-remove build-essential libffi-dev libssl-dev && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* && \
    install -d -o apps -g apps /config && \
    chown -R root:root /app && \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
