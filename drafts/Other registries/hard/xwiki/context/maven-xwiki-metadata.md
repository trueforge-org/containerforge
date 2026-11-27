# maven.xwiki.org: xwiki-platform-distribution-war maven-metadata.xml

## Source URL(s) + date
- https://maven.xwiki.org/releases/org/xwiki/platform/xwiki-platform-distribution-war/maven-metadata.xml (fetched 2026-11-27)

## Facts
- `<latest>`: 9.10-rc-1 (metadata quirk; not a usable release pointer)
- `<release>`: 18.10.0-rc-1
- `lastUpdated`: 20261123160345
- 445 versions listed. Last entries include: 18.4.7, 18.4.8, 18.9.0-rc-1, 18.9.0, 18.10.0-rc-1.
- Pinned in Dockerfile: 18.9.0 (WAR URL `.../xwiki-platform-distribution-war/18.9.0/xwiki-platform-distribution-war-18.9.0.war`).

## Gotchas
- `<release>` is an RC (18.10.0-rc-1); do not use it as the image version.
- WAR asset naming: `xwiki-platform-distribution-war-<version>.war`.
