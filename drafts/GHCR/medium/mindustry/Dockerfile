# Base as used by apps/java17 siblings (Mindustry needs JDK 17; the server jar targets 17).
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION
# sha256 of server-release.jar for v160.8, from the GitHub asset digest (plan.md section 1).
# A version bump must update this value; renovate does not change it.
ARG MINDUSTRY_SHA256=faeaf247a8b622de940181a96cb21cb20692d3c3da4e8ac3f79cb4af5059aa6c

ENV HOME=/config \
    DATA_DIR=/config/mindustry \
    SRV_NAME=DockerMindustry \
    GAME_PARAMS=""

USER root

# Prebuilt server jar from the release, verified against the pinned sha256. License shipped with it.
# UNVERIFIED: the LICENSE path at the v${VERSION} tag; check on the first build.
RUN set -eux; \
    mkdir -p /app/mindustry /usr/share/licenses/mindustry; \
    curl -fsSL -o /app/mindustry/server-release.jar \
      "https://github.com/Anuken/Mindustry/releases/download/v${VERSION}/server-release.jar"; \
    echo "${MINDUSTRY_SHA256}  /app/mindustry/server-release.jar" | sha256sum -c -; \
    curl -fsSL -o /usr/share/licenses/mindustry/LICENSE \
      "https://raw.githubusercontent.com/Anuken/Mindustry/v${VERSION}/LICENSE"; \
    chown -R root:root /app /usr/share/licenses/mindustry; \
    chmod -R 755 /app /usr/share/licenses/mindustry

USER apps
COPY --chmod=0755 . /

EXPOSE 6567/tcp
EXPOSE 6567/udp
VOLUME /config
WORKDIR /config
