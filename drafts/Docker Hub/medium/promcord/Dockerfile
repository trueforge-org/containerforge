# build stage: compile the shaded jar from source (upstream publishes no release or image)
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
USER root

# UNVERIFIED: openjdk-17-jdk-headless and maven package names on ubuntu 26.04 (check with apt-cache policy).
RUN \
  echo "**** install jdk and maven ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    maven \
    openjdk-17-jdk-headless && \
  echo "**** fetch promcord ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/promcord.tar.gz \
    "https://github.com/nimarion/promcord/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/promcord.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** build ****" && \
  cd /tmp/src && \
  mvn -B -DskipTests -Dmaven.repo.local=/tmp/m2 package && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# runtime stage
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

# set version label
ARG VERSION
USER root

COPY --from=build /tmp/src/target/promcord-*-SNAPSHOT-shaded.jar /app/promcord/promcord.jar
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/promcord/LICENSE
RUN chown -R apps:apps /app/promcord && \
  chmod -R 755 /app/promcord

# copy local files
USER apps
COPY --chmod=0755 . /

# volumes (no ports: the bot is a Discord gateway client)
VOLUME /config

WORKDIR /config
