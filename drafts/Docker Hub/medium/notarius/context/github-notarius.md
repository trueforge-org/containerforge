# GitHub: agusalex/Notarius (upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/agusalex/Notarius/master/Dockerfile (2026-11-26)
- https://github.com/agusalex/Notarius/blob/master/Dockerfile (2026-11-26; same file as raw, not parsed separately)
- https://github.com/agusalex/Notarius (repo root, not fetched directly)

## What it is
Java web app packaged as a WAR, deployed in Tomcat.

## Dockerfile (master, full content)
```
# we are extending everything from tomcat:8.0 image ...
FROM tomcat:jre8-alpine
MAINTAINER agusalex
# COPY path-to-your-application-war path-to-webapps-in-docker-tomcat
RUN rm -rf /usr/local/tomcat/webapps/
COPY target/Notarius-1.0.3-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
```

## Build steps / deps
- Base: `tomcat:jre8-alpine` (Tomcat on Java 8, Alpine/musl).
- Expects a prebuilt WAR at `target/Notarius-1.0.3-SNAPSHOT.war` in build context (no Maven/build stage in Dockerfile).
- Removes `/usr/local/tomcat/webapps/`, then copies WAR as `ROOT.war` (app served at `/`).

## Runtime deps
- Java 8 (JRE), from base image.

## Entrypoint/flags
- Inherited from tomcat base image (not overridden).

## Ports
- Not declared in Dockerfile. Tomcat default 8080 (inherited, not verified in this repo).

## Volumes/paths
- `/usr/local/tomcat/webapps/ROOT.war`.

## User/UID
- Not set in Dockerfile (runs as tomcat base default, root).

## Healthcheck
- None.

## Version/asset naming
- WAR name `Notarius-1.0.3-SNAPSHOT.war`. No releases/tags checked.

## Gotchas
- The WAR must be built outside the Dockerfile; the repo has no build stage.
- Base image is Java 8 (old). Build is pinned to tomcat:jre8-alpine.
- Comment says tomcat:8.0 but FROM is tomcat:jre8-alpine.
