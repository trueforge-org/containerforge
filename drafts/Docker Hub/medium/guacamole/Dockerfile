FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:5651f46cebe5a42ff069da176dd7ab50f6b050169493fe06ebc1be2fe81cd15e

# set version label
ARG VERSION
ARG GUACAMOLE_SHA256
USER root

# GUACAMOLE_HOME is persistent under /config. Tomcat runs from /tmp so /app stays read-only.
ENV \
  BAN_ENABLED=true \
  ENABLE_FILE_ENVIRONMENT_PROPERTIES=true \
  GUACAMOLE_HOME=/config/guacamole \
  CATALINA_HOME=/usr/share/tomcat9 \
  CATALINA_BASE=/tmp/tomcat \
  CATALINA_TMPDIR=/tmp

# UNVERIFIED: the tomcat9 package is not confirmed in the ubuntu 26.04 archive. Pin its version as apps/valkey does once known.
RUN \
  echo "**** install tomcat 9 ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    tomcat9 && \
  echo "**** install guacamole ${VERSION} ****" && \
  mkdir -p /app/guacamole /usr/share/licenses/guacamole && \
  curl -fL -o \
    /tmp/guacamole.war \
    "https://dlcdn.apache.org/guacamole/${VERSION}/binary/guacamole-${VERSION}.war" && \
  echo "${GUACAMOLE_SHA256}  /tmp/guacamole.war" | sha256sum -c - && \
  mv /tmp/guacamole.war /app/guacamole/guacamole.war && \
  curl -fL -o \
    /usr/share/licenses/guacamole/LICENSE \
    "https://raw.githubusercontent.com/apache/guacamole-client/${VERSION}/LICENSE" && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

# TODO: the PostgreSQL JDBC driver (42.7.2, upstream bundles it) and the guacamole-auth-jdbc-postgresql extension are not added. Their download URLs are not in the facts yet.

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
