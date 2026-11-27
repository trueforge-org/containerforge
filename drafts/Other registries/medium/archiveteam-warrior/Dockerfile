FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# Fetch warrior-code2 at the pinned commit and install it into the bundled /app/venv at build time.
# UNVERIFIED: upstream builds on atdr.meo.ws/archiveteam/grab-base (wget-lua binaries, crane), which is not
# reproduced here. UNVERIFIED: that warrior-code2 provides run-warrior3 through pip install.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git; \
    rm -rf /var/lib/apt/lists/*; \
    git clone --recurse-submodules https://github.com/ArchiveTeam/warrior-code2.git /tmp/warrior-code2; \
    git -C /tmp/warrior-code2 checkout --detach "${VERSION}"; \
    git -C /tmp/warrior-code2 submodule update --init --recursive; \
    cp -a /tmp/warrior-code2 /app/warrior-code2; \
    /app/venv/bin/pip install --no-cache-dir /app/warrior-code2; \
    install -D -m 0644 /app/warrior-code2/LICENSE /usr/share/licenses/archiveteam-warrior/LICENSE; \
    rm -rf /app/warrior-code2/.git /tmp/warrior-code2

ENV HOME=/config \
    PATH=/app/venv/bin:${PATH}

USER apps
COPY --chmod=0755 . /

EXPOSE 8001
VOLUME /config
STOPSIGNAL SIGINT
