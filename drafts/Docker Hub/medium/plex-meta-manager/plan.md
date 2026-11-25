# plex-meta-manager — implementation plan
> Source: ./draft.md · Target: apps/plex-meta-manager/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart pins `meisnate12/plex-meta-manager:v1.21.0` (released 2024-04-04). The project moved to the Kometa-Team org and is now named Kometa. Latest release is `v2.5.5` (2026-11-11). This plan pins v1.21.0 (reviewed Dockerfile); v2.x is an open decision (section 10). |
| Renovate | `// renovate: datasource=github-releases depName=Kometa-Team/Kometa versioning=semver` (repo moved; UNVERIFIED that Renovate follows the redirect for the old name) |
| License | MIT (https://api.github.com/repos/meisnate12/Plex-Meta-Manager/license, redirects to Kometa-Team/Kometa LICENSE) |
| Source URL | https://github.com/Kometa-Team/Kometa (formerly https://github.com/meisnate12/Plex-Meta-Manager; the draft link redirects) |
| Release page | https://github.com/Kometa-Team/Kometa/releases/tag/v1.21.0 (no assets) |
| Download | No release assets. Source tarball `https://github.com/Kometa-Team/Kometa/archive/refs/tags/v1.21.0.tar.gz` (standard GitHub archive URL; UNVERIFIED that it resolves for the tag, confirm at build time). |
| Checksum source | None published. Pin by tag and record the sha256 of the tarball at build time (UNVERIFIED commit SHA for v1.21.0). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/meisnate12/Plex-Meta-Manager/v1.21.0/Dockerfile. `FROM python:3.11-slim-buster`; `ARG BRANCH_NAME=master`; `ENV TINI_VERSION v0.19.0`, `ENV PMM_DOCKER True`; apt build deps (`gcc g++ libxml2-dev libxslt-dev libz-dev libjpeg62-turbo-dev zlib1g-dev wget curl`) installed then purged; `tini` downloaded to `/tini`; `COPY requirements.txt`, `pip3 install --no-cache-dir --upgrade --requirement /requirements.txt`; `COPY . /`; `ENTRYPOINT ["/tini", "-s", "python3", "plex_meta_manager.py", "--"]`; `VOLUME /config`; no USER (root); no EXPOSE. |
| Env vars | Upstream image sets `PMM_DOCKER=True`, `TINI_VERSION`, `BRANCH_NAME` (build arg). User-facing runtime env vars: UNVERIFIED (not in the Dockerfile). |
| Ports | None (no EXPOSE, no listener expected). Matches the draft. |
| Docs | https://metamanager.wiki/ and https://kometa.wiki/en/latest/ (carried over from the draft; not fetched). |
| Data paths | `/config` (VOLUME). Holds the user `config.yml` (created by the user, draft caveat, UNVERIFIED that the app reads `/config/config.yml`). |
| arm64 | Docker Hub `meisnate12/plex-meta-manager:v1.21.0` has amd64 and arm64 images (https://hub.docker.com/v2/repositories/meisnate12/plex-meta-manager/tags). Source install is arch-neutral except for wheels with native code (`lxml`, `Pillow`, `PyYAML` etc.), which need arm64 wheels or the build deps. |
| copy-from | Not used. The upstream image is the app plus its Python tree; this plan installs from source instead, as the draft's reason states. |

## 2. Target layout

- `apps/plex-meta-manager/Dockerfile`
- `apps/plex-meta-manager/docker-bake.hcl`
- `apps/plex-meta-manager/settings.yaml`
- `apps/plex-meta-manager/container-test.yaml`
- `apps/plex-meta-manager/start.sh` (seeds `/config` only if missing, then `exec`s the Python process)
- `apps/plex-meta-manager/defaults/` only if a default config is needed (reason: a `config.yml` seed; the upstream app needs the user to write one, so default seeding is not the plan unless a template exists in the source tree; UNVERIFIED)

No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (brief table; the python base already provides `/app/venv`, and upstream is Python 3.11, so check the app supports 3.15 before choosing; if not, use the python image that matches the requirements, and say so). Build on `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` only if a compiled build stage is needed.

Closest sibling: `apps/bazarr` (Python app on the python base, `start.sh` runs `/usr/local/bin/python`). Python rules: `/app/venv` is read-only at runtime; use it directly or seed `/config/venv` only if writable persistent venv is required (not needed here: PMM has no venv write need, so use `/app/venv` read-only, and keep pip cache in `/tmp`).

Note the upstream image is Debian buster (3.11-slim-buster, EOL). The ContainerForge python base replaces it; the apt build deps and tini are handled by the base or installed in the Dockerfile.

## 4. Dockerfile

1. `FROM <python base> AS runtime`, `ARG VERSION` (matches bake), `ARG TARGETARCH`, `USER root`.
2. `mkdir -p /app/plex-meta-manager`. Fetch the pinned source: `curl -fL -o /tmp/pmm.tar.gz https://github.com/Kometa-Team/Kometa/archive/refs/tags/${VERSION}.tar.gz`, verify sha256 recorded in the build, then `tar xzf /tmp/pmm.tar.gz -C /app/plex-meta-manager --strip-components=1`.
3. Native wheels: install build deps only if a wheel is missing for arm64 (`apt-get install -y --no-install-recommends gcc g++ libxml2-dev libxslt-dev zlib1g-dev libjpeg-dev`), then purge them in the same layer. Do not install `tzdata` or `wget` if the base has them.
4. Install requirements into the venv: `/app/venv/bin/pip install --no-cache-dir -r /app/plex-meta-manager/requirements.txt`. Pip cache in `/tmp` (`PIP_CACHE_DIR=/tmp/pip`). Do not write to `/app/venv` at runtime (only at build).
5. `ENV PMM_DOCKER=True HOME=/config`. Caches to `/tmp`.
6. Licence: `mkdir -p /usr/share/licenses/plex-meta-manager && curl -fL -o /usr/share/licenses/plex-meta-manager/LICENSE https://raw.githubusercontent.com/Kometa-Team/Kometa/${VERSION}/LICENSE`.
7. `chown -R apps:apps /app/plex-meta-manager && chmod -R 755 /app/plex-meta-manager`.
8. Tini: the upstream uses tini as PID 1. Check whether the python or ubuntu base already provides `tini` (the ubuntu base installs `tini`, per `apps/ubuntu/Dockerfile`). If yes, do not download it. If no, install it from apt, pinned, rather than the upstream wget.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

VOLUME /config
WORKDIR /app/plex-meta-manager
```

No EXPOSE (no ports).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "plex-meta-manager"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Kometa-Team/Kometa versioning=semver
  default = "v1.21.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Kometa-Team/Kometa"
}
```

Four standard targets and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`. Keep the `v` prefix to match the release tag; the Dockerfile `ARG VERSION` matches. Run `docker buildx bake --print` from `apps/plex-meta-manager`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Kometa-Team/Kometa"
ports: []
env:
  - name: PMM_DOCKER
    default: "True"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`ports: []` (none; `ports` must list only real ports, rule in settings-yaml instructions). `dependencies`: none. Plex token and TMDb/TVDB keys are user-supplied in config.yml, not env (draft; UNVERIFIED for env names). Do not add env names that are not read.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config /tmp/pmm-cache

if [[ ! -f /config/config.yml ]]; then
  echo "No /config/config.yml found; the app needs one to run (see upstream docs)."
fi

cd /app/plex-meta-manager
exec python3 plex_meta_manager.py --config /config/config.yml
```

Notes:
- Idempotent. Never overwrites `/config/config.yml`. Seeding a template is not planned (UNVERIFIED that a template exists; check `defaults/` in the source before adding one).
- The `--config` flag is UNVERIFIED: the upstream Dockerfile passes only `--` after the script; read the argparse definition in `plex_meta_manager.py` at v1.21.0 before writing the exec line, and use the real flag.
- The app must read and write its cache and logs under `/config` or `/tmp`; check the source for relative paths (for example `logs/` and `cache`) and point them to `/config` or `/tmp` (UNVERIFIED).
- Use `exec` so tini or the base init handles signals.
- The script runs from the source dir, so relative `./` reads from `/app` and must only read.

## 8. container-test.yaml

No ports, so no tcp or http probes. Use the form of a sibling with no network listener (for example `apps/autoscan/container-test.yaml` or `apps/actions-runner/container-test.yaml`, which have no `tcp:` or `http:`; copy its shape, UNVERIFIED key names for process checks in forgetool).

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
filePaths:
- /app/plex-meta-manager/plex_meta_manager.py
- /app/plex-meta-manager/requirements.txt
- /usr/share/licenses/plex-meta-manager/LICENSE
```

Test runs without env vars and without a `config.yml`, so the app will exit or log the missing config. The protocol's readiness check (process still running, positive signal in logs) does not fit a run that exits without config: either supply a minimal config through a fresh `/config` volume in the local run (protocol step 3), or narrow the test with the protocol's rules and say so. Do not invent a passing assertion. Timeout 120 is UNVERIFIED: `apps/bazarr` sets no `timeoutSeconds`; the repo values are 120 to 600 (180 most common).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Upstream runs as root (no USER) | `USER apps` in the final stage |
| `/config` (VOLUME upstream) | Kept as `/config` (persistent) |
| Build-time pip cache and temp | `/tmp` (`PIP_CACHE_DIR=/tmp/pip`), build stage only |
| Runtime cache, logs (UNVERIFIED paths) | `/config` or `/tmp`; no writes to `/app/plex-meta-manager` at runtime |
| Upstream `COPY . /` (source at `/`) | Source installed to `/app/plex-meta-manager` (Python source is read-only at runtime) |
| Draft security expectations (runAsUser 0, readOnlyRootFilesystem false, privileged false) | Reconciled: rootless `apps`, read-only rootfs with `--tmpfs /tmp`; no extra persistence beyond `/config`. |

## 10. Risks, caveats and open questions

- **Upstream rename and version**: Kometa v2.5.5 is the latest (2026-11-11). The chart's v1.21.0 is from 2024 on EOL Debian buster. Decide: pin v1.21.0 (reviewed here) or move to v2.x, which needs its own Dockerfile and entrypoint review (not fetched, UNVERIFIED).
- **Python version**: upstream pins Python 3.11; the python base is 3.15.2. Confirm the requirements install and run on 3.15 (wheel availability UNVERIFIED for the pinned requirements).
- **Config**: the app needs a user-written `config.yml` with Plex token and TMDb/TVDB keys (draft, not verified on a fetched page).
- **First run**: may take a long time on large libraries (draft, inferred).
- **Native wheels on arm64**: UNVERIFIED for the requirements set.
- **Container test**: no port, no default config; the readiness check needs a config (section 8).
- **Blockers**: none confirmed; the v2 decision above is the main one.

## 11. Build and test steps

From `apps/plex-meta-manager`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create plex-meta-manager-probe-config`
4. `docker run --rm -d --name plex-meta-manager-probe --read-only --tmpfs /tmp -v plex-meta-manager-probe-config:/config plex-meta-manager:v1.21.0`
5. `docker logs -f plex-meta-manager-probe`: with an empty `/config`, expect the "no config" message and a clean exit or a wait state. Record which. The protocol's pass criteria need a process still running plus a readiness signal, so run once with a minimal `config.yml` seeded into the volume (test data only, no secrets) to observe the real readiness line (UNVERIFIED text).
6. `forgetool containers test --image plex-meta-manager:v1.21.0 --config ./apps/plex-meta-manager/container-test.yaml`
7. Clean up: `docker rm -f plex-meta-manager-probe; docker volume rm plex-meta-manager-probe-config`.

## 12. PR checklist

- Branch `feat/add-plex-meta-manager`, commit `feat(plex-meta-manager): add new container`, PR title the same, target `main`.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; only tick what was done.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- State what is untested: the full Plex run (no Plex server or API keys), arm64 build, Python 3.15 compatibility, checksum (none upstream), v2.x not reviewed.
- Pre-completion checklist from `.github/copilot-instructions.md` (bake print, version alignment, rootless, empty `/config`, no DOWNSTREAM file needed).
