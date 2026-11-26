# glauth/glauth (GitHub)

**Source URL(s) + fetch date**
- https://github.com/glauth/glauth (repo, draft source link)
- https://raw.githubusercontent.com/glauth/glauth/251ec3ef667e7e51f4b38c3f52c048f7f20dfc32/v2/docker/Dockerfile-standalone (draft's Dockerfile link, pinned commit)
- https://raw.githubusercontent.com/glauth/glauth/251ec3ef667e7e51f4b38c3f52c048f7f20dfc32/v2/docker/assets/start-standalone.sh (the `/v2/docker/start-standalone.sh` path returned 404; Dockerfile COPYs from `assets/`)
- https://raw.githubusercontent.com/glauth/glauth/251ec3ef667e7e51f4b38c3f52c048f7f20dfc32/v2/docker/assets/default-config-standalone.cfg (same reason)
- https://github.com/glauth/glauth/releases/tag/GLAuth-v2.5.5 (asset list did not load)
- https://raw.githubusercontent.com/glauth/glauth/GLAuth-v2.5.5/LICENSE
- Fetched 2026-11-26

**What it is**
Lightweight LDAP authentication server written in Go. Users and groups can come from a config file (local or S3), SQL, or be proxied to other LDAP servers. Backends can be chained (TOTP and Yubikey 2FA layered on top). MIT licensed.

**Install/build steps and build deps (upstream Dockerfile-standalone)**
- Build stage: `FROM alpine:latest AS build`; `apk add --no-cache git make busybox-static dumb-init`.
- Run stage: `FROM gcr.io/distroless/base-debian13 AS run`.
- `ARG TARGETPLATFORM`.
- COPY `assets/start-standalone.sh` to `/app/docker/start-standalone.sh`; `assets/default-config-standalone.cfg` to `/app/docker/default-config-standalone.cfg`; `assets/$TARGETPLATFORM/glauth` to `/app/glauth`.
- COPY from build stage: `dumb-init` to `/usr/bin/dumb-init`; busybox.static as `/bin/sh`, `/bin/ln`, `/bin/rm`.
- `RUN ln /bin/sh /usr/bin/cp && ln /bin/sh /usr/bin/mkdir && rm /bin/ln /bin/rm`.
- `EXPOSE 389 636 5555`.
- `ENTRYPOINT ["/usr/bin/dumb-init", "--"]`; `CMD ["/bin/sh", "/app/docker/start-standalone.sh"]`.
- No ENV, WORKDIR, USER, VOLUME or HEALTHCHECK.

**Runtime deps**
glibc (distroless base-debian13). The binary is built upstream; no runtime packages.

**Binaries/entrypoint/CLI flags**
- `/app/glauth -c <config>` (start script), `/app/glauth --version`.
- Other flags per the Hub page: `--ldap`, `--ldaps`, `--ldaps-cert`, `--ldaps-key`, `-r` (S3 region), `-K`/`-S` (S3 credentials), `-c` (config, also `s3://` URI).

**Start script behaviour (`assets/start-standalone.sh`)**
- If `/app/config/config.cfg` is missing: prints a message, `mkdir -p /app/config`, copies `/app/docker/default-config-standalone.cfg` to `/app/config/config.cfg`, exits 1 if the copy fails.
- Prints `/app/glauth --version`, then runs `/app/glauth -c /app/config/config.cfg`. Prints "GLauth has exited." afterwards.

**Env vars (table)**

| Name | Default | Notes |
| --- | --- | --- |
| `AWS_ACCESS_KEY_ID` | unset | Documented for S3-hosted config (alternative to `-K`). |
| `AWS_SECRET_ACCESS_KEY` | unset | Documented for S3-hosted config (alternative to `-S`). |
| (none for the server itself) | | No GLAUTH_* variables documented. |

**Ports**
- Upstream default config: LDAP `0.0.0.0:3893` (enabled), LDAPS `0.0.0.0:3894` (disabled), API `0.0.0.0:5555` (enabled, no TLS).
- Dockerfile `EXPOSE 389 636 5555`, which does not match the sample config's listen ports (389/636 are standard ports, not the sample's). The chart maps 389 and 636.

**Volumes/paths and persistent data**
- Config at `/app/config/config.cfg`. Upstream has no VOLUME instruction. Chart mounts `/app/config`.

**User/UID & permissions**
No USER instruction: runs as root in the upstream image (distroless default user is root in the base-debian13 image; not verified here).

**Config files and formats**
TOML. Sample `default-config-standalone.cfg` sections:
- `debug = true`; `syslog` and `watchconfig` commented out.
- `[ldap] enabled = true, listen = "0.0.0.0:3893"`.
- `[ldaps] enabled = false, listen = "0.0.0.0:3894", cert = "glauth.crt", key = "glauth.key"`.
- `[backend] datastore = "config", baseDN = "dc=glauth,dc=com"` (nameformat, groupformat, sshkeyattr commented out).
- `[behaviors]`: `IgnoreCapabilities = false`, `LimitFailedBinds = true`, `NumberOfFailedBinds = 3`, `PeriodOfFailedBinds = 10`, `BlockFailedBindsFor = 60`, `PruneSourceTableEvery = 600`, `PruneSourcesOlderThan = 600`.
- `[api] enabled = true, tls = false, listen = "0.0.0.0:5555", cert = "cert.pem", key = "key.pem"`.
- `[[groups]]`: `superheros` (5501), `svcaccts` (5502), `vpn` (5503, includes 5501).
- `[[users]]`: five sample accounts (`hackers`, `johndoe`, `serviceuser`, `otpuser`, `uberhackers`) with hashes, SSH key, OTP and Yubikey values. Not copied into the plan's seed.

**Healthcheck/readiness endpoints**
None in the Dockerfile. Chart uses TCP probes on 389 (not fetched).

**Version/release info and asset naming**
- Tag `GLAuth-v2.5.5`, marked Latest, released 2026-11-21 (commit 6563208, signed). Release asset list did not load, so asset names and SHA-256 digests could not be re-checked here.
- Upstream binaries for the standalone image come from the repo `assets/$TARGETPLATFORM/glauth`, not the release tarball.

**Arch support**
Dockerfile uses `TARGETPLATFORM`; Hub page says only linux 64-bit is tested in CI, other platforms cross-compiled "as-is".

**License**
MIT. LICENSE at `GLAuth-v2.5.5`: "MIT License", "Copyright (c) 2018 Ned McClain & Ben Yanke & Chris Ravenscroft".

**Gotchas**
- The sample config's `debug = true` and its users with public-style passwords must not ship as the default.
- The sample config's REST API is enabled on all interfaces without TLS.
- Pull requests target the `dev` branch (Hub page).

**Contradictions with plan.md**
- plan.md section 1 says the sample config listens on 3893, 3894 (LDAPS, disabled) and 5555 (API, enabled, no TLS). Confirmed.
- plan.md section 1 says ENTRYPOINT is dumb-init and the image runs `start-standalone.sh`. Confirmed (`ENTRYPOINT ["/usr/bin/dumb-init", "--"]`, `CMD ["/bin/sh", "/app/docker/start-standalone.sh"]`).
- plan.md section 1 says the start script copies the config to `/app/config/config.cfg` and runs `-c`. Confirmed.
- plan.md section 1 "UNVERIFIED: that the binary is statically linked" stays unverified here.
- plan.md section 1 gives release digests (amd64 `b0a27c...`, arm64 `d0a17a...`). Not re-verified: the release asset list did not load.
- plan.md section 1 says "Env vars: None documented". The Hub page documents `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for S3 config. Not a conflict with the plan's rule (no GLAUTH_* variables), but worth noting.
