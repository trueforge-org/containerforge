FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: sha256 of the amd64 .deb, computed locally on first fetch (no upstream checksum is published).
ARG SEEDSYNC_DEB_SHA256=UNVERIFIED

ENV HOME=/tmp
USER root

# Only packages missing from the base (verify with dpkg -l on the first build).
# UNVERIFIED: p7zip-rar availability on the Ubuntu base.
RUN apt-get update && apt-get install -y --no-install-recommends \
        lftp \
        openssh-client \
        p7zip-full \
        p7zip-rar \
        bzip2 \
        curl \
        libnss-wrapper \
    && rm -rf /var/lib/apt/lists/*

# Route A: amd64 .deb (arm64 has no upstream .deb, so image-all is amd64 only).
# UNVERIFIED: internal layout of the .deb (python code, html, scanfs) and whether it bundles its own interpreter.
RUN curl -fsSL -o /tmp/seedsync.deb "https://github.com/ipsingh06/seedsync/releases/download/v${VERSION}/seedsync_${VERSION}_${TARGETARCH}.deb" \
    && echo "${SEEDSYNC_DEB_SHA256}  /tmp/seedsync.deb" | sha256sum -c - \
    && dpkg-deb -x /tmp/seedsync.deb /tmp/seedsync-root \
    && mv /tmp/seedsync-root /app/seedsync \
    && rm -f /tmp/seedsync.deb

# UNVERIFIED: Python dependencies for the extracted app. Install into /app/venv at build time from the deb metadata (uv pip install --python /app/venv/bin/python ...). Not written yet.

# Default config: generated at build time, then the upstream sed sets local_path to /downloads/.
# UNVERIFIED: module path /app/seedsync/python/seedsync.py and the generated file name.
RUN mkdir -p /tmp/seedsync-defaults /app/seedsync/defaults \
    && /app/venv/bin/python /app/seedsync/python/seedsync.py -c /tmp/seedsync-defaults --html / --scanfs / --exit \
    && sed 's|local_path = <replace me>|local_path = /downloads/|' /tmp/seedsync-defaults/settings.cfg > /app/seedsync/defaults/settings.cfg \
    && rm -rf /tmp/seedsync-defaults

# UNVERIFIED: license file from the .deb (usually /usr/share/doc/seedsync/copyright). Copy it to /usr/share/licenses/seedsync/ once the layout is confirmed.

RUN chown -R root:root /app && chmod -R 755 /app \
    && rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8800
VOLUME /config
WORKDIR /config
