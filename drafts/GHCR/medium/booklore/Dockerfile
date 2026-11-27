# Build stage: compile the Angular UI and the Spring Boot jar (the UI is bundled into the jar as static resources).
# Only the jar, the unrar helper and the LICENSE are copied into the runtime image.
# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION

USER root

# UNVERIFIED: openjdk-25-jdk-headless and nodejs (Node 24 is needed by booklore-ui) are not confirmed in the Ubuntu 26.04 archive.
# UNVERIFIED: gradle 9.3.1 is not in the Ubuntu archive. Use the repo's gradle wrapper if booklore-api ships one.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        openjdk-25-jdk-headless \
        nodejs \
        npm \
    && rm -rf /var/lib/apt/lists/*

# Keep every build cache in /tmp.
ENV HOME=/tmp \
    GRADLE_USER_HOME=/tmp/gradle \
    npm_config_cache=/tmp/npm

RUN mkdir -p /src && \
    curl -fsSL -o /tmp/booklore.tar.gz "https://github.com/booklore-app/booklore/archive/refs/tags/${VERSION}.tar.gz" && \
    tar xzf /tmp/booklore.tar.gz -C /src --strip-components=1 && \
    rm -f /tmp/booklore.tar.gz

# Angular UI, copied into the Spring Boot static resources as upstream does.
WORKDIR /src/booklore-ui
RUN npm ci --force && \
    npm run build -- --configuration=production && \
    mkdir -p /src/booklore-api/src/main/resources/static && \
    cp -r /src/booklore-ui/dist/booklore/browser/. /src/booklore-api/src/main/resources/static/

# Inject the version without the leading v. Upstream uses yq here. This sed targets the verified
# `app.version: 'development'` line instead, because the Ubuntu yq package may not be the same tool.
# UNVERIFIED: the exact quoting of that line in application.yaml at the tag.
RUN sed -i "s/version: 'development'/version: '${VERSION#v}'/" \
      /src/booklore-api/src/main/resources/application.yaml

WORKDIR /src/booklore-api
RUN gradle clean build -x test --no-daemon --parallel && \
    mkdir -p /build && \
    cp build/libs/booklore-api-0.0.1-SNAPSHOT.jar /build/app.jar

# Runtime stage. The java25 base is a JRE (Temurin), which is enough for java -jar.
# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:3db5983d5bd504865ac842efb282bcbdbd286adbc116fc18645ec3c433eba44a

ARG TARGETARCH

ENV JAVA_TOOL_OPTIONS="-XX:+UseG1GC -XX:+UseCompactObjectHeaders -XX:+UseStringDeduplication -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError" \
    BOOKLORE_PORT=6060 \
    DATABASE_HOST=mariadb \
    DATABASE_PORT=3306 \
    DATABASE_NAME=booklore \
    DATABASE_USERNAME=root

USER root

COPY --from=builder /build/app.jar /app/app.jar
COPY --from=builder /src/LICENSE /usr/share/licenses/booklore/LICENSE
COPY --from=builder /src/docker/unrar/unrar-${TARGETARCH} /usr/local/bin/unrar

# The app hard-codes /app/data and /bookdrop. Link them into /config at build time, so the
# runtime never writes to /app or to the root filesystem. The targets are created by start.sh.
# UNVERIFIED: unrar is glibc and the redistribution terms of the bundled binary still need checking.
RUN chmod 0755 /usr/local/bin/unrar && \
    ln -s /config/data /app/data && \
    ln -s /config/bookdrop /bookdrop

USER apps
COPY --chmod=0755 . /

EXPOSE 6060

VOLUME ["/config"]

CMD ["/start.sh"]
