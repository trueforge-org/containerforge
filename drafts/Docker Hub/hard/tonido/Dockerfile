# Unresolved items (see plan.md "Fix attempt (2026-11-28)"):
# - Closed-source, end-of-life vendor binary. Redistribution terms are not confirmed
#   (the package manifest only says <License>Free</License>).
# - The vendor URL now returns 404. The tarball comes from the Internet Archive snapshot of
#   2021-10-06, pinned by sha256. Not built, not run.
# - Bundled libgd needs libpng12.so.0, which Ubuntu 26.04 no longer ships. It is taken from the
#   Ubuntu xenial-updates .deb below (pinned by sha256).
# - Binary compatibility with Ubuntu 26.04 and arm64 are untested (amd64 only).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
ARG TONIDO_URL
ARG TONIDO_SHA256
ARG LIBPNG12_URL
ARG LIBPNG12_SHA256

USER root

ENV HOME=/config \
    LD_LIBRARY_PATH=/app/tonido

RUN set -eux; \
    test "${TARGETARCH}" = "amd64"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libjpeg-turbo8 \
        libfontconfig1 \
        libfreetype6 \
        zlib1g; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /tmp/dl /app/tonido; \
    curl -fsSL -o /tmp/dl/libpng12.deb "${LIBPNG12_URL}"; \
    echo "${LIBPNG12_SHA256}  /tmp/dl/libpng12.deb" | sha256sum -c -; \
    dpkg-deb -x /tmp/dl/libpng12.deb /tmp/dl/libpng12; \
    install -m 0644 /tmp/dl/libpng12/lib/x86_64-linux-gnu/libpng12.so.0.54.0 /usr/lib/x86_64-linux-gnu/libpng12.so.0.54.0; \
    ln -sf libpng12.so.0.54.0 /usr/lib/x86_64-linux-gnu/libpng12.so.0; \
    ldconfig; \
    curl -fsSL -o /tmp/dl/tonido.tar.gz "${TONIDO_URL}"; \
    echo "${TONIDO_SHA256}  /tmp/dl/tonido.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/dl/tonido.tar.gz -C /app/tonido; \
    grep -q "<Version>${VERSION}</Version>" /app/tonido/manifest.xml; \
    install -d /usr/share/licenses/tonido; \
    install -m 0644 /app/tonido/manifest.xml /usr/share/licenses/tonido/manifest.xml; \
    install -m 0644 /tmp/dl/libpng12/usr/share/doc/libpng12-0/copyright /usr/share/licenses/tonido/libpng12-copyright; \
    chown -R root:root /app && chmod -R a+rX /app; \
    rm -rf /tmp/dl

USER apps
COPY --chmod=0755 . /

EXPOSE 10001
VOLUME /config
WORKDIR /config
