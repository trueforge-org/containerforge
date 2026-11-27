FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

ENV TITLE=Firefox \
    HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache \
    MOZ_CRASHREPORTER_DISABLE=1 \
    MOZ_DISABLE_AUTO_SAFE_MODE=1

USER root

# Install the Mozilla tarball for the target arch, checked against the SHA512SUMS of the release.
# UNVERIFIED: runtime libraries for the bare tarball on Ubuntu 26.04. Run ldd at build time and add
# only what is missing (candidates: libgtk-3-0t64 libdbus-glib-1-2 libasound2t64 libxt6t64 libx11-xcb1).
RUN set -eux; \
    mkdir -p /app; \
    case "${TARGETARCH}" in \
      amd64) MOZ_ARCH=linux-x86_64; MOZ_SHA512=4b83d5313082dbf9b9c16a961487ff3299d7da85a5b47a728cd88198aecb6341bd60eed4a7779c366fa2ff6e6017e0b10cad85d61701a8b6176bc616cd56dd6c ;; \
      arm64) MOZ_ARCH=linux-aarch64; MOZ_SHA512=a4689c3cdd88e240db36c6cca06a1c3411568a4a0c1c6ce9944d939e8c7ad78cb42eaea049bffecfc4b49fa6f55467f64529775c471a6736d0fad30fa733da63 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/firefox.tar.xz \
      "https://archive.mozilla.org/pub/firefox/releases/${VERSION}/${MOZ_ARCH}/en-US/firefox-${VERSION}.tar.xz"; \
    echo "${MOZ_SHA512}  /tmp/firefox.tar.xz" | sha512sum -c -; \
    tar -xJf /tmp/firefox.tar.xz -C /app; \
    ln -s /app/firefox/firefox /usr/local/bin/firefox; \
    rm -f /tmp/firefox.tar.xz

# UNVERIFIED: the tarball ships no license file in the path used. Copy the notices into /usr/share/licenses/firefox/ once confirmed.

COPY --chmod=0755 . /

# Telemetry and first-run prefs. UNVERIFIED: prefs load from the tarball's browser/defaults/preferences path.
RUN set -eux; \
    install -D -m 0644 /defaults/firefox.js /app/firefox/browser/defaults/preferences/firefox.js; \
    rm -rf /tmp/*

USER apps

EXPOSE 3001

VOLUME /config

CMD [""]
