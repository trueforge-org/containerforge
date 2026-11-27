# Anuken/Mindustry README and build.gradle (master)

Source URL(s) + date:
- https://raw.githubusercontent.com/Anuken/Mindustry/master/README.md (2026-11-27)
- https://raw.githubusercontent.com/Anuken/Mindustry/master/build.gradle (2026-11-27; first lines only, grep)

## What it is
Java/Kotlin tower-defense RTS. Server artefact is `server-release.jar`.

## Build/runtime facts
- README: JDK 17 required for building ("Other JDK versions will not work"). Server builds are bundled with each release; `gradlew server:dist` builds server jar at `/server/build/libs/server-release.jar`.
- build.gradle: Kotlin JVM plugin 2.3.20; version modifier default `release`; versionNumber `8`.

## Gotchas
- Container uses the prebuilt release jar, not a source build.
- Javadoc and wiki pages (mindustrygame.github.io) not fetched.
