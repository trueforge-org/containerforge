
# BLOCKED (see plan.md section 10): edition, license, checksum and DB variables must be confirmed before merge
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# UNVERIFIED: which of these are already provided by the base image
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      mailcap \
      media-types \
 && rm -rf /var/lib/apt/lists/*

# download the arch-specific server tarball into /app
# UNVERIFIED: edition in the tarball (Enterprise or Team); add a sha256 check against the SLSA provenance before merge
RUN mkdir -p /app/mattermost \
 && curl -fsSL -o /tmp/mattermost.tar.gz \
      "https://releases.mattermost.com/${VERSION}/mattermost-${VERSION}-linux-${TARGETARCH}.tar.gz" \
 && tar xzf /tmp/mattermost.tar.gz -C /app/mattermost --strip-components=1 \
 && rm -f /tmp/mattermost.tar.gz

# writable paths are symlinks into /config so /app stays read-only
RUN rm -rf /app/mattermost/data /app/mattermost/logs /app/mattermost/plugins /app/mattermost/client/plugins \
 && ln -s /config/data /app/mattermost/data \
 && ln -s /config/logs /app/mattermost/logs \
 && ln -s /config/plugins /app/mattermost/plugins \
 && ln -s /config/client-plugins /app/mattermost/client/plugins \
 && chown -R root:root /app \
 && chmod -R 755 /app

# UNVERIFIED: license file name in the tarball root; copy every LICENSE/NOTICE file found there
RUN mkdir -p /usr/share/licenses/mattermost \
 && for f in /app/mattermost/LICENSE* /app/mattermost/NOTICE*; do \
      [ -e "$f" ] && cp "$f" /usr/share/licenses/mattermost/; \
    done \
 && rm -rf /tmp/*

ENV MM_SERVICESETTINGS_ENABLELOCALMODE=true \
    MM_INSTALL_TYPE=docker

# run as 568
USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 8065
VOLUME /config
