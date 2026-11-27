
# java17 base as used by apps/nzbhydra2 (a Java 11 jar runs on a Java 17 JVM)
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION

ENV HOME=/config \
    ENABLE_SSL=false \
    ENABLE_LOGIN=false \
    BASE_URL=""

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends unzip \
 && rm -rf /var/lib/apt/lists/*

# Upstream publishes no checksum for the release asset.
# UNVERIFIED: sha256 to be computed at the build round and pinned as an ARG (see plan section 4).
RUN echo "*** Installing gaps ${VERSION} ***" && \
  mkdir -p /app/gaps /tmp/gaps /usr/share/licenses/gaps && \
  curl -fsSL -o /tmp/gaps/GapsAsJar.zip \
    "https://github.com/JasonHHouse/gaps/releases/download/${VERSION}/GapsAsJar-${VERSION#v}.zip" && \
  unzip -q /tmp/gaps/GapsAsJar.zip -d /tmp/gaps && \
  cp "$(find /tmp/gaps -name 'GapsWeb-*.jar' | head -n1)" /app/gaps/gaps.jar && \
  curl -fsSL -o /usr/share/licenses/gaps/LICENSE \
    "https://raw.githubusercontent.com/JasonHHouse/gaps/${VERSION}/LICENSE" && \
  rm -rf /tmp/gaps && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 8484

VOLUME /config
