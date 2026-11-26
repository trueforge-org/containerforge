# sonatype/nexus-public README

**Source:** https://raw.githubusercontent.com/sonatype/nexus-public/master/README.md (fetched 2026-11-26)

## What it is
- Nexus Repository Core, the open source edition (EPL v1, LICENSE.txt). Formats: maven, raw, APT. Embedded H2 DB (small workloads).
- Community Edition adds npm, Docker, NuGet, PyPI and external PostgreSQL. Pro is commercial.

## Build
- Java 21; Maven wrapper `./mvnw clean install -Ppublic`
- Frontend: `corepack enable`, then `corepack yarn install` (Node 16.10+ corepack).
- Source tags: `release-{version}` (e.g. release-3.89.0-09).

## Run
- Output: public/selfhosted/assemblies/nexus-repository-core/target/assembly
- `java -jar bin/nexus-repository-core-*.jar`
- Creates sonatype-work dir on first run (admin credentials, DB, blobstore).
- Runtime Java not separately stated (Java 21 listed as build requirement).
