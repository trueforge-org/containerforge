# Docker Hub: pawelmalak/flame

Source URL(s): https://hub.docker.com/r/pawelmalak/flame ; API: https://hub.docker.com/v2/repositories/pawelmalak/flame/ and /tags?page_size=10 (JSON used)
Date: fetched 2026-11-26

- Repo: namespace `pawelmalak`, name `flame`, description "Flame is self-hosted startpage for your server with built-in apps and bookmarks editors." pull_count 11736912, star_count 127. Registered 2021-06-01; last_updated 2026-04-24.
- Run (API full description): `docker run -p 5005:5005 -v /path/to/data:/app/data -e PASSWORD=flame_password flame`
- Compose: image `pawelmalak/flame:latest`, port 5005, mount to `/app/data`, `PASSWORD` env, restart `unless-stopped`; `/var/run/docker.sock` optional.
- Multiarch: tag `multiarch` (amd64, arm64, arm/v7) for Raspberry Pi.
- Tags (24 total; first 10 shown):

| Tag | Updated | Arch | Digest (short) |
| --- | --- | --- | --- |
| latest | 2026-04-24 | amd64 | sha256:7a5edc85... |
| 2.4.0 | 2026-04-24 | amd64 | sha256:7a5edc85... |
| multiarch2.4.0 | 2026-04-24 | amd64, arm64, arm/v7 | sha256:1b54ea03... |
| multiarch | 2026-04-24 | amd64, arm64, arm/v7 | sha256:1b54ea03... |
| 2.3.1 | 2023-07-23 | amd64 | sha256:ed331453... |
| multiarch2.3.1 | 2023-07-23 | amd64, arm64, arm/v7 | sha256:9f88b176... |
| multiarch2.3.0 | 2022-03-25 | amd64, arm64, arm/v7 | per-arch digests |
| 2.3.0 | 2022-03-25 | amd64 | sha256:512798f1... |
| multiarch2.2.2 | 2022-03-21 | amd64, arm64, arm/v7 | per-arch digests |
| 2.2.2 | 2022-03-21 | amd64 | sha256:03dd6206... |
