FROM ghcr.io/trueforge-org/java8:8@sha256:c3b5d515a5f2658b61680bbaff4cbb4a91b386f6e6f7ccab2eaafa5b7620d3ab

# set version label
ARG VERSION
# UNVERIFIED: Tomcat 9.x release that runs on Java 8 and this WAR; pin it before building
ARG TOMCAT_VERSION
ARG TARGETARCH
USER root

ENV CATALINA_HOME=/app/tomcat \
    CATALINA_TMPDIR=/tmp

RUN \
  echo "**** install tomcat ****" && \
  mkdir -p /app/tomcat && \
  curl -fL -o \
    /tmp/tomcat.tar.gz \
    "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
  curl -fL -o \
    /tmp/tomcat.tar.gz.sha512 \
    "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512" && \
  echo "$(cut -d' ' -f1 /tmp/tomcat.tar.gz.sha512)  /tmp/tomcat.tar.gz" | sha512sum -c - && \
  tar xzf \
    /tmp/tomcat.tar.gz -C \
    /app/tomcat --strip-components=1 && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/tomcat /usr/share/licenses/notarius && \
  cp /app/tomcat/LICENSE /usr/share/licenses/tomcat/LICENSE && \
  echo "**** clean tomcat defaults ****" && \
  rm -rf \
    /app/tomcat/webapps/* \
    /app/tomcat/logs \
    /app/tomcat/temp \
    /app/tomcat/work && \
  echo "**** install notarius ****" && \
  mkdir -p /app/notarius && \
  curl -fL -o \
    /app/notarius/ROOT.war \
    "https://github.com/agusalex/Notarius/releases/download/${VERSION}/ROOT.war" && \
  # UNVERIFIED: LICENSE file name and presence at the release tag
  curl -fL -o \
    /usr/share/licenses/notarius/LICENSE \
    "https://raw.githubusercontent.com/agusalex/Notarius/${VERSION}/LICENSE" && \
  chmod -R 755 /app && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config
