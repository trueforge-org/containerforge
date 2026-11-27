# GitLab draganczukp/simply-shorten (Dockerfile, tags, license)

Source URL(s) + date:
- https://gitlab.com/draganczukp/simply-shorten/-/raw/1.1/Dockerfile
- https://gitlab.com/api/v4/projects/draganczukp%2Fsimply-shorten/repository/tags
- https://gitlab.com/draganczukp/simply-shorten/-/raw/master/LICENSE
- Fetched 2026-11-27

## Dockerfile at tag 1.1
```
FROM gradle:jdk14 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon

FROM openjdk:14.0-slim

EXPOSE 4567

RUN mkdir /app

COPY --from=build /home/gradle/src/build/libs/*.jar /app/application.jar

ENTRYPOINT ["java", "-jar","/app/application.jar"]
```
- Runs as root (no USER). No HEALTHCHECK. Two-stage build (`gradle:jdk14` -> `openjdk:14.0-slim`).

## Tags (GitLab API)
- 1.3 (commit 2023-10-11, created 2023-11-19), 1.2, 1.1, 1.0 (plus a bogus `'1.2'` entry with quotes)
- No Docker Hub tag for 1.2 or 1.3.

## License
- MIT, Copyright (c) 2020 Przemek Dragańczuk

## Version/asset naming
- Git tags are bare semver-like (`1.1`, `1.3`); no release assets seen.

## Gotchas
- Dockerfile at 1.1 is the Docker Hub 1.1 build source; `master` / 1.3 may differ (not fetched).
