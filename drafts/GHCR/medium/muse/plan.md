# muse — implementation plan
> Source: ./draft.md · Target: apps/muse/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest stable | `v2.12.0` (published 2026-10-30), https://github.com/museofficial/muse/releases/tag/v2.12.0. Draft tag `2.12.0` matches. |
| renovate | `datasource=github-releases depName=museofficial/muse versioning=loose` (tags are `vX.Y.Z`, so strip the `v` in the Dockerfile or use `versioning=semver` with the tag form, matching a sibling app) |
| License | MIT (`package.json` at v2.12.0 `"license": "MIT"`; GitHub API `museofficial/muse` MIT). |
| Source URL | https://github.com/museofficial/muse |
| Upstream Dockerfile reviewed | v2.12.0 (https://raw.githubusercontent.com/museofficial/muse/v2.12.0/Dockerfile): multi-stage on `node:22-bookworm-slim`. `base`: apt `ffmpeg tini openssl ca-certificates python3 python3-venv`; `python3 -m venv /opt/yt-dlp`; `pip install "yt-dlp[default]"` (or `==${YT_DLP_VERSION}` when set); symlink `/usr/local/bin/yt-dlp`; `ENV MUSE_BUNDLED_YT_DLP_PATH=/opt/yt-dlp/bin/yt-dlp`. `dependencies`: `python-is-python3 build-essential`, `yarn install --prod` into `prod_node_modules`, then `yarn install`. `builder`: `yarn prisma generate`, `yarn build`. `runner`: copies `dist`, prod modules, `.prisma/client`; `ENV DATA_DIR=/data NODE_ENV=production ENV_FILE=/config`; `CMD ["tini","--","node","--enable-source-maps","dist/scripts/migrate-and-start.js"]`. No `USER`, no `EXPOSE`, no `VOLUME`. |
| Node and yarn | `package.json`: `engines.node >=22.12.0`; `packageManager: yarn@1.22.22`. |
| Env vars (`.env.example` v2.12.0 and README) | `DISCORD_TOKEN` (required), `YOUTUBE_API_KEY` (required per README), `SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET` (optional), `DATA_DIR` (`./data`; image `/data`), `CACHE_LIMIT` (~2GB default), `YT_DLP_PATH`, `YT_DLP_AUTO_UPDATE`, `YT_DLP_COOKIES_PATH`, `ENABLE_SPONSORBLOCK`, `SPONSORBLOCK_TIMEOUT`, `PLAYING_MESSAGE_UPDATE_INTERVAL_SECONDS`, `BOT_STATUS`, `BOT_ACTIVITY_TYPE`, `BOT_ACTIVITY_URL`, `BOT_ACTIVITY`. `ENV_FILE` default `/config` (README: "the container will look for a `/config` environment file"). |
| Ports | None (`EXPOSE` absent). The bot only makes outbound connections to Discord and YouTube. |
| Paths | `/data` (`DATA_DIR`, persisted DB and cache). The SQLite file path and the cache subfolder: UNVERIFIED (not located in the fetched files). |
| yt-dlp | Required; the README says yt-dlp needs frequent updates, and YouTube extraction needs a JS runtime: the image bundles `yt-dlp-ejs` and uses its Node runtime (README line 229). Current yt-dlp version: UNVERIFIED (not fetched; pick at build time). |
| Container image | `ghcr.io/museofficial/muse:2.12.0` (GHCR is canonical per README). |
| arm64 | `node:22-bookworm-slim` is multi-arch. Debian ffmpeg and python3 are available for amd64 and arm64 (inferred from the distro, not fetched). |
| Dependencies | None inside ContainerForge. External accounts: Discord bot token, YouTube API key. Database: SQLite via Prisma (inferred from `prisma generate`; UNVERIFIED path). |

## 2. Target layout

- `apps/muse/Dockerfile`
- `apps/muse/docker-bake.hcl`
- `apps/muse/settings.yaml`
- `apps/muse/container-test.yaml`
- `apps/muse/start.sh`

No `defaults/` (the bot creates its DB on first run via `migrate-and-start`). No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Use `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (brief). It covers both Python (pip for yt-dlp) and Node (muse). Closest sibling: `apps/changedetection` (python-node, `/app/venv`, `USER apps`, `COPY --chmod=0755 . /`).

Node version inside `python-node`: UNVERIFIED. Muse needs `>=22.12.0`. Check it in the build (`node --version`). If it is older, use `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` and install Node 22 from the official tarball, verified against `SHASUMS256.txt`. Decide in the build step, not at review.

## 4. Dockerfile

1. Build stage on the python-node base: `ARG VERSION`, `ARG YT_DLP_VERSION`, `ARG TARGETARCH`. `// renovate` annotations: `VERSION` github-releases; `YT_DLP_VERSION` pypi `depName=yt-dlp`.
2. `USER root`, `apt-get install -y --no-install-recommends ffmpeg tini openssl ca-certificates python3-venv build-essential`, clean `/var/lib/apt/lists/*`. Do NOT reinstall what the base has (check python3, node, ca-certificates first). Pin apt versions only if the sibling pattern does (`apps/valkey`).
3. yt-dlp in a venv under `/opt/yt-dlp`: `python3 -m venv /opt/yt-dlp && /opt/yt-dlp/bin/pip install --no-cache-dir "yt-dlp[default]==${YT_DLP_VERSION}"`, symlink `/usr/local/bin/yt-dlp`. Set `ENV MUSE_BUNDLED_YT_DLP_PATH=/opt/yt-dlp/bin/yt-dlp`.
4. Source: the tarball `https://github.com/museofficial/muse/archive/refs/tags/${VERSION}.tar.gz` (`VERSION=v2.12.0`), extracted to `/tmp/src`. No checksum is published; record the sha256 of the tarball in the PR. Fallback: `git clone --branch ${VERSION}`.
5. In `/tmp/src`: `corepack`/`npm i -g yarn@1.22.22` (pinned to the repo's `packageManager`), `yarn install --frozen-lockfile --prod` → copy `node_modules` to `/tmp/prod_node_modules`; `yarn install --frozen-lockfile`; `yarn prisma generate`; `yarn build`. Keep `/tmp` out of the final image (remove `/tmp/src` in the same RUN).
6. Final stage on the same base (`USER root` only for the copy/apt steps):
   - `mkdir -p /app/muse`, copy `dist/`, `/tmp/prod_node_modules` → `/app/muse/node_modules`, `node_modules/.prisma/client`, `package.json`, `prisma/` (migrations), and the license to `/usr/share/licenses/muse/LICENSE`.
   - `chown -R root:root /app/muse` and `chmod -R 755 /app/muse` (not writable at runtime).
7. Environment, with paths moved to `/config`:

```dockerfile
ENV NODE_ENV=production \
    DATA_DIR=/config \
    ENV_FILE=/config/muse.env \
    MUSE_BUNDLED_YT_DLP_PATH=/opt/yt-dlp/bin/yt-dlp \
    YT_DLP_AUTO_UPDATE=false \
    HOME=/tmp \
    npm_config_cache=/tmp/npm \
    YARN_CACHE_FOLDER=/tmp/yarn
VOLUME ["/config"]
WORKDIR /app/muse
USER apps
COPY --chmod=0755 . /
```

`ENV_FILE=/config/muse.env`, NOT `/config`: the upstream default is a file named `/config`, which conflicts with the `/config` volume directory. `YT_DLP_AUTO_UPDATE=false`: the venv under `/opt` is read-only at runtime, so self-update cannot write. Users who want updates rebuild the image.

8. No `EXPOSE`. No `CMD` in the Dockerfile; `start.sh` is the entrypoint (see section 7).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "muse"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=museofficial/muse versioning=loose
  default = "v2.12.0"
}

variable "YT_DLP_VERSION" {
  // renovate: datasource=pypi depName=yt-dlp versioning=pep440
  default = "<pin at build time>"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/museofficial/muse"
}
```

- The `VERSION` tag has a `v` prefix. The image tag `${APP}:${VERSION}` then becomes `muse:v2.12.0`, while the draft says `2.12.0`. Decide the tag form (keep `v2.12.0` to match the upstream release tag, or strip with `VERSION = "${trimprefix(VERSION, "v")}"`). Pick one and note it in the PR.
- `YT_DLP_VERSION` is a placeholder: pin the latest yt-dlp release available at build time, and record it in the PR. Do not leave the placeholder.
- Then the four standard targets and `group "default" { targets = ["image-local"] }`, args `VERSION` and `YT_DLP_VERSION`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/museofficial/muse"
ports:
  []
env:
  - name: DISCORD_TOKEN
    default: ""
    required: true
  - name: YOUTUBE_API_KEY
    default: ""
    required: true
  - name: SPOTIFY_CLIENT_ID
    default: ""
    required: false
  - name: SPOTIFY_CLIENT_SECRET
    default: ""
    required: false
  - name: CACHE_LIMIT
    default: "2GB"
    required: false
  - name: YT_DLP_AUTO_UPDATE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `required: true` env vars with an empty default must be handled by `start.sh` (see section 7 and the open question in section 10).
- Do not add `DATA_DIR`, `ENV_FILE` or `MUSE_BUNDLED_YT_DLP_PATH`: they are set in the image, not configuration for users. List `DATA_DIR` only if a user change is supported; the image is pinned to `/config`.
- `dependencies:` none. `ports:` empty (`[]`) because the bot opens no port.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

if [ -z "${DISCORD_TOKEN:-}" ]; then
  echo "DISCORD_TOKEN is not set; Muse cannot connect to Discord." >&2
  exit 1
fi

cd /app/muse
exec tini -- node --enable-source-maps dist/scripts/migrate-and-start.js
```

- `tini` is installed in the Dockerfile; `exec` keeps the process as the child of tini for signal handling. Confirm tini is the PID 1 wrapper, or use `exec node` if tini is not needed (`ffmpeg` children are reaped by tini).
- Idempotent: `migrate-and-start` runs Prisma migrations on each start; the DB lives under `/config` so it persists.
- Do not write to `/app/muse`. Caches go to `/tmp` where the code allows it; the Muse cache under `DATA_DIR` is intentionally persistent (see section 9).
- Keep the env file optional: if `/config/muse.env` is missing, the code must not fail. UNVERIFIED: check the code path in `src/` on a clean `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
filePaths:
- /app/muse/dist/scripts/migrate-and-start.js
- /app/muse/node_modules/.prisma/client
- /opt/yt-dlp/bin/yt-dlp
- /usr/bin/ffmpeg
- /usr/share/licenses/muse/LICENSE
```

- No `tcp` or `http` probe: the bot opens no port (settings `ports: []`).
- The test runs with no env vars. `DISCORD_TOKEN` is unset, so the bot will exit with the message in `start.sh`. That is a real failure under the protocol's step 3 (the container must still be running). See the open question in section 10. Do not drop the check silently.
- Process-level check is not available in the schema used here: UNVERIFIED whether forgetool supports a process probe. Use filePaths only, unless the schema allows more.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (DB, cache, `DATA_DIR`) | `/config`. Existing users must move their `/data` to `/config`. |
| `/data` cache (CACHE_LIMIT, yt-dlp output) | Stays under `/config` (persistent by design, sized by `CACHE_LIMIT`). The exact subfolder: UNVERIFIED. If the code also writes to `/tmp`, that is fine. |
| `ENV_FILE=/config` (a file, upstream) | `/config/muse.env` (avoids a clash with the `/config` directory). |
| npm, yarn caches | `/tmp` (`npm_config_cache`, `YARN_CACHE_FOLDER`). |
| yt-dlp self-update into the venv | Disabled (`YT_DLP_AUTO_UPDATE=false`); the venv is read-only at runtime. |
| `HOME` | `/tmp`. |
| Node `node_modules` | Read-only in the image. Prisma engines are generated at build. |

Draft security expectations, reconciled: the chart runs as runAsUser 0 and readOnlyRootFilesystem false. This image runs as `apps` (568) and is read-only compatible, so the chart values must change; the draft's root expectation is not kept. Privileged no.

## 10. Risks, caveats and open questions

- **Discord token and test (decision needed):** the bot needs `DISCORD_TOKEN` and exits without it. The test has no env, so the container exits and step 3 fails. Options: (a) start.sh stays up and logs the missing token (the process then never connects), (b) fail fast and document the exception. The protocol's DB exception does not cover this (no DB dependency), so the user must decide.
- **yt-dlp churn:** playback breaks without yt-dlp updates. Pinning yt-dlp is needed for reproducible builds, but the image will go stale: renovate must bump `YT_DLP_VERSION` often.
- **YouTube JS runtime:** yt-dlp needs a JS runtime for YouTube. The image uses the Node it has; confirm `yt-dlp-ejs` works on the chosen Node version.
- **Node version:** `>=22.12.0` required; `python-node` version UNVERIFIED (section 3).
- **Tag form:** `v2.12.0` vs `2.12.0` (section 5).
- **Prisma:** migrations run on every start (`migrate-and-start`); a rollback needs the DB under `/config` restored first.
- **Upstream Docker Hub:** GHCR is canonical (README). Do not publish to Docker Hub.
- No blockers: no GPU, not privileged, arm64 expected to work (not tested).

## 11. Build and test steps

```sh
cd apps/muse
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name muse-probe --read-only --tmpfs /tmp \
  -e DISCORD_TOKEN=test -e YOUTUBE_API_KEY=test \
  -v muse-probe-config:/config muse:v2.12.0
docker logs -f muse-probe

forgetool containers test --image muse:v2.12.0 --config ./apps/muse/container-test.yaml

docker rm -f muse-probe; docker volume rm muse-probe-config
```

- Expected readiness signal: the migration log line from `migrate-and-start`, then the Discord login attempt. A fake token will fail login: that is expected, so the test checks the process stays up through migrations, not that the bot is online (state this in the PR).
- Also log `node --version` and `yt-dlp --version` inside the image (`docker run --rm --entrypoint sh ...`).
- Test an empty `/config` volume, a restart on the same volume, and arm64 only if the build is run with `--set image-local.platform=linux/arm64`.

## 12. PR checklist

- Branch `feat/add-muse`, commit `feat(muse): add new container`, PR title the same, target `main`.
- CLA: sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Notes section contains `🤖 This PR is AI generated.`; fill in `.github/PULL_REQUEST_TEMPLATE.md`, check only applicable boxes.
- State what was not tested: a real Discord login, playback, YouTube extraction, arm64, the tarball checksum (none published), and whether `python-node` ships Node 22.12+.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
