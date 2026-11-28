# solidping — implementation plan
> Source: ./draft.md · Target: apps/solidping/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.54.1` (GitHub release `v0.54.1`, published 2026-11-23). **The draft pins `0.52.0`, which is out of date.** Use `0.54.1`. NOTE: release `v0.55.0` was published 2026-11-25 (after this plan's research); the human must choose 0.54.1 or 0.55.0, and if 0.55.0 is chosen every hash and doc fact here must be re-checked (its amd64 sha256 is `c1313cd1682fb4bcef72dae4c99614d3a238b87280843430932a1b3fd61dccd5`, arm64 `a6864b067ae08360507914dcc9b4b73404e4ddf7e6a62b789512314542b35454`). Source: `gh api repos/fclairamb/solidping/releases/latest`. |
| Renovate | `datasource=github-releases depName=fclairamb/solidping versioning=semver` |
| License | AGPL-3.0. https://github.com/fclairamb/solidping/blob/main/LICENSE |
| Source URL | https://github.com/fclairamb/solidping |
| Download amd64 | `https://github.com/fclairamb/solidping/releases/download/v0.54.1/solidping-linux-amd64.gz` (sha256 `1f5e661e29000105c2c6c993fe964674b2670f976bf472f5a06ac595c8901f33`) |
| Download arm64 | `https://github.com/fclairamb/solidping/releases/download/v0.54.1/solidping-linux-arm64.gz` (sha256 `94524f93772d43515162f6c72a4e72819df832ac75d7c3b48c44a3924c05da39`) |
| Checksum source | `https://github.com/fclairamb/solidping/releases/download/v0.54.1/solidping-checksums.txt` (also `sp-checksums.txt`, same values). |
| Upstream Dockerfile reviewed | https://github.com/fclairamb/solidping/blob/5e35c5e4a02b63f3e15c48ade8e6bbe4b5b4e070/Dockerfile (commit pinned by the draft; the v0.54.1 Dockerfile is UNVERIFIED as identical). Multi-stage: node:26-alpine + bun builds the web UIs, golang:1.27.4-trixie builds with `CGO_ENABLED=0` (pure-Go SQLite), final `gcr.io/distroless/base-debian13:nonroot` as UID 65532. `ENV SP_DB_TYPE=sqlite SP_DB_DIR=/data SP_FILESTORAGE_LOCAL_ROOT=/data/files`, `VOLUME /data`, `EXPOSE 4000`, `HEALTHCHECK CMD ["/app/solidping","healthcheck"]`, `ENTRYPOINT ["/app/solidping","serve"]`. |
| Ports (real) | 4000/tcp (web UI, API, healthcheck). Confirmed by the upstream Dockerfile. Health endpoint `/api/mgmt/health` (from the Dockerfile comment). |
| Env vars (real) | From `web/docs/docs/installation/docker.md` and `configuration/database.md` at v0.54.1: `SP_DB_TYPE` (`sqlite` default, `postgres`, `sqlite-memory`), `SP_DB_URL` (required when postgres), `SP_DB_DIR` (default `/data`), `SP_SERVER_LISTEN` (default `:4000`), `SP_FILESTORAGE_LOCAL_ROOT` (default `/data/files`), `SP_ADMIN_PASSWORD` (optional first admin password), `SP_ADMIN_EMAIL` (optional). |
| Data path | `SP_DB_DIR` (SQLite file `$SP_DB_DIR/solidping.db`) and `SP_FILESTORAGE_LOCAL_ROOT` (uploads). Both default to `/data`. |
| Dependencies | None required. PostgreSQL is optional (`SP_DB_TYPE=postgres` with `SP_DB_URL`). `apps/postgresql` exists (✅). |
| arm64 | Published (`solidping-linux-arm64.gz`). Also riscv64, not in scope. |
| Runtime libs | Static Go binary (`CGO_ENABLED=0`), so no apt packages are needed. CA certs are UNVERIFIED for outbound HTTP checks; the ubuntu base should already provide them. |

## 2. Target layout

- `apps/solidping/Dockerfile`
- `apps/solidping/docker-bake.hcl`
- `apps/solidping/settings.yaml`
- `apps/solidping/container-test.yaml`
- `apps/solidping/start.sh`

No `defaults/`, `etc/` or `health/` are needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Fits because the upstream binary is static, so no runtime libraries are needed beyond the base. The draft's "distroless" upstream is replaced with ContainerForge's ubuntu base. Closest sibling: `apps/adguardhome-sync` (prebuilt binary, `/config` volume).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/tmp`.
2. Map `TARGETARCH` to the upstream asset name: `amd64` -> `solidping-linux-amd64.gz`, `arm64` -> `solidping-linux-arm64.gz`.
3. `curl -fsSL -o /tmp/solidping.gz "https://github.com/fclairamb/solidping/releases/download/v${VERSION}/solidping-linux-${ARCH}.gz"`. Verify with the matching line from `solidping-checksums.txt` using `sha256sum -c`.
4. `mkdir -p /app/solidping && gunzip -c /tmp/solidping.gz > /app/solidping/solidping && chmod 0755 /app/solidping/solidping`.
5. License: the repo LICENSE is AGPL-3.0. Fetch `https://raw.githubusercontent.com/fclairamb/solidping/v0.54.1/LICENSE` into `/usr/share/licenses/solidping/LICENSE`.
6. `chown -R apps:apps /app && chmod -R 755 /app`, `rm -rf /tmp/*`.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 4000`, `VOLUME /config`, `WORKDIR /config`.
8. Env: `ENV SP_DB_TYPE=sqlite SP_DB_DIR=/config SP_FILESTORAGE_LOCAL_ROOT=/config/files HOME=/tmp`. These are remapped from upstream `/data` to `/config` (see section 9).

`ARG VERSION` must match `docker-bake.hcl`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "solidping" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=fclairamb/solidping versioning=semver
  default = "0.54.1"
}
variable "LICENSE" { default = "AGPL-3.0" }
variable "SOURCE" { default = "https://github.com/fclairamb/solidping" }
```

LICENSE is `AGPL-3.0`, the SPDX id GitHub reports for the repo (no `-only`/`-or-later` suffix is claimed). Four standard targets and the default group copied from `apps/adguardhome-sync`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/fclairamb/solidping"
ports:
  - port: 4000
    protocol: tcp
    required: true
env:
  - name: SP_DB_TYPE
    default: "sqlite"
    required: false
  - name: SP_DB_URL
    default: ""
    required: false
  - name: SP_DB_DIR
    default: "/config"
    required: false
  - name: SP_SERVER_LISTEN
    default: ":4000"
    required: false
  - name: SP_FILESTORAGE_LOCAL_ROOT
    default: "/config/files"
    required: false
  - name: SP_ADMIN_PASSWORD
    default: ""
    required: false
  - name: SP_ADMIN_EMAIL
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`postgresql` is optional, so it is not in `dependencies`; list it under `opt_dependencies` (`- name: postgresql`), the key sibling apps such as `apps/babybuddy` use. `SP_DB_URL` is not required for the default SQLite setup.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p "${SP_DB_DIR:-/config}" "${SP_FILESTORAGE_LOCAL_ROOT:-/config/files}"

exec /app/solidping/solidping serve
```

- Idempotent. Solidping creates the SQLite file on first start, so nothing is seeded.
- Nothing is written to `/app`.
- `exec` passes PID 1 to the server.
- `SP_ADMIN_PASSWORD` and `SP_DB_URL` are read by the app itself. `start.sh` does not transform them, so special characters in a Postgres URL are not handled here.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '4000'
http:
- port: '4000'
  path: /api/mgmt/health
filePaths:
- /app/solidping/solidping
- /usr/share/licenses/solidping/LICENSE
```

- Port 4000 has a `tcp` and an `http` probe. The health path `/api/mgmt/health` is from the upstream Dockerfile comment; the 200 response on a fresh `/config` is UNVERIFIED, check during the run.
- No env is passed in the test, so the default SQLite path is exercised. The Postgres path is not covered and does not need to be (it is optional).
- `timeoutSeconds` 120 is UNVERIFIED against a sibling. Confirm against `apps/adguardhome-sync` or another Go sibling.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (SQLite `solidping.db`) | `SP_DB_DIR=/config`, persistent `/config` volume |
| `/data/files` (uploads: org logos, status-page assets, screenshots) | `SP_FILESTORAGE_LOCAL_ROOT=/config/files` |
| Upstream runs as distroless `nonroot` UID 65532 | `USER apps`. Port 4000 is above 1024, so no capability is needed. |
| Upstream healthcheck uses the binary itself | Not needed. ContainerForge uses the tcp and http probes in `container-test.yaml`. |
| `HOME` | `/tmp` (read-only rootfs safe). |

## 10. Risks, caveats and open questions

- Draft pins `0.52.0`. Latest is `0.54.1`. The draft must be updated, or the image is out of date on day one.
- Draft says "default database backend is not stated". Confirmed from the docs: `sqlite` is the default, with `SP_DB_DIR`. Postgres is opt-in.
- First admin: the docs say the admin password is generated on first start if `SP_ADMIN_PASSWORD` is unset, and that the generated password can be lost. Where the generated password is printed (log line) is UNVERIFIED. If it is printed to the container log, the log is the only place to recover it; treat that as a caveat.
- Draft says `read-only-rootfs: yes` and `non-root: yes`. Both hold with this plan. `/config` must stay writable.
- arm64 is published. No blockers found.

## 11. Build and test steps

From `apps/solidping/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name solidping-probe --read-only --tmpfs /tmp \
  -v solidping-probe-config:/config solidping:0.54.1
docker logs -f solidping-probe
docker rm -f solidping-probe; docker volume rm solidping-probe-config
forgetool containers test --image solidping:0.54.1 --config ./apps/solidping/container-test.yaml
```

- Expected readiness signal: the process stays up and logs show the HTTP server listening on `:4000`. The exact line is UNVERIFIED, so check it during the run.
- Empty `/config` start is covered by the fresh volume.
- arm64: build only if amd64 fails in an arm64-specific way.

## 12. PR checklist

- Branch `feat/add-solidping`, commit `feat(solidping): add new container`, PR title matches.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and only ticks boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`.
- Tell the user the CLA is needed: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what is untested: the Postgres path, the arm64 build, and the admin password log location, unless verified.
