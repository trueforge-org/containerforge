# yacy upstream Dockerfile (docker/Dockerfile at eba3f94)

**Source URL(s):** https://github.com/yacy/yacy_search_server/blob/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/docker/Dockerfile (fetched via https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/docker/Dockerfile)
**Fetched:** 2026-11-26

## Stage 1: builder
- `FROM eclipse-temurin:24-jdk-noble AS builder`.
- RUN: apt-get update (retried up to 3 times, 5 s pause), install `ant`, `git`, `curl` (`--no-install-recommends`), clear `/var/lib/apt/lists/*`.
- `WORKDIR /opt`; `COPY . /opt/yacy_search_server/` (build context).
- RUN: `ant compile -f /opt/yacy_search_server/build.xml`, then remove `.git` (needed at build for the version, not at runtime).
- RUN: `sed` edits to `/opt/yacy_search_server/defaults/yacy.init`:
  - `adminAccountBase64MD5=` set to `MD5:8cffbc0d66567a0987a4aba1ec46d63c` (password `yacy`).
  - `adminAccountForLocalhost=` set to `false`.
  - `server.https=false` changed to `server.https=true`.

## Stage 2: app (final)
- `FROM eclipse-temurin:24-jdk-noble AS app`.
- LABEL maintainer (omitted).
- RUN: `adduser --system --group --no-create-home --disabled-password yacy`.
- `WORKDIR /opt`.
- `COPY --chown=yacy:yacy --from=builder /opt/yacy_search_server /opt/yacy_search_server`.
- `EXPOSE 8090 8443`.
- `VOLUME /opt/yacy_search_server/DATA`.
- `USER yacy`.
- `CMD ["/bin/sh","/opt/yacy_search_server/startYACY.sh","-f"]`.
- No ENTRYPOINT, ENV, ARG; no extra packages in the final stage.

## Usage in the header comments
- Build: `docker build -t yacy/yacy_search_server:latest -f Dockerfile ../`.
- Run: `docker run -d --name yacy -p 8090:8090 -p 8443:8443 -v yacy_data:/opt/yacy_search_server/DATA --log-opt max-size=200m --log-opt max-file=2 yacy/yacy_search_server:latest`.

## Gotchas for our build
- Upstream sets `server.https=true` and `adminAccountForLocalhost=false` at build time; the plan's approach (seeded config in `/config`) is needed to reproduce this without writing to `/app`.
- Upstream admin default `yacy` is baked in via the MD5 hash. Do not ship it (plan decision).
- The builder stage needs JDK + ant for `ant compile`; the plan uses a prebuilt tarball, so no builder is needed.
- Upstream runs the JVM under `startYACY.sh -f`; our `start.sh` should keep that foreground behaviour.
