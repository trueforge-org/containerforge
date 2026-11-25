# qbitrr — implementation plan
> Source: ./draft.md · Target: apps/qbitrr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **5.14.9-4** (latest, published 2026-11-23). The draft pins `v5.12.12`, which is stale; the plan uses the latest. Source: https://api.github.com/repos/Feramance/qBitrr/releases/latest |
| Renovate | `datasource=github-releases depName=Feramance/qBitrr versioning=semver` (convention; repo renovate config not fetched). |
| License | MIT (GitHub `license.spdx_id`, https://api.github.com/repos/Feramance/qBitrr) |
| Source URL | https://github.com/Feramance/qBitrr |
| Release assets | https://github.com/Feramance/qBitrr/releases/download/v5.14.9-4/qBitrr-5.14.9-4-ubuntu-latest-x64.tar.gz (amd64, a prebuilt Linux build); `...-macOS-latest-arm64.tar.gz` and a Windows zip (not usable on Linux). No Linux arm64 asset. |
| Checksum source | Per-asset `.sha256` file, e.g. https://github.com/Feramance/qBitrr/releases/download/v5.14.9-4/qBitrr-5.14.9-4-ubuntu-latest-x64.tar.gz.sha256. amd64 value: `082abd73e70503b0da7a4a953d3edf5bfe878c2462f7d1fd6d88f02825472a51`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Feramance/qBitrr/master/Dockerfile (WebFetch summary). Stage 1 `node:26-bookworm` builds `webui` (`npm ci`, `npm run build`) into `qBitrr/static`. Stage 2 `python:3.14-slim`: `pip install ".[fast]"` in `/app`; system user `qbitrr` with home `/config`; `docker-entrypoint.sh` (uses `gosu` and `tini`); `WORKDIR /config`; `EXPOSE 6969`; `ENTRYPOINT ["/docker-entrypoint.sh"]`; `CMD ["python","-m","qBitrr.main"]`; no `VOLUME`, no `USER`. |
| Port | 6969 (upstream `EXPOSE`). The web UI is served on it. |
| Env vars (real) | `QBITRR_DOCKER_RUNNING=69420`, `QBITRR_SOURCE_BUILD` (build arg default `0`), `PYTHONDONTWRITEBYTECODE=1`, `PYTHONUNBUFFERED=1`, `PYTHONOPTIMIZE=1` (all set by the upstream Dockerfile). Application config env: UNVERIFIED (the entrypoint script and README were not fetched). |
| Data path | `/config` (home, `WORKDIR`, chowned to `qbitrr`). Config file and database location inside `/config`: UNVERIFIED (not fetched). |
| arm64 | Upstream Dockerfile is multi-arch (Docker Hub `feramance/qbitrr` has amd64 and arm64 for `v5.14.9-4`). No Linux arm64 release tarball. The draft's `pip:qbitrr2` for arm64 is UNVERIFIED (not confirmed on a fetched page). |
| Docker Hub `feramance/qbitrr` | Tags `latest`, `v5.14.9-4` (2026-11-23), `nightly`; amd64 and arm64 (https://hub.docker.com/v2/repositories/feramance/qbitrr/tags). `copy-from`: a Debian python-slim image, so copying the install tree is possible but fragile; the plan does not use `COPY --from`. |

## 2. Target layout

- `apps/qbitrr/Dockerfile`
- `apps/qbitrr/docker-bake.hcl`
- `apps/qbitrr/settings.yaml`
- `apps/qbitrr/container-test.yaml`
- `apps/qbitrr/start.sh` (replaces upstream `docker-entrypoint.sh`)
- No `defaults/` unless a seed config is needed (decide after the config-format check in section 10). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime: `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`.
Build stage for the web UI: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (has node, so the `webui` build does not need a separate `node` image).

Reason: qbitrr is a pip-installed Python package, which the `python` base is made for; it sets `VENV_FOLDER=/app/venv` and the pip/uv environment. Upstream uses `python:3.14-slim`; the move to 3.15.2 is a behaviour change to test. Closest siblings: `apps/bazarr` (python), `apps/changedetection` (python-node, webui build).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`.
2. Build stage `FROM <python-node> AS webui`: `WORKDIR /src`, fetch the source archive of tag `v${VERSION}` (`https://github.com/Feramance/qBitrr/archive/refs/tags/v${VERSION}.tar.gz`), `npm ci` and `npm run build` in `webui/`, output to `qBitrr/static`. Pin the archive by its release checksum or by the tag's commit SHA (UNVERIFIED: the archive's checksum is not published; record the SHA at review).
3. Python stage `FROM <python> AS app`: install the source archive with `pip install ".[fast]"` into the base venv at build time (`/app/venv/bin/pip`), not at runtime. Copy the built `qBitrr/static` in before install so the package ships the UI.
4. Final stage `FROM <python>`: `USER root`, `apt-get install --no-install-recommends tini gosu curl` only if `start.sh` needs them (it should not, because `start.sh` runs as `apps`); otherwise install nothing. `apt-get clean` and remove lists.
5. Tail:

```dockerfile
ENV QBITRR_DOCKER_RUNNING=69420 \
    QBITRR_SOURCE_BUILD=0 \
    PYTHONOPTIMIZE=1

USER apps
COPY --chmod=0755 . /

EXPOSE 6969
VOLUME /config
WORKDIR /config
CMD ["/start.sh"]
```

Upstream `gosu` drops privileges after a root `chown`. This image runs as `apps` from the start, so `gosu` and the root `chown` step are not needed; say so in the PR.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "qbitrr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Feramance/qBitrr versioning=semver
  default = "5.14.9-4"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Feramance/qBitrr"
}
```

Then `group "default"` and the `image`, `image-local`, `image-all` targets copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/qbitrr/`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Feramance/qBitrr"
ports:
  - port: 6969
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

The qBittorrent and Sonarr/Radarr wiring is set in qBitrr's own config, not by env, so it does not go in `env`. Add env entries only after the config format is read (section 10). `dependencies` stays empty: qBittorrent and the *arr apps are external services the user configures, not ContainerForge apps (UNVERIFIED that no ContainerForge `qbittorrent` dependency is wanted; check `apps/` before merging).

## 7. start.sh

- Runs as `apps`. `mkdir -p /config` only if missing. Creates no config by default; qBitrr's first start writes its own config into `/config` (UNVERIFIED: the file name and the first-run behaviour, to confirm in the run).
- Writes nothing under `/app` (`/app` holds the installed venv and package and is read-only at runtime). Caches (`PIP_CACHE_DIR`, `XDG_CACHE_HOME`) go to `/tmp`.
- Runs `exec python -m qBitrr.main` (or the venv's `qbitrr` entrypoint if the package installs one; UNVERIFIED, check `pyproject.toml`), so signals reach the process.
- The web UI must bind `0.0.0.0:6969`. UNVERIFIED: the default bind address in qBitrr's config; if it is `127.0.0.1`, set it in `start.sh` on first run and say so in the PR.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '6969'
http:
- port: '6969'
  path: /
filePaths:
- /app/venv/bin/python
- /start.sh
```

Every port in `settings.yaml` has a `tcp` probe. The `http` path must return an accepted status; UNVERIFIED: qBitrr may answer `/` with a redirect or require setup first. Confirm in the first local run and use the path that answers, without loosening the check.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (home, config, DB and logs; upstream `WORKDIR`) | Unchanged: `/config` is the persistent volume. |
| `/app` (package install, `qBitrr/static`) | Read-only at runtime (build-time install only). |
| pip, npm and Python bytecode caches | `/tmp` (`PIP_NO_CACHE_DIR=1`, `PYTHONDONTWRITEBYTECODE=1`, cache envs to `/tmp`). |
| Completed downloads (`/completed_downloads`, chart PVC) | Not a qBitrr write path; the path is set in the user's config and is not part of this image. |

Reconciled with the draft: the chart runs as root (`runAsUser 0`, `runAsNonRoot false`) and `readOnlyRootFilesystem: false`. This image runs as `apps` and passes `--read-only --tmpfs /tmp`. Not privileged. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- Version: the draft's `v5.12.12` is stale. Use `5.14.9-4` (see section 1). Re-check the draft's `container` field before PR.
- Python version: upstream `3.14-slim`, this plan `3.15.2` base. Test that `pip install ".[fast]"` resolves on 3.15.2.
- Config format and first run: the entrypoint (`docker-entrypoint.sh`) and the README were not fetched. Before writing `start.sh`, read them for the config path, the env names and the first-run behaviour. Do not invent env names (UNVERIFIED).
- The amd64 release tarball is a prebuilt Linux x64 bundle. Its contents and whether it runs on the Ubuntu base are UNVERIFIED. The plan uses the source build (pip install from the tag) for both architectures, so the tarball is only a reference.
- arm64: no Linux arm64 release asset. The source build is platform-independent Python, so arm64 should build (untested). The draft's `pip:qbitrr2` path is UNVERIFIED and not used.
- The webui build needs the node stage; the build takes longer (inferred).
- No blockers found: MIT license, no privileged or GPU needs.

## 11. Build and test steps

```sh
cd apps/qbitrr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name qbitrr-probe --read-only --tmpfs /tmp \
  -v qbitrr-probe-config:/config qbitrr:5.14.9-4
docker logs -f qbitrr-probe
forgetool containers test --image qbitrr:5.14.9-4 --config ./apps/qbitrr/container-test.yaml
docker rm -f qbitrr-probe; docker volume rm qbitrr-probe-config
```

Readiness signal: the process stays up, logs show the web server listening on port 6969 (wording UNVERIFIED until the first run), and no traceback on first start with an empty `/config`. Also check that a second start with the same volume keeps the config.

## 12. PR checklist

- Branch `feat/add-qbitrr`, commit and PR title `feat(qbitrr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the webui build, the Python 3.15.2 install, the arm64 build, the http probe status, and the config-format assumptions.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no test assertion weakened.
