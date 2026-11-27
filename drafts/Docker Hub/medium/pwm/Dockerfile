FROM ghcr.io/trueforge-org/java8:8@sha256:c3b5d515a5f2658b61680bbaff4cbb4a91b386f6e6f7ccab2eaafa5b7620d3ab

# set version label
ARG VERSION
# UNVERIFIED: Tomcat 9 release version and its SHA-512 from archive.apache.org (plan sections 4 and 10, not fetched).
# Both must be filled in before the first build; the build fails without them.
ARG TOMCAT_VERSION
ARG TOMCAT_SHA512
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip && \
  echo "**** fetch pwm ****" && \
  mkdir -p /app/tomcat /tmp/pwm && \
  tag="$(printf '%s' "${VERSION}" | tr '.' '_')" && \
  curl -fL -o /tmp/pwm/pwm.war \
    "https://github.com/pwm-project/pwm/releases/download/v${tag}/pwm-${VERSION}.war" && \
  # UNVERIFIED: upstream publishes no checksum for the WAR. Record its SHA-256 at first build (plan section 10).
  curl -fL -o /tmp/pwm/LICENSE \
    "https://raw.githubusercontent.com/pwm-project/pwm/v${tag}/LICENSE" && \
  echo "**** fetch and verify tomcat ****" && \
  curl -fL -o /tmp/pwm/tomcat.tar.gz \
    "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
  echo "${TOMCAT_SHA512}  /tmp/pwm/tomcat.tar.gz" | sha512sum -c - && \
  tar xzf /tmp/pwm/tomcat.tar.gz -C /app/tomcat --strip-components=1 && \
  echo "**** deploy pwm at / ****" && \
  # Deployed as ROOT (context /) instead of pwm, matching upstream's ROOT/server.xml edit. The chart's path is /, so no context change.
  rm -rf /app/tomcat/webapps/* && \
  mkdir -p /app/tomcat/webapps/ROOT && \
  unzip -q /tmp/pwm/pwm.war -d /app/tomcat/webapps/ROOT && \
  mkdir -p /usr/share/licenses/pwm && \
  cp /tmp/pwm/LICENSE /usr/share/licenses/pwm/LICENSE && \
  echo "**** move tomcat writable dirs to /tmp ****" && \
  rm -rf /app/tomcat/logs /app/tomcat/work /app/tomcat/temp && \
  ln -s /tmp/tomcat/logs /app/tomcat/logs && \
  ln -s /tmp/tomcat/work /app/tomcat/work && \
  ln -s /tmp/tomcat/temp /app/tomcat/temp && \
  chown -R apps:apps /app/tomcat && \
  chmod -R 755 /app/tomcat && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/* && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Tomcat and PWM paths; PWM configuration is persisted under /config.
ENV CATALINA_HOME=/app/tomcat \
    CATALINA_TMPDIR=/tmp \
    PWM_HOME=/app/tomcat/webapps/ROOT \
    PWM_APPLICATIONPATH=/config/pwm \
    JAVA_OPTS="-Djava.io.tmpdir=/tmp"

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
