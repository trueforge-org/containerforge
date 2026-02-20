

FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:3a1e87c9e6ddc9b2b8b35a88209671c52ab43d8f6a2039111d04e2ca367c675c

ARG VERSION

ENV JAVA_TOOL_OPTIONS="-Xmx256M"

USER root

# install needed packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      unzip \
 && rm -rf /var/lib/apt/lists/* \
 \
 # create directories
 && mkdir -p /app/bin /defaults /tmp_download \
 \
 # download nzbhydra2
 && curl -fsSL -o /tmp_download/nzbhydra2.zip \
      "https://github.com/theotherp/nzbhydra2/releases/download/${VERSION}/nzbhydra2-${VERSION#*v}-generic.zip" \
 && unzip -q /tmp_download/nzbhydra2.zip -d /tmp_download \
 && cp /tmp_download/lib/core-${VERSION#*v}-exec.jar /app/bin/nzbhydra2.jar \
 \
 # fetch default config and tweak
 && curl -fsSL -o /defaults/nzbhydra.yml \
      "https://raw.githubusercontent.com/theotherp/nzbhydra2/${VERSION}/core/src/main/resources/config/baseConfig.yml" \
 && sed -i 's/mapIpToHost: true/mapIpToHost: false/' /defaults/nzbhydra.yml \
 && sed -i 's/checkOpenPort: true/checkOpenPort: false/' /defaults/nzbhydra.yml \
 \
 # permissions and cleanup
 && chown -R root:root /app /defaults \
 && chmod -R 755 /app /defaults \
 && rm -rf /tmp_download/*

# copy your repo
COPY --chmod=0755 . /

# run as 568
USER apps
COPY container-test.yaml /container-test.yaml

WORKDIR /config
VOLUME ["/config"]

