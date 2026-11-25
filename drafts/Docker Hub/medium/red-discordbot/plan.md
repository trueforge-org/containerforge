# red-discordbot — implementation plan
> Source: ./draft.md · Target: apps/red-discordbot/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Blocker first: Red-DiscordBot 3.5.24 requires Python `<3.12`, and the ContainerForge `python` base is 3.15.2. The Dockerfile cannot use `ghcr.io/trueforge-org/python` as-is. See section 3 and section 10 before writing any file.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.5.24`. Latest GitHub release and latest PyPI release (uploaded 2026-03-06). Source: https://pypi.org/pypi/Red-DiscordBot/json and https://github.com/Cog-Creators/Red-DiscordBot/releases/tag/3.5.24. The draft names no version. |
| Renovate | `// renovate: datasource=pypi depName=Red-DiscordBot versioning=pep440` (convention; repo renovate config not fetched) |
| License | GPL-3.0 (https://github.com/Cog-Creators/Red-DiscordBot/blob/V3/develop/LICENSE; GitHub API `spdx_id` GPL-3.0) |
| Source URL | https://github.com/Cog-Creators/Red-DiscordBot |
| Python constraint | `requires_python = "<3.12,>=3.8.1"` (PyPI JSON). Upstream image uses `python:3.11-slim-bookworm`. |
| Per-arch download | Application: PyPI wheel/sdist `Red-DiscordBot==3.5.24` (architecture-independent for the pure parts; `apsw`, `uvloop`, `orjson`, `zstandard`, `brotli`, `rapidfuzz`, `psutil` need wheels or a build on each arch). Upstream Hub images: amd64, arm64, arm (`full`, `latest`, `full-py311`). |
| Checksum source | PyPI file hashes (JSON API `digests`), enforced by pip. No separate checksum file. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/PhasecoreX/docker-red-discordbot/79e918d9c2cd87e249a1ed1a708a8b5f54f1d070/Dockerfile (python 3.11 bookworm; apt build-essential, git, libsodium-dev, libffi-dev, jq, openssh-client; `ENV SODIUM_INSTALL=system`; `VOLUME /data`; `ENTRYPOINT user-entrypoint`; variants core / extra / core-audio / extra-audio / core-pylav / extra-pylav; `CMD /app/start-redbot.sh`) |
| Upstream start flow | https://raw.githubusercontent.com/PhasecoreX/docker-red-discordbot/79e918d9c2cd87e249a1ed1a708a8b5f54f1d070/root/app/start-redbot.sh and `root/app/functions/setup-env.sh`: creates `/data/venv` (Python venv so cogs can pip install as the non-root user), records `/data/venv/.pyversion` and recreates the venv on change, symlinks `~/.config/Red-DiscordBot/config.json` to `/data/config.json`. `main-loop.sh` not fetched (UNVERIFIED: behaviour with no TOKEN). |
| Env vars (real) | Per README (https://raw.githubusercontent.com/PhasecoreX/docker-red-discordbot/79e918d9c2cd87e249a1ed1a708a8b5f54f1d070/README.md): `TOKEN`, `OWNER`, `PREFIX`, `PREFIX2`-`PREFIX5` (persisted to the bot config on first run), `STORAGE_TYPE` (default json), `REDBOT_VERSION`, `EXTRA_ARGS`, `CUSTOM_REDBOT_PACKAGE` (advanced), `TZ` (default UTC), `PUID`/`PGID` (upstream user mapping), `NICENESS`. |
| Data path | `/data` upstream (README `-v ...:/data`). The draft's `/config` is wrong for upstream; ContainerForge maps this to `/config` (section 9). |
| Ports | No EXPOSE upstream. README documents no HTTP port. The RPC/dashboard port listens on localhost only. Port number: UNVERIFIED. Lavalink 2333: UNVERIFIED for this image. Draft's 42356 is UNVERIFIED. |
| arm64 | Yes: Hub `phasecorex/red-discordbot:full` lists amd64, arm64, arm (https://hub.docker.com/v2/repositories/phasecorex/red-discordbot/tags?name=full). |
| Dependencies | Discord bot token. No database by default (JSON datastore). PostgreSQL only if `STORAGE_TYPE=postgres`. |

## 2. Target layout

- `apps/red-discordbot/Dockerfile`
- `apps/red-discordbot/docker-bake.hcl`
- `apps/red-discordbot/settings.yaml`
- `apps/red-discordbot/container-test.yaml`
- `apps/red-discordbot/start.sh`

No `defaults/`, `etc/` or `health/` needed. No `root/` (never used by agents). `DOWNSTREAM_CHANGES.md` not needed (not a `FROM` base). The audio (Java) and PyLav variants are out of scope for this first PR (section 10).

## 3. Base image

Blocked choice. Two options:

- **Option A (preferred, matches upstream):** `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` with a pinned CPython 3.11 added in the build stage (for example a `uv`-managed or tarball-built 3.11 in `/usr/local`), then `/app/venv` created with it. The runtime then has no Python 3.15 dependency. The exact CPython 3.11 source and checksum are UNVERIFIED and must be pinned in the build.
- **Option B:** `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Not viable: Red 3.5.24 refuses Python 3.15 (`requires_python <3.12`).

Closest sibling: `apps/python` (venv at `/app/venv`, read-only rule) and `apps/bazarr` (python venv pattern; note Option A does not use the python base, so the `/app/venv` layout must be recreated by hand). Python rules apply: `/app/venv` is read-only; cogs' runtime installs go to `/config/venv`, seeded from `/app/venv` only when missing (python-runtime instructions).

## 4. Dockerfile

1. `FROM <base> AS build`; `ARG VERSION`; `ARG TARGETARCH`; `USER root`.
2. apt (only what the base lacks, and only what the build needs): `build-essential`, `libsodium-dev`, `libffi-dev` for the core variant. `git` is upstream's choice for SSH cog repos (UNVERIFIED whether it is needed). Skip the audio/PyLav packages (`libaio`, `openjdk`). Pin apt versions against the base release if any are added.
3. Install CPython 3.11 (option A) into `/usr/local`; create `/app/venv` with it; `ENV SODIUM_INSTALL=system`.
4. `pip install --no-cache-dir "Red-DiscordBot==${VERSION}"` into `/app/venv` with `PIP_CACHE_DIR=/tmp/pip`, then `--require-hashes` is preferred if hashes are exported (UNVERIFIED tooling).
5. Remove build-only packages; `rm -rf /var/lib/apt/lists/*`.
6. Final stage `FROM <base>`, `USER root` only for apt, then `USER apps`.
7. `COPY --chmod=0755 . /` (the allow-list includes `start.sh`).
8. `ENV PIP_CACHE_DIR=/tmp/pip HOME=/config`. `VOLUME /config`.
9. `ENTRYPOINT ["/start.sh"]` or `CMD ["/start.sh"]` consistent with siblings (check `apps/python/Dockerfile`).

No `EXPOSE`: no confirmed port (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "red-discordbot"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=Red-DiscordBot versioning=pep440
  default = "3.5.24"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Cog-Creators/Red-DiscordBot"
}
```

Use the license identifier from the upstream LICENSE text (GPL-3.0 per GitHub; the PyPI-published text is `GPL-3.0`, so `GPL-3.0-only` only if the LICENSE file says so: UNVERIFIED wording, use `GPL-3.0` if unsure). Then the four standard targets (`image`, `image-local`, `image-all`, default group) copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Cog-Creators/Red-DiscordBot"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: TOKEN
    default: ""
    required: false
  - name: OWNER
    default: ""
    required: false
  - name: PREFIX
    default: "!"
    required: false
  - name: STORAGE_TYPE
    default: "json"
    required: false
  - name: REDBOT_VERSION
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

The header above is the one used by sibling `settings.yaml` files. Only list env vars the app reads (names confirmed in section 1). `ports: []` because no port is confirmed (section 10). `dependencies: []`; PostgreSQL is only needed for `STORAGE_TYPE=postgres`, so it is not a hard dependency and goes under `opt_dependencies` if listed at all.

## 7. start.sh

- `set -eu`. Create `/config/data` if missing (`mkdir -p`).
- Set `redbot` data path to `/config/data` (verify flag on 3.5.24 with `redbot --help`: UNVERIFIED; alternatively keep upstream symlink behaviour with `HOME=/config`).
- Seed `/config/venv` from `/app/venv` only when `/config/venv` is missing or empty (real directory, not a symlink).
- If `TOKEN` is set and no bot config exists, pass it through as upstream does; never log it.
- Apply `PREFIX`, `OWNER` only when set. Values are passed as arguments or env, never through `eval` or unquoted shell.
- Idempotent. No writes under `/app`. Caches in `/tmp`.
- End with `exec` of the bot process so signals reach it (PID 1 handoff).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
filePaths:
  - /app/venv/bin/redbot
  - /app/venv/lib
```

No `tcp` or `http` probes because `settings.yaml` has no ports. The test runs with no env vars, so the bot will not connect to Discord. Readiness is checked by the run step (section 11): the process stays alive and logs no traceback. UNVERIFIED: whether Red exits without `TOKEN`. If it does, the protocol's required-env path needs the first-run path covered by `filePaths` and a manual run with a fake token (not a real one).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (config.json, cogs, core, venv, pylav) | `/config` (`HOME=/config`, data under `/config/data`) |
| `/data/venv` (cog pip installs) | `/config/venv`, seeded from `/app/venv` (python-runtime rule) |
| `~/.config/Red-DiscordBot` (symlink to `/data/config.json`) | Under `/config` via `HOME`, no symlink into `/app` |
| pip cache | `PIP_CACHE_DIR=/tmp/pip` |
| apt/pip at build time | build stage only; nothing at runtime |

Draft expectations reconciled: the chart runs as UID 0 (this image runs as `apps`, UID per base), chart `readOnlyRootFilesystem: false` (the image is designed for `--read-only --tmpfs /tmp`), chart `privileged: false`. Chart mount `/data` must be re-pointed to `/config`; existing users must copy their data into `/config`.

## 10. Risks, caveats and open questions

- **Python 3.11 required (blocker):** Red 3.5.24 has `requires_python <3.12`. Option A in section 3 is the path; pinning CPython 3.11 is UNVERIFIED work.
- **No confirmed port:** the dashboard/RPC port and Lavalink 2333 are UNVERIFIED. Do not invent a port. Re-check the source before adding `ports:`.
- **No TOKEN start path:** `main-loop.sh` not fetched. Verify whether Red exits without `TOKEN` (test runs without env).
- **Cog pip installs at runtime:** the venv in `/config/venv` is writable and persistent; a cog can install an incompatible package. Upstream recreates the venv when the Python version changes (`.pyversion`); copy that check.
- **Audio/Java variants out of scope:** upstream `-audio` variants need `openjdk-17-jre-headless` and outbound access for audio sources. The `java17` base is the alternative. Separate PR.
- **Storage path mismatch:** draft says `/config`; upstream uses `/data`. Resolved in section 9.
- **Draft's Discord token expectation:** a bot token from the Discord developer portal is required for a working bot (README). Not a test requirement.
- **License identifier:** confirm `GPL-3.0` vs `GPL-3.0-only` against the LICENSE file before writing docker-bake.hcl.

## 11. Build and test steps

```sh
cd apps/red-discordbot
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name red-discordbot-probe --read-only --tmpfs /tmp \
  -v red-discordbot-probe-config:/config red-discordbot:3.5.24
docker logs -f red-discordbot-probe
forgetool containers test --image red-discordbot:3.5.24 --config ./apps/red-discordbot/container-test.yaml
docker rm -f red-discordbot-probe; docker volume rm red-discordbot-probe-config
```

Expected readiness signal: Red's startup banner or `Logged into Discord` (only with a real token). Without a token, the success criterion is the process staying alive with no traceback (UNVERIFIED text; capture the first 100 log lines in round 1). Also run one manual test with a fake `TOKEN` to confirm the venv seeding path (`/config/venv` created, `/app` unchanged). Use a separate volume for that run.

## 12. PR checklist

- Branch `feat/add-red-discordbot`, commit and PR title `feat(red-discordbot): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Say what was not tested: the image was not built or run unless the build steps in section 11 were done; name the blockers (Python 3.11, port, TOKEN path).
- `docker buildx bake --print` must pass; bake `VERSION` equals Dockerfile `ARG VERSION`.
