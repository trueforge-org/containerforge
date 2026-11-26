# influxdata.com downloads and product pages (Chronograf)

Source URL(s) + fetch date:
- https://www.influxdata.com/downloads/ (fetched 2026-11-26)
- https://www.influxdata.com/time-series-platform/chronograf (fetched 2026-11-26)

## Downloads page (Chronograf section)
- Latest: v1.11.8 (a "Chronograf Nightly (Unstable)" option also exists).
- amd64 deb: `https://dl.influxdata.com/chronograf/releases/chronograf_1.11.8_amd64.deb`, SHA256 `ca05ab9ccd1c35535fc3a853dc8964befb9271b4154c2155d2bc356cdfc3b36d`.
- arm64 deb: `https://dl.influxdata.com/chronograf/releases/chronograf_1.11.8_arm64.deb`, SHA256 `e10d11232714f940c23475facc86c751e7a8f7beb7f5875b98c5a67af0ac85d8`.
- Nightly: `https://dl.influxdata.com/chronograf/releases/chronograf_nightly_amd64.deb` (no SHA256 shown).
- Asset naming: `chronograf_<version>_<arch>.deb`, detached `.asc` next to it; arch `amd64` / `arm64`.
- GPG: the Chronograf section shows no signature details. The shared InfluxData archive key fingerprint `24C9 75CB A61A 024E E1B6 3178 7C3D 5715 9FC2 F927` (matches the key in the upstream Dockerfile). Banner notes InfluxData's package signing key is expiring (https://www.influxdata.com/blog/package-signing-key-rotation/). Key URL https://repos.influxdata.com/influxdata-archive.key.
- Page shows RPM and macOS tar archives too (not needed).

## Product page
- Describes Chronograf as "the user interface and administrative component of the InfluxDB 1.x platform". Features: 20+ dashboards, admin tool, auth via GitHub, Google, Auth0, Heroku, Okta, RBAC, Kapacitor alerting UI, log viewer.
- States no maintenance status, no current version, and no license. The draft's "maintenance mode" claim is NOT supported by this page.
- Docs link points at v1.7 docs.

## Gotchas
- Downloads page latest (1.11.8) is newer than the draft and plan pin (1.11.7). Plan.md section 10 already flags this.
- Signing key expiry banner: re-verify the key fingerprint if a future bump fails `gpg --verify`.
