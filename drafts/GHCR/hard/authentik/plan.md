# authentik — implementation plan
> Source: ./draft.md · Target: apps/authentik/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2026.8.6`. GitHub release tag is `version/2026.8.6` (published 2026-11-20). The tag carries a `version/` prefix. Source: https://api.github.com/repos/goauthentik/authentik/releases/tags/version/2026.8.6 |
| Renovate | `// renovate: datasource=github-releases depName=goauthentik/authentik versioning=semver`. The `version/` tag prefix needs an `extractVersion` rule in renovate. Exact renovate config: UNVERIFIED (renovate not run). |
| License | UNVERIFIED for SPDX. GitHub reports `NOASSERTION`. The LICENSE header says "Copyright (c) 2023 Jens Langhammer", `website/` is CC BY-SA 4.0, and `authentik/enterprise/` has its own license. The core license text after the header was not read. Source: https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684fcb0cccfe78888a12df1df1ad938be/LICENSE |
| Source URL | https://github.com/goauthentik/authentik |
| Standalone server binary | None. Release assets include `server.oci.tar` only. The server must come from the source tree or from `COPY --from=ghcr.io/goauthentik/server:2026.8.6`. |
| Outpost binaries (release assets) | `authentik-outpost-ldap_linux_amd64` sha256 `e54f6e3208867303bda866cf3e71b535b6e0e640c6cd52fdcf6b717caa2ebc0c` (29926815 bytes); `authentik-outpost-ldap_linux_arm64` sha256 `d0d86e1e26c4282fcd672a062687459cbf5a699a0eef413b0bc6852fb53c8a6e`. Radius: `authentik-outpost-radius_linux_{amd64,arm64}`. Proxy: `authentik-outpost-proxy-x86_64-unknown-linux-gnu`, `authentik-outpost-proxy-aarch64-unknown-linux-gnu`. Digests from the GitHub release asset API. Source: `gh api repos/goauthentik/authentik/releases/tags/version/2026.8.6`. |
| Checksum source | GitHub asset `digest` field (sha256). No `SHA256SUMS` asset is published for this release. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/Dockerfile. Stages: `pnpm` (ghcr.io/pnpm/pnpm:11.20.0), `node-builder` (node:26.12.1-trixie-slim, builds `web/`), `geoip` (ghcr.io/maxmind/geoipupdate:v8.0.0), `rust-builder` and `rust-toolchain` on `ghcr.io/goauthentik/fips-debian:trixie-slim-fips`, `uv` 0.13.4, `python-base` `ghcr.io/goauthentik/fips-python:3.14.10-p1-slim-trixie-fips`. Final stage: apt `libpq5 libmaxminddb0 ca-certificates libkadm5clnt-mit12 libkadm5clnt7t64-heimdal libltdl7 libxslt1.1`; user `authentik` uid 1000; dirs `/certs /data /media /blueprints /ak-root /authentik/.ssh`; `ln -s /media /data/media`; copies `/ak-root/.venv`, `/web/dist`, `/web/authentik`, `/bin/authentik` (Rust), `/geoip`, `/blueprints`, `/lifecycle`, `/manage.py`; `USER 1000`; `ENV TMPDIR=/dev/shm/ PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 GOFIPS=1 RUST_BACKTRACE=full`; `HEALTHCHECK ... CMD ["ak","healthcheck"]`; `ENTRYPOINT ["dumb-init","--","ak"]`. |
| Ports | `9000/tcp` http and `9443/tcp` https. Source: https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684fcb0cccfe78888a12df1df1ad938be/authentik/lib/default.yml (`listen.http: [::]:9000`, `listen.https: [::]:9443`). |
| Env vars | Config keys come from `authentik/lib/default.yml` as `AUTHENTIK_*`. Full runtime list: UNVERIFIED (not read). Build-time only: `GEOIPUPDATE_EDITION_IDS`, `GEOIPUPDATE_VERBOSE`, `GEOIPUPDATE_ACCOUNT_ID_FILE` (geoip stage, not runtime). |
| arm64 | Outposts: yes (release assets). Server: upstream builds it per platform; a ContainerForge build for arm64 is UNVERIFIED. |
| Dependencies in ContainerForge | `apps/postgresql` exists (hard, per draft). `apps/k8s-sidecar` exists. Missing: `geoipupdate`, `ldap`, `radius`, `proxy` (checked against `apps/`). |

## 2. Target layout

Two options. Decide before writing files (section 10).

Option A (recommended for PR 1): `apps/authentik/` with `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. Copies the compiled server from the upstream image (`COPY --from`).

Option B: the same five files, but built from source inside ContainerForge (pnpm web build, uv Python deps, Rust `authentik` binary).

No `defaults/`, `etc/`, `health/`, `root/` planned. Add `defaults/` only if a blueprint seed is needed. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Option A needs a Python 3.14 runtime. The upstream venv and interpreter are built for Python 3.14.10. ContainerForge `apps/python` is 3.15.2 (`ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`). A venv from 3.14 does not run on 3.15 without a rebuild. Eight other apps use `ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232`, so a 3.14 minor image is consumed in the repo (patch 3.14.8 vs upstream 3.14.10; same minor, compatibility UNVERIFIED). This is the main blocker (section 10).

Base choice for the final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` plus a Python 3.14 interpreter, or a Python 3.14 base if one exists in ContainerForge (a `python:3.14.8` image is used by other apps, see above; whether it fits the 3.14.10 venv is UNVERIFIED). Closest sibling: `apps/bazarr` for Python-app layout.

## 4. Dockerfile

Option A steps:

1. `ARG VERSION`. `FROM ghcr.io/goauthentik/server:2026.8.6@sha256:<digest> AS upstream` (digest UNVERIFIED: not fetched). Upstream image is the only source of the compiled server.
2. Final stage: the base from section 3 (`ubuntu` plus Python 3.14 is UNVERIFIED). `USER root`.
3. apt: `libpq5 libmaxminddb0 ca-certificates libkadm5clnt-mit12 libltdl7 libxslt1.1` (copied from upstream list). Pin nothing: these are runtime libs, not the app.
4. `COPY --from=upstream /ak-root/.venv /ak-root/.venv`, `/authentik`, `/lifecycle`, `/blueprints`, `/manage.py`, `/pyproject.toml`, `/schemas`, `/locale`, `/bin/authentik`, `/web/dist`, `/web/authentik`, `/packages`, `/geoip`.
5. `ln -s /media /data/media`. Create `/certs /data /media /blueprints` owned by `apps`.
6. `ENV TMPDIR=/tmp PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 GOFIPS=1 RUST_BACKTRACE=full`. Keep `TMPDIR` in `/tmp` (upstream sets `/dev/shm/`; `/dev/shm` may be absent in ContainerForge: UNVERIFIED).
7. License: copy the core LICENSE to `/usr/share/licenses/authentik/LICENSE`. Keep `website/` and `enterprise/` notices in the same directory.
8. `USER apps` then `COPY --chmod=0755 . /`, `EXPOSE 9000 9443`, `VOLUME /config`.

Option B is a multi-stage build (pnpm + node 26 for `web/`, uv for Python deps, Rust `authentik` binary). Large, and needs the FIPS base images, which ContainerForge does not provide (UNVERIFIED that they are usable). Not recommended for PR 1.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "authentik" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=goauthentik/authentik versioning=semver
  default = "2026.8.6"
}

variable "LICENSE" { default = "UNVERIFIED-MIT-OR-SEE-LICENSE" }
variable "SOURCE" { default = "https://github.com/goauthentik/authentik" }
```

Set `LICENSE` only after reading the core LICENSE text. Standard targets and `group "default"` copied from `apps/bazarr`. Validate with `docker buildx bake --print`. The Dockerfile must consume `VERSION` through `ARG VERSION`, and the upstream `FROM` tag must match `2026.8.6`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/goauthentik/authentik"
ports:
  - port: 9000
    protocol: tcp
    required: false
  - port: 9443
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  # add AUTHENTIK_* entries only after reading the real names in authentik/lib/default.yml
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
```

Notes: `9443` only if the image really serves TLS on that port with the default config (UNVERIFIED: the default config may need certs in `/certs`). Dependencies: `postgresql` (exists). `k8s-sidecar` is in the chart but not a hard requirement, so leave it out of `dependencies:`.

## 7. start.sh

- Upstream entrypoint is `ak`. `start.sh` runs `exec ak server` or `exec dumb-init -- ak worker`? UNVERIFIED: the upstream `ak` subcommand map was not read. Decide the process model after reading `lifecycle/ak` (section 10).
- Idempotent: create `/config/media` and `/config/certs` only when missing. Do not write `/app` or the venv.
- Caches to `/tmp`. Keep secrets out of files and the process list (read `AUTHENTIK_SECRET_KEY`, and the DB password, from env).
- `exec` the final process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
tcp:
- port: '9000'
http:
- port: '9000'
  path: /-/health/live/
filePaths:
- /ak-root/.venv/bin/python
- /authentik
- /web/dist
- /usr/share/licenses/authentik/LICENSE
```

- Test runs without env. The server needs `AUTHENTIK_SECRET_KEY` and a reachable Postgres, so the server will not reach ready state in the test. Narrow to a process/tcp smoke check with the required comment from the build and run protocol, OR keep the test as a file check only. UNVERIFIED which the protocol allows here; decide with the database exception criteria (section 10).
- `/-/health/live/` path is UNVERIFIED (not read from the router).
- 9443 has no probe. Add a `tcp` probe only if the port is really opened without TLS config.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/data` (uid 1000, `/data/media` -> `/media`) | `/config/data` (persistent); `/media` -> `/config/media` via symlink or config |
| `/certs` | `/config/certs` (persistent) |
| `/blueprints` (read) | `/blueprints` read-only, or `/config/blueprints` if user blueprints are needed |
| `/authentik/.ssh` | `/tmp/.ssh` (ephemeral), `HOME=/tmp` |
| `TMPDIR=/dev/shm/` | `TMPDIR=/tmp` |
| `/geoip` (build-time GeoIP DB) | `/config/geoip` (populated by `geoipupdate`, missing dependency) |

UID: upstream is 1000. ContainerForge `apps` user UID is UNVERIFIED against 1000. Do not change the base UID.

## 10. Risks, caveats and open questions

- **Blocker 1, Python version mismatch.** Upstream venv is for Python 3.14.10. ContainerForge `python` base is 3.15.2. Option A needs a Python 3.14 runtime only at patch 3.14.8 (other apps' `FROM`; the 3.14.10 match is UNVERIFIED). Resolve before writing the Dockerfile.
- **Blocker 2, process model.** The `ak` entrypoint runs server and worker from one image. The ContainerForge single-process model needs a supervised start (one `exec` per container). UNVERIFIED how `ak` chooses a role. Read `lifecycle/ak` before writing `start.sh`.
- **Blocker 3, missing dependencies.** `geoipupdate`, `ldap`, `radius`, `proxy` have no ContainerForge app. Without ldap/proxy outposts, the chart's features are missing. The main server alone is a partial deployment. Document in the PR.
- **Blocker 4, test database.** A working server needs Postgres. The test runs without env and without a DB. Narrowed assertions must follow the database exception (all three criteria apply: hard `postgresql` dependency, will not start without it, not feasible to wire a sidecar DB in one suite). Annotate the narrowing.
- License: core SPDX UNVERIFIED. Do not set `LICENSE` until read.
- Size: the server image is large (Python deps, Rust binary, web bundle). Not measured.
- Outpost binaries (ldap, radius, proxy) are separate images in the chart. Not part of this PR unless the team wants them.

## 11. Build and test steps

From `apps/authentik/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create authentik-probe-config`
4. `docker run --rm -d --name authentik-probe --read-only --tmpfs /tmp -e AUTHENTIK_SECRET_KEY=probe -v authentik-probe-config:/config authentik:2026.8.6`
5. Logs: expected readiness signal is the server listening on `0.0.0.0:9000` (UNVERIFIED wording). Without a DB the process is expected to fail: that is the documented blocker, not a pass. Record the actual log.
6. `forgetool containers test --image authentik:2026.8.6 --config ./container-test.yaml`
7. Cleanup: `docker rm -f authentik-probe; docker volume rm authentik-probe-config`.

## 12. PR checklist

- Branch `feat/add-authentik`, commit `feat(authentik): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`. Keep sections and checkboxes. Check only what applies.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: the full server with Postgres, the outposts, arm64, and the license.
- Do not check "Built container locally" unless the build ran.
