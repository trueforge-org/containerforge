# apache/guacamole-client: Dockerfile (pinned 0537c89 and tag 1.6.0)
Source URL(s): https://github.com/apache/guacamole-client/blob/0537c89cd783681b986ff8f8c4e0b97ec6873371/Dockerfile (= raw at same sha) ; https://raw.githubusercontent.com/apache/guacamole-client/1.6.0/Dockerfile (fetched 2026-11-26; both files identical, 106 lines)

## Build (stage 1: maven:3-eclipse-temurin-21 AS builder)
- apt: software-properties-common, Mozilla Firefox PPA (ppa:mozillateam/ppa); firefox installed for JS unit tests
- COPY guacamole-docker/{bin,build.d,entrypoint.d,environment} to /opt/guacamole/...
- `RUN /opt/guacamole/bin/build-guacamole.sh "$BUILD_DIR" /opt/guacamole` (BUILD_DIR=/tmp/guacamole-docker-BUILD)
- MAVEN_ARGUMENTS default "-DskipTests=false"
- Bundled JDBC drivers: MSSQL 9.4.1, MySQL 8.3.0, PostgreSQL 42.7.2

## Runtime (stage 2: tomcat:${TOMCAT_VERSION}-${TOMCAT_JRE})
- ARG TOMCAT_VERSION=9, TOMCAT_JRE=jdk21
- apt xmlstarlet (server.xml edits)
- WORKDIR /opt/guacamole; COPY --from=builder /opt/guacamole/ .
- User: groupadd/useradd guacamole, UID/GID ARG 1001 (system user, nologin shell, home created)
- USER guacamole
- ENV BAN_ENABLED=true, ENABLE_FILE_ENVIRONMENT_PROPERTIES=true, GUACAMOLE_HOME=/etc/guacamole
- EXPOSE 8080
- CMD ["/opt/guacamole/bin/entrypoint.sh"]

## Gotchas
- Image is built from source in the Dockerfile (not from a prebuilt WAR). Binary WAR download (dlcdn.apache.org guacamole-1.6.0.war) is listed in urls.txt but was not fetched (binary).
- guacd image is not built from this repo (separate image; guacamole-server not fetched).
