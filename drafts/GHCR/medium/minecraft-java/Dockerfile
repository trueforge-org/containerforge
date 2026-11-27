# Base as used by apps/airsonic-advanced and apps/nzbhydra2 (Java 21 matches the upstream default image).
FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:5651f46cebe5a42ff069da176dd7ab50f6b050169493fe06ebc1be2fe81cd15e

# VERSION is the image release (CalVer tag), matching docker-bake.hcl. The Minecraft version is the ENV VERSION below.
ARG VERSION
ARG TARGETARCH

# Helper tools. The release tag forms and asset names come from the plan; the tag form is UNVERIFIED.
# Each download is checked against the checksum file published with that release.
# UNVERIFIED: restify and mc-server-runner from the upstream image are not ported (pins not verified).
# UNVERIFIED: Log4jPatcher is not included; no checksum was published on the page reviewed.
ARG RCON_CLI_VERSION=1.7.9
ARG MC_MONITOR_VERSION=1.18.3
ARG MC_HELPER_VERSION=1.76.0

USER root

RUN set -eux; \
    base="https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VERSION}"; \
    asset="rcon-cli_${RCON_CLI_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    cd /tmp; \
    curl -fsSL -o "${asset}" "${base}/${asset}"; \
    curl -fsSL -o rcon-cli_checksums.txt "${base}/rcon-cli_${RCON_CLI_VERSION}_checksums.txt"; \
    grep -F "${asset}" rcon-cli_checksums.txt | sha256sum -c -; \
    tar -xzf "${asset}" -C /usr/local/bin rcon-cli; \
    rm -f /tmp/"${asset}" /tmp/rcon-cli_checksums.txt

RUN set -eux; \
    base="https://github.com/itzg/mc-monitor/releases/download/${MC_MONITOR_VERSION}"; \
    asset="mc-monitor_${MC_MONITOR_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    cd /tmp; \
    curl -fsSL -o "${asset}" "${base}/${asset}"; \
    curl -fsSL -o mc-monitor_checksums.txt "${base}/checksums.txt"; \
    grep -F "${asset}" mc-monitor_checksums.txt | sha256sum -c -; \
    tar -xzf "${asset}" -C /usr/local/bin mc-monitor; \
    rm -f /tmp/"${asset}" /tmp/mc-monitor_checksums.txt

# mc-image-helper ships as a tgz with a .sha256 file. UNVERIFIED: the .sha256 line format; the first field is taken as the hash.
RUN set -eux; \
    base="https://github.com/itzg/mc-image-helper/releases/download/${MC_HELPER_VERSION}"; \
    file="mc-image-helper-${MC_HELPER_VERSION}.tgz"; \
    cd /tmp; \
    curl -fsSL -o "${file}" "${base}/${file}"; \
    curl -fsSL -o "${file}.sha256" "${base}/${file}.sha256"; \
    echo "$(cut -d' ' -f1 "${file}.sha256")  ${file}" | sha256sum -c -; \
    tar -C /usr/share -xzf "${file}"; \
    ln -s "/usr/share/mc-image-helper-${MC_HELPER_VERSION}/bin/mc-image-helper" /usr/bin/mc-image-helper; \
    rm -f "/tmp/${file}" "/tmp/${file}.sha256"

# License of the image's scripts. UNVERIFIED: the LICENSE path at the release tag; check on the first build.
RUN set -eux; \
    mkdir -p /usr/share/licenses/minecraft-java; \
    curl -fsSL -o /usr/share/licenses/minecraft-java/LICENSE \
      "https://raw.githubusercontent.com/itzg/docker-minecraft-server/${VERSION}/LICENSE"; \
    chmod 0644 /usr/share/licenses/minecraft-java/LICENSE

# The Minecraft version (ENV VERSION) is separate from the image release (ARG VERSION).
ENV TYPE=VANILLA \
    VERSION=LATEST \
    EULA="" \
    MEMORY=1G

USER apps
COPY --chmod=0755 . /

EXPOSE 25565
VOLUME /config
WORKDIR /config
