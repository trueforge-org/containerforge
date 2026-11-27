# GitHub: fjudith/pwm-container alpine/Dockerfile

Source URL(s):
- https://raw.githubusercontent.com/fjudith/pwm-container/master/alpine/Dockerfile
Fetched: 2026-11-27

## Build stage
| Item | Value |
| --- | --- |
| base | docker.io/amd64/maven:3-openjdk-11 AS builder |
| ARG | APP_VERSION |
| source | git clone pwm-project/pwm at tag `v<APP_VERSION with . replaced by _>` (e.g. v2_0_8) |
| build | `mvn -B verify --file pom.xml`; artifact `webapp/target/` |

## Runtime stage
| Item | Value |
| --- | --- |
| base | docker.io/amd64/tomcat:9-jre8-alpine |
| ARG | APP_VERSION, ORGANISATION |
| LABEL | org.opencontainers.image.* (title PWM, source https://github.com/${ORGANISATION}/pwm-container) |
| ENV | MYSQL_DRIVER_VERSION=8.0.32, POSTGRES_DRIVER_VERSION=42.6.0, MONGODB_DRIVER_VERSION=3.9.1, MARIADB_DRIVER_VERSION=3.1.3, PWM_HOME=${CATALINA_HOME}/webapps/pwm, PWM_APPLICATIONPATH=/usr/share/pwm |
| user | group/user `pwm` uid/gid 1234 |
| packages | apk: xmlstarlet, curl, unzip (curl purged after driver downloads) |
| JDBC drivers | copied into ${CATALINA_HOME}/lib (mysql, postgres, mongo, mariadb jars from Maven/Sonatype/MariaDB URLs) |
| WAR | COPY builder `pwm/webapp/target/pwm-${APP_VERSION}.war` to /tmp, unzip into ${PWM_HOME}, remove war |
| server.xml | xmlstarlet edits: context path "/" -> docBase pwm, ROOT context removed to /ROOT, WatchedResource web.xml |
| entrypoint | COPY docker-entrypoint.sh to /; chmod +x |
| perms | chown -R pwm:pwm $CATALINA_HOME and $PWM_APPLICATIONPATH |
| USER | pwm |
| WORKDIR | $CATALINA_HOME |
| EXPOSE | 8080 |
| ENTRYPOINT | commented out |
| CMD | `["catalina.sh", "run"]` |

## Gotchas
- Build requires APP_VERSION matching a pwm-project git tag (dots become underscores in the tag).
- Entrypoint is not used by ENTRYPOINT (commented out); CMD runs Tomcat directly.
- Needs docker-entrypoint.sh in the build context (not fetched).
- Drivers are fetched at build time from external URLs (not verified here).
