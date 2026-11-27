FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION=1.0.2

ENV \
    FLASK_APP=prpdf.py \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5000 \
    WORKDIR=/app/prpdf

USER root
WORKDIR /app

# Replaces the upstream builder stage (Ghostscript 10.03.1 and jbig2enc were compiled from source).
# UNVERIFIED: apt package names and versions on this base; pin versions once checked with apt-cache policy.
# Upstream ghostscript and jbig2enc versions differ from apt; compare output before opening the PR.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ghostscript \
        jbig2enc \
        libopenjp2-7 \
        poppler-utils \
        qpdf \
        tesseract-ocr \
        tesseract-ocr-deu \
    && rm -rf /var/lib/apt/lists/*

# Fetch the source at the release tag. No checksum is published, so the tag is the pin.
# Python deps are installed at build time into /app/venv (read-only at runtime).
# requirements.txt is unpinned upstream; pinning is an open decision (see plan section 10).
RUN mkdir -p /tmp/src /app/prpdf \
    && curl -fsSL "https://github.com/maschhoff/pdfscanexplorer/archive/refs/tags/${VERSION}.tar.gz" \
        | tar -xz -C /tmp/src --strip-components=1 \
    && cp -a /tmp/src/. /app/prpdf/ \
    && /app/venv/bin/pip install --requirement /app/prpdf/requirements.txt \
    && install -Dm644 /tmp/src/LICENSE /usr/share/licenses/prpdf/LICENSE \
    && chown -R root:root /app && chmod -R 755 /app \
    && rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 5000
VOLUME /config
