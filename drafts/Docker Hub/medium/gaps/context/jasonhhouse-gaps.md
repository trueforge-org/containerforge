# JasonHHouse/gaps (Dockerfile + start.sh + README + LICENSE @ v0.10.4)

Source URL(s): https://github.com/JasonHHouse/gaps ; https://github.com/JasonHHouse/gaps/blob/v0.10.4/Dockerfile (raw fetched: https://raw.githubusercontent.com/JasonHHouse/gaps/v0.10.4/Dockerfile) ; https://raw.githubusercontent.com/JasonHHouse/gaps/v0.10.4/README.md ; https://raw.githubusercontent.com/JasonHHouse/gaps/v0.10.4/start.sh ; https://raw.githubusercontent.com/JasonHHouse/gaps/v0.10.4/LICENSE
Date: fetched 2026-11-26

## What it is
- Scans a Plex server's movie library and recommends films missing from it (via TMDB/MovieDB collections). Spring Boot server, jQuery/Bootstrap UI. Maintainer no longer actively develops it (Docker Hub note).

## Build (Dockerfile @ v0.10.4)
- Single stage: `FROM eclipse-temurin:11.0.14.1_1-jre`.
- ENV: `JAR_FILE=gaps.jar`, `ENABLE_SSL=false`, `ENABLE_LOGIN=false`, `BASE_URL=` (empty).
- RUN: `mkdir /usr/data` and `/usr/app`, chmod 777 both.
- COPY `GapsWeb/target/GapsWeb-0.10.4.jar` -> `/usr/app/gaps.jar` (prebuilt jar, not built in image); `movieIds.json` -> `/usr/data`; `start.sh` -> `/usr/app/`.
- WORKDIR `/usr/app`. `EXPOSE 8484`. `CMD ./start.sh` (shell form). No ENTRYPOINT, VOLUME, HEALTHCHECK, USER (runs as root).

## Runtime deps
- Java 11 JRE (temurin 11.0.14.1_1). TMDB API key (user supplied). Plex server (user supplied).

## Entrypoint/flags (start.sh @ v0.10.4)
- `#!/bin/sh`; reads `ENABLE_SSL`, `ENABLE_LOGIN`, `BASE_URL`, `JAR_FILE`; echoes them, then picks Spring profile:

| ENABLE_SSL | ENABLE_LOGIN | Profile |
| --- | --- | --- |
| true | true | ssl |
| true | not true | ssl-no-login |
| not true | true | no-ssl |
| not true | not true | no-ssl-no-login |

- Java line (SSL+login): `java -Xms256m -Xmx2048m -jar -Dspring.profiles.active=ssl -Dserver.servlet.context-path=$BASE_URL $JAR_FILE`
- Heap: -Xms256m, -Xmx2048m. Variables unquoted (values with spaces break).

## Env vars
| Var | Default | Meaning |
| --- | --- | --- |
| JAR_FILE | gaps.jar | jar name |
| ENABLE_SSL | false | selects ssl profiles |
| ENABLE_LOGIN | false | selects login profiles |
| BASE_URL | (empty) | servlet context path; UI at http://IP:8484/BASE_URL |

- TMDB key, Plex host/IP/port/token and network timeout are entered in the web UI (Settings), not env.

## Ports
- 8484/tcp (EXPOSE; web UI). README run example also `--expose 32400` (Plex, informational).

## Volumes/paths
| Path | Use |
| --- | --- |
| `/usr/data` | data dir (README: `-v /{localFolder}/gaps:/usr/data`); contains movieIds.json at build |
| `/usr/app` | app dir (jar, start.sh) |

## User/UID
- Root (no USER). Dirs chmod 777.

## Config files
- None documented; settings stored via web UI.

## Healthcheck
- None.

## Version/asset naming
- Jar `GapsWeb-0.10.4.jar`. GitHub release `v0.10.4` (2022-04-01), asset `GapsAsJar-0.10.4.zip` (Windows package).

## Arch
- Docker Hub tags: `latest`/`x64-v0.10.4` (amd64), `arm-v0.10.4` (arm64), `arm32v7-v0.10.4` (arm/v7), `ppc64le-v0.10.4`, `s390x-v0.10.4`, `risc-v0.10.4` (riscv64). README: ARM use `arm-latest`.

## License
- MIT, "Copyright (c) 2019 Jason H House".

## Gotchas
- Base eclipse-temurin 11 (EOL) pinned in Dockerfile.
- BASE_URL path must match UI URL.
- Chart/README: Folders tab not functional; only Plex search works.
