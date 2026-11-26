# xavierh/external-ip (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/xavierh/external-ip
- Fetched 2026-11-26

**What it is**
Docker Hub listing for the image used by the TrueCharts chart. Publisher `xavierh`, 10K+ pulls listed.

**Install/build steps and build deps**
`docker pull xavierh/external-ip`. Compose example in the page: service `external_ip`, `restart: always`, `TZ=America/New_York` in examples.

**Version/release info and asset naming**
- Tags: only `latest` is listed (labelled the stable tag). Size about 37.8 MB.
- Last pushed: about 3 months before fetch (page relative date).
- Source repo linked: https://github.com/xavier-hernandez/docker-external-ip

**Arch support**
linux/amd64, linux/arm/v7, linux/arm64/v8.

**Gotchas**
- The image is published only as `latest`; no version tag is available to pin on Docker Hub.
- TrueCharts values reference `latest@sha256:eae953728e95a9536d0c85b941bbc55b66c64f62713402bd8f1d182073b921a8` (see truecharts summary).

**Contradictions with plan.md**
None found. plan.md does not claim a Docker Hub tag other than `latest`.
