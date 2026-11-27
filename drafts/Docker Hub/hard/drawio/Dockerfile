# UNVERIFIED: no digest for this java11 tag is in the repo yet. Pin the digest from the java11 build output before merge.
FROM ghcr.io/trueforge-org/java11:11.0.29

ARG VERSION
ARG TOMCAT_VERSION

USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip && \
  echo "**** install tomcat ${TOMCAT_VERSION} ****" && \
  mkdir -p /tmp/dl /app/tomcat && \
  curl -fsSL -o /tmp/dl/tomcat.tar.gz \
    "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
  curl -fsSL -o /tmp/dl/tomcat.tar.gz.sha512 \
    "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512" && \
  (cd /tmp/dl && echo "$(awk '{print $1}' tomcat.tar.gz.sha512)  tomcat.tar.gz" | sha512sum -c -) && \
  tar xzf /tmp/dl/tomcat.tar.gz -C /app/tomcat --strip-components=1 && \
  rm -rf /app/tomcat/webapps/* && \
  echo "**** install draw.io ${VERSION} ****" && \
  curl -fsSL -o /tmp/dl/draw.war \
    "https://github.com/jgraph/drawio/releases/download/v${VERSION}/draw.war" && \
  mkdir -p /app/tomcat/webapps/ROOT && \
  unzip -q /tmp/dl/draw.war -d /app/tomcat/webapps/ROOT && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/drawio && \
  cp /app/tomcat/LICENSE /app/tomcat/NOTICE /usr/share/licenses/drawio/ && \
  curl -fsSL -o /usr/share/licenses/drawio/drawio-LICENSE \
    "https://raw.githubusercontent.com/jgraph/drawio/v${VERSION}/LICENSE" && \
  echo "**** cleanup ****" && \
  chmod -R a+rX /app && \
  apt-get purge -y --auto-remove unzip && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# CATALINA_HOME stays read-only; Tomcat writes to CATALINA_BASE in /tmp (start.sh copies conf and webapp there).
ENV HOME=/config \
  CATALINA_HOME=/app/tomcat \
  CATALINA_BASE=/tmp/tomcat \
  CATALINA_TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /config
