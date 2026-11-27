# GitHub: ajanata/PretendYoureXyzzy (upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/ajanata/PretendYoureXyzzy/master/README.md
- https://api.github.com/repos/ajanata/PretendYoureXyzzy/releases/latest (HTTP 404)
- Fetched 2026-11-27

## What it is
- "Pretend You're Xyzzy" (PYX): Cards Against Humanity clone, server plus web client.
- Project is retired; author will not return to the code. Server still running.

## Build and run (README)
- Java web app built with Maven (not Gradle).
- Build: `mvn clean package war:war` in project dir.
- Jetty dev run: `mvn clean package war:exploded jetty:run`, plus `-Dmaven.buildNumber.doCheck=false -Dmaven.buildNumber.doUpdate=false`.
- README: "only known to work with Tomcat 7, all other versions are unsupported."
- Third-party Docker package mentioned: `emcniece/dockeryourxyzzy:dev` (port 8080 mapping in example).

## Ports
- Not stated; Docker example maps 8080.

## Config/data
- `build.properties`: key `geoip.db` points to a GeoLite2-City `.mmdb` (optional, GeoIP only).
- GeoIP data from MaxMind `GeoLite2-City.mmdb.gz`.
- No other data directories or env vars mentioned.

## License
- Details in `WebContent/license.html` (README does not name it). GitHub SPDX per plan: BSD-2-Clause.

## Releases
- `releases/latest`: HTTP 404 (no GitHub releases). Source only; pin commit SHA.

## Gotchas
- Tomcat 7 stated as the only known-working servlet container; packaging image uses Tomcat 10.1 (JDK 11). Conflict unresolved by these sources.
- Alternate fetch of the same repo not attempted (budget).
