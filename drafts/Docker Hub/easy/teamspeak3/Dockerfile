FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: this SHA256 is the plan's value for the amd64 3.13.9 tarball. The context fetch did not see
# checksums on the vendor downloads page. Confirm it before the first build; do not trust it blindly.
ARG TS3_SHA256=35049b080d23b001d32079eff0be1404f2d9784fbc7457887422ec134c095d5a

USER root

ENV HOME=/config

# bzip2 is not in the ubuntu base. libstdc++6 is probably already present (UNVERIFIED; drop it if dpkg -l shows it).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends bzip2 libstdc++6; \
    rm -rf /var/lib/apt/lists/*

# amd64 only: the vendor ships no arm64 server build.
RUN set -eux; \
    [ "${TARGETARCH}" = "amd64" ] || { echo "teamspeak3 supports linux/amd64 only" >&2; exit 1; }; \
    curl -fsSL -o /tmp/ts3.tar.bz2 "https://files.teamspeak-services.com/releases/server/${VERSION}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2"; \
    echo "${TS3_SHA256}  /tmp/ts3.tar.bz2" | sha256sum -c -; \
    tar -xjf /tmp/ts3.tar.bz2 -C /app --strip-components=1; \
    mkdir -p /usr/share/licenses/teamspeak3; \
    cp /app/LICENSE /app/3RD_PARTY_LICENSES /usr/share/licenses/teamspeak3/; \
    mv /app/*.so /app/redist/* /usr/local/lib/; \
    rmdir /app/redist; \
    ldconfig; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -f /tmp/ts3.tar.bz2

# Do NOT set TS3SERVER_LICENSE here: the user must accept the license explicitly.

USER apps
COPY --chmod=0755 . /

EXPOSE 9987/udp 10011/tcp 30033/tcp

VOLUME /config

WORKDIR /config
