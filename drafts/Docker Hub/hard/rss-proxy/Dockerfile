FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# Source stage: upstream publishes no release assets, the application only exists inside its image.
# The source image is amd64 only, so pin the platform to keep arm64 builds working.
# renovate: datasource=docker depName=damoeb/rss-proxy versioning=semver
# UNVERIFIED: pin the @sha256 digest of damoeb/rss-proxy:2.1.1 (docker buildx imagetools inspect). Keep the tag identical to VERSION.
# UNVERIFIED: /app/app.jar and /app/public are placeholder paths inside the source image. Confirm with `docker run --rm --entrypoint sh damoeb/rss-proxy:2.1.1 -c 'ls -la / /app /opt'` before the first build.
FROM --platform=linux/amd64 docker.io/damoeb/rss-proxy:2.1.1@sha256:c51cf8bf000822ee73de3d7e02b961f0aa34c18270bdb7f7af081a78df6bf0da AS source

FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  TZ=Etc/UTC \
  JAVA_TOOL_OPTIONS="-Xmx256M"

RUN \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/rss-proxy && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl && \
  curl -fL -o /usr/share/licenses/rss-proxy/LICENSE \
    "https://raw.githubusercontent.com/damoeb/rss-proxy/d91dbde/LICENSE" && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: copy the jar and the static UI from the source stage. Paths follow the placeholders above.
COPY --from=source --chown=568:568 /app/app.jar /app/rss-proxy.jar
COPY --from=source --chown=568:568 /app/public /app/public

RUN \
  echo "**** fix permissions ****" && \
  chown -R apps:apps /app && \
  chmod -R a+rX /app && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config
WORKDIR /config
