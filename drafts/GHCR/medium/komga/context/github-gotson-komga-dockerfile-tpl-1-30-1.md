# Upstream Dockerfile template: gotson/komga 1.30.1

Source URL(s) + date: https://raw.githubusercontent.com/gotson/komga/1.30.1/komga/docker/Dockerfile.tpl (fetched 2026-11-27). Template: `{{distributionArtifactFile}}` is substituted at build by the upstream build.
Failed: https://api.github.com/repos/gotson/komga (403) and https://api.github.com/repos/gotson/komga/releases/latest (403). Not retried; no alternative fetched.

## Build stages
1. `FROM eclipse-temurin:17-jre AS builder`: `ARG JAR={{distributionArtifactFile}}`, copies `assembly/${JAR}` to `application.jar`, runs `java -Djarmode=tools -jar application.jar extract --layers --destination extracted`.
2. `build-amd64`: `FROM ubuntu:26.04`, `JAVA_HOME=/opt/java/openjdk`, copies JRE from `eclipse-temurin:25-jre`. apt installs: ca-certificates locales libjxl-dev libheif-dev libwebp-dev wget curl. Locale en_US.UTF-8. Downloads `https://github.com/pgaskin/kepubify/releases/latest/download/kepubify-linux-64bit` to /usr/bin/kepubify (unpinned). `LD_LIBRARY_PATH` += /usr/lib/x86_64-linux-gnu.
3. `build-arm64`: same as amd64, kepubify-linux-arm64, LD_LIBRARY_PATH += /usr/lib/aarch64-linux-gnu.
4. `build-arm`: `FROM eclipse-temurin:17-jre` (JDK 21 dropped arm32), kepubify-linux-arm. Comment: arm32 support dropped in JDK 21.
5. `runner`: `FROM build-${TARGETARCH}`.

## Runner
- `VOLUME /config`, `WORKDIR /app`.
- COPY from builder: `extracted/dependencies/`, `spring-boot-loader/`, `snapshot-dependencies/`, `application/` into `/app`.
- ENV: `KOMGA_CONFIGDIR=/config`, `LANG=en_US.UTF-8`, `LANGUAGE=en_US:en`, `LC_ALL=en_US.UTF-8`.
- `ENTRYPOINT ["java", "-Dspring.profiles.include=docker", "--enable-native-access=ALL-UNNAMED", "-jar", "application.jar", "--spring.config.additional-location=file:/config/"]`
- `EXPOSE 25600`.
- LABEL source https://github.com/gotson/komga.

## Runtime deps
- Java: Temurin 25 JRE (copied from `eclipse-temurin:25-jre`) on amd64/arm64 stages; Temurin 17 on the arm stage (see Gotchas).
- kepubify binary (ebook conversion), libjxl, libheif, libwebp.

## User/UID
- No USER set in template.

## Healthcheck
- None in template.

## Version/asset naming
- Jar asset per plan: `komga-${VERSION}.jar` (plan, not verified here). Template uses `{{distributionArtifactFile}}`.

## Gotchas
- kepubify fetched from `releases/latest` (unpinned, changes without a Komga version bump).
- `build-arm` stage uses Temurin 17 and has no ubuntu base; the runner uses `build-${TARGETARCH}` so arm (32-bit) selects that stage.
- Template is pinned to 1.30.1; re-check against 1.30.2 (plan already notes this).
