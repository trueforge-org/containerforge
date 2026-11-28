# hadolint ignore=DL3007
# UNVERIFIED: the plan's digest (f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a...) is not used elsewhere in the repo. This uses the digest the sibling apps pin.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
ARG SHA256
# UNVERIFIED: upstream DL_URL is http. Check whether https works; SHA256 pins the content either way.
# UNVERIFIED: upstream start-server.sh scrapes a tar.gz link from DL_URL, so confirm this URL is the archive itself.
ARG DL_URL=http://www.urbanterror.info/downloads/software/urt/43/UrbanTerror43_ded.tar.gz

USER root

# The server binary is x86_64 only (image-all lists linux/amd64 only). Fail early on other architectures.
RUN test "${TARGETARCH}" = "amd64"

# UNVERIFIED: curl and ca-certificates are assumed to come from the base image. Check with apt-cacher or dpkg -l.
# UNVERIFIED: apt package name libsdl2-2.0-0 on 26.04 (apt-cache policy).
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libsdl2-2.0-0 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download the game, verify it against the pinned sha256, and extract it to /app.
# /app is read-only at runtime, so start.sh copies the server config into /config and never writes here.
# UNVERIFIED: tarball layout (--strip-components=1). List the archive once before relying on it.
RUN curl -fL -o /tmp/UrbanTerror.tar.gz "${DL_URL}" && \
    echo "${SHA256}  /tmp/UrbanTerror.tar.gz" | sha256sum -c - && \
    mkdir -p /app && \
    tar xzf /tmp/UrbanTerror.tar.gz -C /app --strip-components=1 && \
    rm -f /tmp/UrbanTerror.tar.gz && \
    chown -R root:root /app && \
    chmod -R go-w /app && \
    chmod 0755 /app/Quake3-UrT-Ded.x86_64

ENV GAME_PORT=27960 \
    CONFIG_NAME=server.cfg \
    START_PARAMS="" \
    HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 27960/udp
VOLUME /config

CMD ["/start.sh"]
