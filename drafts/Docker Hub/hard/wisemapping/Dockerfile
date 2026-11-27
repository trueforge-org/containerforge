# Backend (Spring Boot, Java 27) and frontend (React, Node 24) are built from two repos.
# Source tarballs are fetched with ADD and unpacked with tar, since ADD does not extract remote archives.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS backend-build
ARG BACKEND_REF
ARG TARGETARCH
USER root
ENV HOME=/tmp
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl maven \
    && rm -rf /var/lib/apt/lists/*
# Temurin JDK 27 (UNVERIFIED: verify the sha256 published by Adoptium at implementation time)
RUN case "${TARGETARCH}" in amd64) JARCH=x64 ;; arm64) JARCH=aarch64 ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac \
    && mkdir -p /opt/java/openjdk \
    && curl -fsSL "https://api.adoptium.net/v3/binary/latest/27/ga/linux/${JARCH}/jdk/hotspot/normal/eclipse" -o /tmp/jdk.tar.gz \
    && tar -xzf /tmp/jdk.tar.gz -C /opt/java/openjdk --strip-components=1 \
    && rm /tmp/jdk.tar.gz
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=/opt/java/openjdk/bin:$PATH
# BACKEND_REF is a develop commit; it does not map to a 6.x tag (UNVERIFIED which commit matches 6.0.11)
ADD https://github.com/wisemapping/wisemapping-open-source/archive/${BACKEND_REF}.tar.gz /tmp/backend.tar.gz
RUN mkdir -p /build/backend \
    && tar -xzf /tmp/backend.tar.gz -C /build/backend --strip-components=1 \
    && rm /tmp/backend.tar.gz
WORKDIR /build/backend/wise-api
RUN mvn clean package -DskipTests -Dmaven.repo.local=/tmp/m2 \
    -Dgit.branch=unknown -Dgit.commit.id.abbrev=unknown -Dgit.commit.id.full=unknown -Dgit.commit.time=unknown

# UNVERIFIED: pin the node:24 image digest at implementation time (no ContainerForge Node 24 base)
FROM node:24-trixie-slim@sha256:4d00acb4bcc42c454c4eb801526f7ad7f772ea3bd4fd168c5cc2e384abcbb9d4 AS frontend-build
ARG VERSION
ENV COREPACK_ENABLE_STRICT=0 NODE_OPTIONS=--max-old-space-size=4096 YARN_CACHE_FOLDER=/tmp/yarn COREPACK_HOME=/tmp/corepack
ADD https://github.com/wisemapping/wisemapping-frontend/archive/refs/tags/${VERSION}.tar.gz /tmp/frontend.tar.gz
RUN mkdir -p /build/frontend \
    && tar -xzf /tmp/frontend.tar.gz -C /build/frontend --strip-components=1 \
    && rm /tmp/frontend.tar.gz
WORKDIR /build/frontend
# Point the API base at the same origin, so nginx serves it
RUN sed -i 's|"url": "http://localhost:3000/api/restful/app/config"|"url": "/api/restful/app/config"|' packages/webapp/config.prod.json
# yarn version comes from the packageManager field of the repo (UNVERIFIED: 4.18.1 at 6.0.11)
RUN corepack enable && yarn install
RUN APP_CONFIG_TYPE=file:prod yarn build --concurrency 1
# Leave a <base> placeholder for the nginx sub_filter
RUN sed -i -E 's|<base [^>]*>||; s|<head>|<head><base>|' packages/webapp/dist/index.html

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
ARG TARGETARCH
USER root
# nginx is not in the base image. Unpinned, so record the installed version in the PR.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl nginx \
    && rm -f /etc/nginx/sites-enabled/default \
    && rm -rf /var/lib/apt/lists/*
# Temurin JRE 27 (UNVERIFIED: verify the sha256 published by Adoptium at implementation time)
RUN case "${TARGETARCH}" in amd64) JARCH=x64 ;; arm64) JARCH=aarch64 ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac \
    && mkdir -p /opt/java/openjdk \
    && curl -fsSL "https://api.adoptium.net/v3/binary/latest/27/ga/linux/${JARCH}/jre/hotspot/normal/eclipse" -o /tmp/jre.tar.gz \
    && tar -xzf /tmp/jre.tar.gz -C /opt/java/openjdk --strip-components=1 \
    && rm /tmp/jre.tar.gz
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=/opt/java/openjdk/bin:$PATH
COPY --from=backend-build /build/backend/wise-api/target/wisemapping-api.jar /app/wisemapping-api.jar
COPY --from=frontend-build /build/frontend/packages/webapp/dist/ /app/www/
COPY --from=backend-build /build/backend/LICENSE.md /usr/share/licenses/wisemapping/LICENSE.md
# The app directory is read-only at runtime
RUN chown -R root:root /app && chmod -R a+rX /app
ENV HOME=/tmp JAVA_OPTS="-XX:InitialRAMPercentage=60 -XX:MaxRAMPercentage=60"
EXPOSE 8080
VOLUME /config

# Copy configuration files into container (etc/nginx/nginx.conf, start.sh)
COPY --chmod=0755 . /

USER apps
CMD ["/start.sh"]
