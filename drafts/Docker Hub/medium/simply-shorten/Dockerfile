FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
USER root

# UNVERIFIED: openjdk-17-jdk-headless must exist in the 26.04 archive; pin it when checked.
# Build happens here because the java17 base ships only a JRE.
RUN echo "*** Installing build tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends git openjdk-17-jdk-headless && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: repo ships a Gradle wrapper; upstream Dockerfile used `gradle build`.
RUN echo "*** Building simply-shorten ${VERSION} ***" && \
  git clone --depth 1 --branch "${VERSION}" https://gitlab.com/draganczukp/simply-shorten /tmp/src && \
  cd /tmp/src && \
  ./gradlew build --no-daemon

FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION
USER root

ENV HOME=/config

RUN echo "*** Installing simply-shorten ***" && \
  mkdir -p /app /usr/share/licenses/simply-shorten && \
  chown -R apps:apps /app && chmod -R 755 /app

COPY --from=build /tmp/src/build/libs/*.jar /app/application.jar
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/simply-shorten/LICENSE

RUN chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 4567

VOLUME /config
WORKDIR /config
