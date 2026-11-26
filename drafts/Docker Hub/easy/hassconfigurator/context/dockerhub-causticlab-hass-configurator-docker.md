# causticlab/hass-configurator-docker (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/causticlab/hass-configurator-docker
- Fetched 2026-11-26

**What it is**
Docker image of the hass-configurator Home Assistant config editor. 10M+ pulls, 36 stars, about 37.6 MB.

**Tags and architectures**
- Only `latest` listed. Versions follow semver; multi-arch images since 0.4.1; architecture-only tags since 0.3.3.
- Architectures: x86 64-bit and ARM (Raspberry Pi), multi-arch.
- Last pushed about 8 months before fetch.
- The TrueCharts chart uses `x86_64@sha256:45a5a0527ca10da5744bbcf3a7909a0b77ae583e97fe0d28d0e5a8d50aa37689` (see the TrueCharts summary).

**Run example**
docker-compose snippet with image `causticlab/hass-configurator-docker:latest`, `restart: always`, network `hass-network`. Build locally with `--build-arg HC_BUILD_VERSION=<version>`.

**Env vars**
Since 0.3.3 settings can come from env vars; names not listed on the page.

**Volumes and ports**
- `./data/configurator-config:/config` must hold `settings.conf` (page wording; run.sh treats it as optional).
- `./data/config:/hass-config` is the Home Assistant config folder; `basepath` must match it.
- Optional Git over SSH: mount `id_rsa`, `id_rsa.pub`, `known_hosts` under `/root/.ssh/`, or use an HTTPS Git URL with a token.
- Port `3218:3218/tcp`.

**Contradictions with plan.md**
- plan.md section 10 says the image tag is a fixed x86_64 build. The Hub page lists multi-arch images, with the x86_64 tag being architecture-specific. Not a conflict: plan.md's arm64 claim concerns pip installs, not this image.
- plan.md section 1 says the draft's image is "2021-era". The page says the latest push was about 8 months before fetch. Unverified (commit date not read).
