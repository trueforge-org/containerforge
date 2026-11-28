# DRAFT NOTES (see the "Fix attempt" section at the end of plan.md):
# - Built on the ContainerForge kasmvnc app (openbox desktop and web UI on 3000/3001), not on
#   the Selkies stack that linuxserver uses. The web UI is therefore KasmVNC, not Selkies.
# - Ubuntu ships chromium as a snap, so the Debian trixie .deb is installed from the Debian
#   archive with apt pinning. Not built or run: Debian/Ubuntu dependency resolution is unverified.
# - Chromium's sandbox needs unprivileged user namespaces. The wrapper adds --no-sandbox unless
#   CHROMIUM_SANDBOX=true, because Docker's default seccomp profile blocks them. Needs a decision.

FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:7e96ef6465ad32c153f71fdff80fa4e2cb8fdfce1ab79dd269f08c7647505275
ARG VERSION
ARG TARGETARCH

USER root

# VERSION is the upstream Chromium version. The Debian package version is "<VERSION>-1~debNuM", so match it with a glob.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends debian-archive-keyring; \
    printf '%s\n' \
        'Types: deb' \
        'URIs: http://deb.debian.org/debian' \
        'Suites: trixie trixie-updates' \
        'Components: main' \
        'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
        '' \
        'Types: deb' \
        'URIs: http://deb.debian.org/debian-security' \
        'Suites: trixie-security' \
        'Components: main' \
        'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
        > /etc/apt/sources.list.d/debian-trixie.sources; \
    printf '%s\n' \
        'Package: *' \
        'Pin: release o=Debian' \
        'Pin-Priority: 100' \
        '' \
        'Package: chromium chromium-common chromium-sandbox' \
        'Pin: release o=Debian' \
        'Pin-Priority: 600' \
        > /etc/apt/preferences.d/debian-chromium; \
    apt-get update; \
    apt-get install -y --no-install-recommends "chromium=${VERSION}-*" "chromium-common=${VERSION}-*"; \
    mkdir -p /usr/share/licenses/chromium; \
    cp /usr/share/doc/chromium/copyright /usr/share/licenses/chromium/copyright; \
    rm -f /etc/apt/sources.list.d/debian-trixie.sources /etc/apt/preferences.d/debian-chromium; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/*

USER apps
# defaults/autostart replaces the kasmvnc seed that start.sh copies into /config on first start.
COPY --chmod=0755 . /

EXPOSE 3000 3001
VOLUME /config
WORKDIR /config
