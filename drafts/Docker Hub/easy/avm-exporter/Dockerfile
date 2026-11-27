
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION=4.0.3

ENV FRITZ_LISTEN_ADDRESS=0.0.0.0 \
    HOME=/tmp

USER root

# Pure Python wheel (no apt packages needed). LICENSE.md is taken from the upstream tag.
RUN /app/venv/bin/pip install --no-cache-dir "fritz-exporter==${VERSION}" \
    && mkdir -p /usr/share/licenses/avm-exporter \
    && curl -fsSL -o /usr/share/licenses/avm-exporter/LICENSE.md \
        "https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v${VERSION}/LICENSE.md" \
    && chown -R root:root /app && chmod -R a+rX /app \
    && rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9787
VOLUME /config
WORKDIR /config
