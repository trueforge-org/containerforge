# ankicommunity/anki-devops-services

**Source URL(s) + fetch date**
- https://github.com/ankicommunity/anki-devops-services (fetched 2026-11-26)

**What it is**
- "Anki Sync Server with Docker - and it works!". A collection of Docker-based self-hosting setups for Anki servers. GPL-3.0. Default branch `develop`. About 297 stars.
- Services listed: `djankiserv` (self-hosted Anki server with full API) and `anki-sync-server` (basic sync).

**Container and deployment content**
- Top-level folders: `.github`, `config`, `scripts`, `services`, plus a Makefile. `config/` holds env vars to source before using images and example configs.
- Image named on the page: `kuklinistvan/anki-sync-server:latest`, built for x86_64 (a different image from the Rust server in plan.md).
- Compose example: container `anki-container`, `restart: always`, port `27701:27701`, `data` volume at `/app/data`.
- Rebuild: `make build-devops SERVICE="anki-sync-server"`.
- Admin inside the container: `./ankisyncctl.py` with `adduser`, `deluser`, `lsuser`, `passwd`.

**Gotchas**
- Testing table dated 2020-02-06 (AnkiDesktop 2.1.19, AnkiDroid 2.9.1). Not archived, but documented testing is old.
- The chart draft's `/app/data` path matches this repo's compose example, not the Rust server's `/app` volume.
