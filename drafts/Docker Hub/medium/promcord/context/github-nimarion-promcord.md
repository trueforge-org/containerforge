# GitHub: nimarion/promcord (Dockerfile)

Source URL(s):
- https://raw.githubusercontent.com/nimarion/promcord/master/Dockerfile
Fetched: 2026-11-27

## Build (multi-stage Dockerfile, verbatim essentials)
| Stage | Base | Steps |
| --- | --- | --- |
| build | maven:3.8.1-adoptopenjdk-16 | copy src/ and pom.xml to /usr/src/app; `mvn -f /usr/src/app/pom.xml clean package` |
| runtime | openjdk:16-jdk-slim | copy `target/promcord-*-SNAPSHOT-shaded.jar` to `promcord.jar` |

- ENTRYPOINT: `["java", "-jar", "promcord.jar"]`
- No EXPOSE, no USER, no VOLUME, no ENV in the Dockerfile.

## Gotchas
- Base images are old (JDK 16 / openjdk:16 / maven 3.8.1); the jar name depends on a `-SNAPSHOT-shaded.jar` pattern.
- Runtime needs `DISCORD_TOKEN` (see README).
- Dockerfile is not in the Biospheere-owned repo variant named in the README.

## Failures
- https://api.github.com/repos/nimarion/promcord/releases/latest returned 404 (Not Found). No alternative tried for releases; see README.md.
