# semaphore — implementation plan
> Source: ./draft.md · Target: apps/semaphore/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2.20.23` (GitHub release `v2.20.23`, published 2026-11-10). The draft's `v2.20.24` has no GitHub release (`releases/tags/v2.20.24` is 404) and exists only as a Docker Hub tag (pushed 2026-11-11). UNVERIFIED: whether the `v2.20.24` image differs from the `2.20.23` binaries. Decision: pin `2.20.23` unless the user wants the Docker Hub tag. |
| Renovate | `datasource=github-releases depName=semaphoreui/semaphore versioning=semver` (convention; repo renovate config not fetched) |
| License | MIT (GitHub API SPDX `MIT`; https://api.github.com/repos/semaphoreui/semaphore/license) |
| Source URL | https://github.com/semaphoreui/semaphore |
| Download (amd64) | https://github.com/semaphoreui/semaphore/releases/download/v2.20.23/semaphore_2.20.23_linux_amd64.tar.gz |
| Download (arm64) | https://github.com/semaphoreui/semaphore/releases/download/v2.20.23/semaphore_2.20.23_linux_arm64.tar.gz |
| Checksum source | https://github.com/semaphoreui/semaphore/releases/download/v2.20.23/semaphore_2.20.23_checksums.txt. `linux_amd64` sha256 `89cbee983255534e167f140b8c58b4e5973b761afdeeea3fd81a5809ff6a8318`, `linux_arm64` sha256 `3a6cd34f8083ceb1f51953ae9d2022c8b82e232d9fa7789f2619f55a1b5db4c5`. A `.sig` file is also published; signature check not done (UNVERIFIED). |
| Upstream Dockerfile reviewed | https://github.com/semaphoreui/semaphore/blob/7cf38e07fa33532defa12db82b847b2ee4e6ea6f/deployment/docker/server/Dockerfile. Builder `golang:1.26-alpine3.24`; runtime `alpine:3.24`; `ANSIBLE_VERSION=13.5.0` installed with pip into a venv; `tini` as PID 1; `USER 1001`; `EXPOSE 3000`. |
| Bundled tools (renovate-annotated upstream ENV) | OpenTofu `1.11.0` (depName `opentofu/opentofu`), Terraform `1.11.3` (depName `hashicorp/terraform`), Terragrunt `0.78.0` (depName `gruntwork-io/terragrunt`). Upstream publishes them without a checksum check in the Dockerfile. UNVERIFIED: their checksum files (not fetched in this run). |
| Port | `3000/tcp` (EXPOSE in upstream Dockerfile). |
| Env vars (real) | `SEMAPHORE_CONFIG_PATH` (default `/etc/semaphore`), `SEMAPHORE_DB_PATH` (default `/var/lib/semaphore`), `SEMAPHORE_DB_PORT` (default empty). Read in `deployment/docker/server/server-wrapper` (https://api.github.com/repos/semaphoreui/semaphore/contents/deployment/docker/server/server-wrapper?ref=7cf38e07fa33532defa12db82b847b2ee4e6ea6f). The same script supports `*_FILE` variants. UNVERIFIED: the rest of `server-wrapper` (first-run setup, DB dialect variables). |
| Write paths (upstream) | `/etc/semaphore` (config), `/var/lib/semaphore` (DB), `/tmp/semaphore`, `/opt/semaphore` (ansible venv). `/home/semaphore` is the WORKDIR. The draft's `/data` is a chart choice, not an upstream path. |
| Arch | amd64 and arm64 release tarballs confirmed. copy-from amd64 / arm64: no (upstream runtime is alpine/musl). |
| Dependencies | External database. Upstream image ships `mysql-client` only; the server database is configured at runtime. ContainerForge sibling `postgresql` exists (`apps/postgresql`). |

## 2. Target layout

- `apps/semaphore/Dockerfile`
- `apps/semaphore/docker-bake.hcl`
- `apps/semaphore/settings.yaml`
- `apps/semaphore/container-test.yaml`
- `apps/semaphore/start.sh`
- `apps/semaphore/defaults/` only if a default config file is needed (decide after reading `server-wrapper` in full; UNVERIFIED).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`
- Why: the upstream binary is a static Go build from a release tarball, so ubuntu is enough. The Python tooling (ansible) needs `python3` and `python3-venv`; `apps/python` is the alternative if ubuntu lacks them at the pinned release (check with `apt-cache policy python3-venv` in a build round).
- Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu, `COPY --chmod=0755 . /`, `VOLUME /config`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Set `ENV HOME=/config` only if needed; otherwise keep the base default. Put all caches under `/tmp`: `ANSIBLE_LOCAL_TEMP=/tmp/ansible`, `ANSIBLE_REMOTE_TEMP=/tmp/ansible`, `PIP_CACHE_DIR=/tmp/pip`.
3. `apt-get install` only packages not already in the base: `bash curl git gnupg openssh-client rsync sshpass tar tzdata unzip wget zip jq python3 python3-venv` (pin the package versions where they come from apt and check them against the image; upstream also needs `mysql-client`, add it only if the chosen DB mode needs it). Use `--no-install-recommends` and clean `/var/lib/apt/lists/*`.
4. Download the Semaphore tarball for `${TARGETARCH}` (map `amd64` → `linux_amd64`, `arm64` → `linux_arm64`). Verify with `sha256sum -c` against the sha256 values in section 1. Extract `semaphore` and `server-wrapper` only if needed (the wrapper is in the repo, not in the tarball: UNVERIFIED that the tarball ships it; otherwise write `start.sh` to replace it).
5. Install `semaphore` to `/usr/local/bin/semaphore`, mode 0755.
6. Download OpenTofu, Terraform and Terragrunt for `${TARGETARCH}` using the versions in section 1. Verify each against its upstream checksum file (UNVERIFIED: checksum URLs not fetched; resolve before writing the Dockerfile, do not skip). Install to `/usr/local/bin/`.
7. Create the ansible venv at build time, not at runtime: `python3 -m venv /app/ansible-venv` and `pip install ansible==${ANSIBLE_VERSION} boto3 botocore requests pywinrm paramiko` with `ARG ANSIBLE_VERSION` annotated `// renovate`-style comment (`# renovate: datasource=pypi depName=ansible`). Use `/app/ansible-venv` (not `/app/venv`, which is the Python-base convention and is not used here). Do not use `/opt/semaphore`.
8. Set `ENV PATH="/app/ansible-venv/bin:${PATH}"`.
9. `chown -R apps:apps /app` only for paths that must match the runtime user; `/app` stays read-only at runtime.
10. `EXPOSE 3000`, `VOLUME /config`, `COPY --chmod=0755 . /`, final `USER apps`.
11. Upstream uses `tini` as PID 1. The ubuntu base already ships tini and its entrypoint (`/usr/bin/tini -- /entrypoint.sh`) runs `exec /start.sh`, so set no `ENTRYPOINT` or `CMD`; `start.sh` `exec`s the server.
12. License: copy the upstream `LICENSE` to `/usr/share/licenses/semaphore/LICENSE` from the source tarball or repo (fetch it at build time from `https://raw.githubusercontent.com/semaphoreui/semaphore/v2.20.23/LICENSE`, verified by a pinned sha256; UNVERIFIED: checksum not computed).

## 5. docker-bake.hcl

- `variable "APP" { default = "semaphore" }`
- `variable "VERSION" { // renovate: datasource=github-releases depName=semaphoreui/semaphore versioning=semver` then `default = "2.20.23"`. Must equal Dockerfile `ARG VERSION`.
- `variable "LICENSE" { default = "MIT" }`
- `variable "SOURCE" { default = "https://github.com/semaphoreui/semaphore" }`
- Targets: `docker-metadata-action`, `image` (args VERSION, OCI labels source and licenses), `image-local` (output docker, tags `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default"` with `image-local`.
- Validate with `cd apps/semaphore && docker buildx bake --print`.
- Renovate annotations for the bundled tools go in the Dockerfile `ARG`/`ENV` lines, next to their versions.

## 6. settings.yaml

- Schema header and `schema_version: 1` as in `apps/adguardhome-sync/settings.yaml`.
- `upstream_env_url: "https://github.com/semaphoreui/semaphore"`
- `ports`: `port: 3000`, `protocol: tcp`, `required: false`.
- `env`:
  - `SEMAPHORE_CONFIG_PATH`, default `/config/semaphore`, `required: false` (set by start.sh; keeps config in `/config`).
  - `SEMAPHORE_DB_PATH`, default `/config/semaphore`, `required: false`.
  - `TZ`, default `Etc/UTC`, `required: false`.
  - Do not list `SEMAPHORE_DB_PORT` unless start.sh reads it.
- `volumes`: `/config`, `required: true`.
- `dependencies`: omit. `opt_dependencies` with `- name: postgresql` (`apps/postgresql` exists; key shape as in `apps/babybuddy/settings.yaml`).

## 7. start.sh

1. `set -eu`. Create `/config/semaphore` only when missing (`mkdir -p`).
2. Seed nothing from `/app` unless a default config exists; do not overwrite existing `/config` content.
3. Export `SEMAPHORE_CONFIG_PATH=/config/semaphore` and `SEMAPHORE_DB_PATH=/config/semaphore` (or the defaults from settings.yaml), and `ANSIBLE_LOCAL_TEMP`/`ANSIBLE_REMOTE_TEMP` under `/tmp`.
4. Map `*_FILE` secrets through the upstream wrapper logic if it is kept; otherwise document that they are not supported.
5. `exec` the semaphore server (`exec /usr/local/bin/semaphore server --config "${SEMAPHORE_CONFIG_PATH}/config.json"` or the upstream wrapper, decided after reading `server-wrapper`; UNVERIFIED flags).
6. Bind on all interfaces (Semaphore default is `0.0.0.0:3000` per upstream config; confirm, UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /usr/local/bin/semaphore
- /usr/local/bin/tofu
- /usr/local/bin/terraform
- /usr/local/bin/terragrunt
- /app/ansible-venv/bin/ansible
- /usr/share/licenses/semaphore/LICENSE
```

- A tcp and an http probe for port 3000 (rule: every port in settings.yaml).
- Startup with no env vars must work, so the default DB mode must start without an external DB (UNVERIFIED: upstream default; if Semaphore needs a DB to start, apply the database-dependent exception in the protocol and narrow the assertions with the required comment).
- Consider a `filePaths` entry for the DB-setup code path only if it is not exercised at startup.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/etc/semaphore` (config) | `SEMAPHORE_CONFIG_PATH=/config/semaphore` |
| `/var/lib/semaphore` (sqlite/DB) | `SEMAPHORE_DB_PATH=/config/semaphore` |
| `/tmp/semaphore` | `/tmp/semaphore` (already tmpfs under `--read-only --tmpfs /tmp`) |
| `/opt/semaphore` (ansible venv) | `/app/ansible-venv`, built at build time, read-only at runtime |
| `/home/semaphore` (WORKDIR, ansible temp/home) | `HOME=/config` or `/tmp`; set `ANSIBLE_LOCAL_TEMP` and `ANSIBLE_REMOTE_TEMP` to `/tmp/ansible` |
| `ssh` config (`/etc/ssh/ssh_config.d/semaphore.conf`) | Not needed to run; if ssh is needed, write to `/tmp` via `GIT_SSH_COMMAND`/`-F` (decide when porting the feature) |

- UID: upstream uses 1001; ContainerForge uses `apps` (568). Keep `USER apps`. Chart values run as 0 and `readOnlyRootFilesystem: false`; the image must not depend on root.
- Chart extra persistence `/data` (playbook path): map to `/config` for playbooks (UNVERIFIED: whether Semaphore reads playbooks from a fixed path; the chart's `/data` mount is the only reference).
- `privileged`: no.

## 10. Risks, caveats and open questions

- Version: draft says `v2.20.24`; the only GitHub release is `v2.20.23`. Pin `2.20.23` until upstream publishes a matching release (decision needed).
- Large image: OpenTofu, Terraform, Terragrunt and ansible. Size and build time are high.
- Upstream verifies none of the tool downloads in its Dockerfile. This plan adds checksums, which must be sourced (UNVERIFIED).
- Database: no bundled DB. Initial admin account via CLI or first-run setup (draft caveat, UNVERIFIED steps).
- `server-wrapper` contents beyond the `file_env` section were not read in this run (UNVERIFIED).
- Chart mount `/data` vs upstream `/var/lib/semaphore` and `/etc/semaphore`: a mismatch for users migrating data.
- Blockers: none confirmed (glibc-compatible Go binary, arm64 available). No GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/semaphore
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name semaphore-probe --read-only --tmpfs /tmp \
  -v semaphore-probe-config:/config semaphore:2.20.23
docker logs -f semaphore-probe
forgetool containers test --image semaphore:2.20.23 --config ./apps/semaphore/container-test.yaml
docker rm -f semaphore-probe; docker volume rm semaphore-probe-config
```

- Readiness signal: an upstream "server listening" or "Starting Semaphore" line (UNVERIFIED exact text; read it from the first successful run and record it here).
- Check `/config/semaphore` is created on the empty volume and survives a restart.
- Check that `ansible --version` and `tofu version`, `terraform version`, `terragrunt --version` run inside the image.
- Build arm64 only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-semaphore`, commit `feat(semaphore): add new container`, PR title `feat(semaphore): add new container`, target `main`.
- Notes section: `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections; check only what applies.
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what is untested: arm64 runtime, the bundled tool checksums, the ansible task run, and the database modes.
