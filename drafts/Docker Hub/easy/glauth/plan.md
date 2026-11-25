# glauth — implementation plan
> Source: ./draft.md · Target: apps/glauth/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.5.5` (release tag `GLAuth-v2.5.5`, "Latest", 2026-11-21). The draft links `GLAuth-v2.5.4`, which is outdated. |
| Renovate | `datasource=github-releases depName=glauth/glauth extractVersion=^GLAuth-v(?<version>.+)$` |
| License | `MIT` (root `LICENSE` at tag `GLAuth-v2.5.5` starts "MIT License, Copyright (c) 2018 Ned McClain & Ben Yanke & Chris Ravenscroft"; upstream image label also says MIT). |
| Source URL | https://github.com/glauth/glauth |
| Download amd64 | `https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.5/glauth-linux-amd64` (raw binary, no archive) |
| Download arm64 | `https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.5/glauth-linux-arm64` |
| Other assets | `386`, `arm-7`, `riscv64`, darwin, windows binaries. |
| Checksum source | No checksum file, but GitHub publishes a SHA-256 digest per release asset (API, checked 2026-11-25): amd64 `b0a27c536351010fd1ba90ce4930ff980f187ad015d9287c4731f9c109334dbe`, arm64 `d0a17af0cda75676f9a2d1378636562d01a2b5bb8ddc4fa34be87477525caa4d`. |
| License file | `https://raw.githubusercontent.com/glauth/glauth/GLAuth-v2.5.5/LICENSE` returns 200. |
| Upstream Dockerfile reviewed | `v2/docker/Dockerfile-standalone`: runs on `gcr.io/distroless/base-debian13` (glibc), copies `/app/glauth`, `/app/docker/start-standalone.sh`, `EXPOSE 389 636 5555`, `ENTRYPOINT dumb-init`. UNVERIFIED: that the binary is statically linked; it runs on distroless glibc, so Ubuntu glibc is fine. |
| Upstream start script | `start-standalone.sh`: if `/app/config/config.cfg` is missing, copies `default-config-standalone.cfg` there, prints `/app/glauth --version`, then runs `/app/glauth -c /app/config/config.cfg`. |
| Real listen ports | The upstream sample config listens on **3893** (LDAP, `0.0.0.0:3893`), **3894** (LDAPS, `enabled = false` by default, needs cert/key) and **5555** (REST API, `enabled = true`, `tls = false`). Ports 389/636 in the draft are only the Dockerfile `EXPOSE` / Service mapping, not what the process opens. |
| Config format | TOML (`config.cfg`): sections `[ldap]`, `[ldaps]`, `[backend]` (`datastore = "config"`, `baseDN`), `[behaviors]`, `[[users]]` (passsha256 / passbcrypt), `[[groups]]`, `[api]`. |
| Env vars | None documented in what was read. UNVERIFIED whether glauth reads any `GLAUTH_*` env. Do not invent any. |
| CLI | `-c <config>` and `--version` verified from upstream start script. |

## 2. Target layout

```
apps/glauth/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/glauth.cfg     # minimal seed config, copied only when /config/glauth.cfg is missing
```
`defaults/` is on the `include/.dockerignore` allow-list. Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```
Why: one Go binary; the Go rules say no compiling in runtime stage, and a prebuilt release binary is used so no build stage is needed. Closest sibling: `apps/adguardhome-sync` (binary in `/app`, `defaults/` seed with `cp -n`).

## 4. Dockerfile

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
# not renovated: update both with every VERSION bump
ARG SHA256_AMD64=b0a27c536351010fd1ba90ce4930ff980f187ad015d9287c4731f9c109334dbe
ARG SHA256_ARM64=d0a17af0cda75676f9a2d1378636562d01a2b5bb8ddc4fa34be87477525caa4d
USER root

ENV HOME=/config

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) sha="${SHA256_AMD64}" ;; \
      arm64) sha="${SHA256_ARM64}" ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /usr/share/licenses/glauth; \
    curl -fsSL -o /app/glauth \
      "https://github.com/glauth/glauth/releases/download/GLAuth-v${VERSION}/glauth-linux-${TARGETARCH}"; \
    echo "${sha}  /app/glauth" | sha256sum -c -; \
    curl -fsSL -o /usr/share/licenses/glauth/LICENSE \
      "https://raw.githubusercontent.com/glauth/glauth/GLAuth-v${VERSION}/LICENSE"; \
    chown -R apps:apps /app; chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 3893 5555
VOLUME /config
```
Notes:
- `TARGETARCH` equals the asset suffix (`amd64`, `arm64`); no mapping.
- The binary is verified against the GitHub asset digests above. Optionally add `RUN /app/glauth --version` as a build-time smoke check, which also catches a wrong-arch binary.
- No `apt-get`: nothing to install.
- No Go toolchain, no `GOCACHE`; if a Go cache appears at runtime it must go to `/tmp`.
- Final `USER apps`, `COPY --chmod=0755 . /` kept.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "glauth"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=glauth/glauth extractVersion=^GLAuth-v(?<version>.+)$
  default = "2.5.5"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/glauth/glauth"
}
```
Plus the standard `group "default"`, `target "image"`, `"image-local"` (`glauth:${VERSION}`), `"image-all"` (amd64, arm64) as in `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/glauth/glauth"
ports:
  - port: 3893
    protocol: tcp
    required: true
  - port: 5555
    protocol: tcp
    required: false
env:
  - name: CONFIGFILE
    default: "/config/glauth.cfg"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
- `CONFIGFILE` is read by `start.sh` (same pattern as `adguardhome-sync`), not by glauth. This is an image-level variable.
- 3894 (LDAPS) is deliberately not listed (nor `EXPOSE`d): the seed config does not open it, and settings must not list closed ports. Users who enable LDAPS map the port themselves.
- Service mapping of 389 to 3893 and 636 to 3894 is done by the chart, not here.
- `dependencies:` none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIGFILE="${CONFIGFILE:-/config/glauth.cfg}"

mkdir -p "$(dirname "${CONFIGFILE}")"
if [ ! -f "${CONFIGFILE}" ]; then
  echo "[glauth] ${CONFIGFILE} not found, seeding minimal default config"
  cp /defaults/glauth.cfg "${CONFIGFILE}"
fi

/app/glauth --version || true
cd /config
exec /app/glauth -c "${CONFIGFILE}"
```
Seed `defaults/glauth.cfg` (derived from upstream `default-config-standalone.cfg`, with the sample users removed):
- `debug = false`
- `[ldap] enabled = true, listen = "0.0.0.0:3893"`
- `[ldaps] enabled = false, listen = "0.0.0.0:3894", cert = "/config/glauth.crt", key = "/config/glauth.key"`
- `[backend] datastore = "config", baseDN = "dc=glauth,dc=com"`
- `[behaviors]` as upstream defaults (`LimitFailedBinds = true`, etc.)
- one `[[groups]]` entry (`name = "superheros"`, `gidnumber = 5501`)
- `[api] enabled = true, tls = false, listen = "0.0.0.0:5555"`; set `cert`/`key` to `/config/...` paths.
Do NOT copy the upstream sample users and their well-known passwords ("dogood", "mysecret") into the shipped seed; they are public credentials. Open questions: whether glauth starts with zero `[[users]]` (UNVERIFIED, test on first run; if it refuses, seed one `serviceuser` with a clearly invalid placeholder hash and log a warning), and whether the unauthenticated REST API on 5555 should default to enabled.
- Binds on all interfaces as required; nothing written to `/app`; `exec` for signals; idempotent.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3893'
- port: '5555'
filePaths:
- /app/glauth
- /defaults/glauth.cfg
```
- Probes the two ports the seed config really opens. 3894 is not probed because it is disabled by default.
- A `http` probe on 5555 could be added once the API path is confirmed (UNVERIFIED which path returns 200); keep tcp until then.
- Test runs with no env vars; the seed path is exercised by default.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/app/config/config.cfg` (upstream copies the sample there) | `/config/glauth.cfg`; `/app` stays read-only |
| ports 389 / 636 | 3893 / 3894 (non-privileged, as the upstream sample config already does) |
| cert/key relative paths (`glauth.crt`, `glauth.key`) | absolute `/config/...` in the seed, since the working directory must not be `/app` |
| runtime user | base `apps` (568) instead of the chart's root (0) |

Draft expectations: chart sets UID 0 and `readOnlyRootFilesystem: false`; this port runs as 568 with a read-only root because glauth only reads its config and writes nothing else known (UNVERIFIED: no state file written at runtime, check by running with `--read-only`). Extra persistence `/app/config` becomes `/config`; the chart's mount path must be changed.

## 10. Risks, caveats and open questions

- Draft caveat: the config must be hand-written; the shipped seed is intentionally minimal and has no users, so a fresh container serves an empty directory.
- Draft caveat: LDAPS needs a user-supplied certificate in `/config`; plain LDAP on 3893 sends credentials in clear text. Document both in the PR.
- Draft caveat: chart config path `/app/config` vs `/config`; settled as `/config`, chart must be updated.
- The pinned SHA-256 ARGs are not renovated: a `VERSION` bump needs both digests updated by hand, or the build fails.
- Draft lists `GLAuth-v2.5.4` URLs; use `2.5.5` (latest verified).
- The REST API on 5555 has no TLS by default; consider defaulting `[api] enabled = false` for safety (then drop the 5555 probe and mark the port optional).
- Config loading at the tag (`internal/toml/config.go`) requires an LDAP or LDAPS server section; no zero-user check was seen in a search of that file (still confirm by running). The binary also has `--check-config`.
- No blocker: both arches exist, glibc base works, no privileged ports needed.

## 11. Build and test steps

```sh
cd apps/glauth
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create glauth-probe-config
docker run --rm -d --name glauth-probe --read-only --tmpfs /tmp \
  -v glauth-probe-config:/config glauth:2.5.5
docker logs -f glauth-probe      # expect the seeding line, a version banner, then LDAP server listening on 3893
# from a second container on the same network: ldapsearch -H ldap://glauth-probe:3893 -x   (confirms non-localhost binding)
docker rm -f glauth-probe; docker volume rm glauth-probe-config
forgetool containers test --image glauth:2.5.5 --config ./apps/glauth/container-test.yaml
```
Also restart the container on the same volume and confirm the config is not overwritten. Max 10 rounds.

## 12. PR checklist

- [ ] Branch `feat/add-glauth`; commit and PR title `feat(glauth): add new container`; target `main`.
- [ ] PR template filled, only applicable boxes checked.
- [ ] Notes contain `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- [ ] `docker buildx bake --print` passed; `ARG VERSION` equals bake `VERSION` (`2.5.5`).
- [ ] PR text mentions: ports 3893/5555 by default (3894 only when LDAPS is enabled; not 389/636), no sample users shipped, manually pinned digests.
- [ ] Untested until run: build on both arches, zero-user start, read-only start, cross-container LDAP bind, forgetool run. Do not tick "Built container locally" unless done.
