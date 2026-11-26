# retrobot — implementation plan
> Source: ./draft.md · Target: apps/retrobot/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No release or tag found. Pin a commit on `master`. Draft commit `d04ddd8` (short SHA as written in the draft; full SHA UNVERIFIED). Chart image `ghcr.io/rossimo/retrobot:latest` (tag list UNVERIFIED). |
| Renovate | `datasource=git-refs depName=https://github.com/rossimo/retrobot currentValue=master` (precedent `apps/tvheadend`). |
| License | MIT (https://api.github.com/repos/rossimo/retrobot) |
| Source URL | https://github.com/rossimo/retrobot |
| Download | Source archive `https://github.com/rossimo/retrobot/archive/${VERSION}.tar.gz` (VERSION = commit SHA). No prebuilt binary. Interpreted Node (TypeScript via `ts-node`). |
| Checksum source | None published. Commit SHA pin is the only integrity anchor. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/rossimo/retrobot/d04ddd8/Dockerfile (summarized, not verbatim): `alpine:3.16.2`, WORKDIR `/retrobot`, apk `nodejs npm git python3 xz-dev make g++`, `npm -g` yarn cross-env forever, COPY context, `yarn install` then cache clean, `CMD ["yarn","start"]`. No ENTRYPOINT, USER, VOLUME, EXPOSE or ENV. |
| package.json | At `d04ddd8` the package name reads `libretro-webassembly-simple` (version 1.0.0, MIT, `start: ts-node src/index.ts`). Mismatch with the name `retrobot`. See section 10. |
| npm `retrobot` | https://registry.npmjs.org/retrobot/latest is a different project: "Slack bot for retrospectives", Apache-2.0, version 1.0.0. The draft's `npm:retrobot` binary reference is NOT the same app. Do not install it. |
| Port | None documented or exposed (no EXPOSE, no listener found). |
| Env vars | UNVERIFIED: none documented on fetched pages. The chat-service token is supplied by the user (draft inference, not confirmed in code). |
| Data path | Chart mounts `/retrobot/data` (draft, chart values). Upstream write path not confirmed. |

## 2. Target layout

- `apps/retrobot/Dockerfile`
- `apps/retrobot/docker-bake.hcl`
- `apps/retrobot/settings.yaml`
- `apps/retrobot/container-test.yaml`
- `apps/retrobot/start.sh`

No `defaults/`, `etc/`, `scripts/` or `health/` needed. Do not use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Draft suggests `ghcr.io/trueforge-org/python-node` as runtime. The porter base table maps Node to `ghcr.io/trueforge-org/ubuntu`. Recommendation: use `python-node`, which is the only repo base that ships Node (used by `apps/budge`), and record the deviation from the table in the PR. Use the digest exactly as in the brief:

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Closest sibling: `apps/budge` (Node backend and frontend built in the image, `USER apps`, `COPY --chmod=0755 . /`). Do not use `apps/python` (the app is not Python). The `python-runtime` rules do not apply, since there is no venv.

Node version: UNVERIFIED which Node the base provides and whether `ts-node`/`yarn` run on it. Check with `node --version` in the built image before pinning anything.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install only what the build needs and is missing from the base. Base already has Node/npm (verify). Add `build-essential` and `python3` only if a native module fails to build (draft inference, UNVERIFIED). Use `apt-get install -y --no-install-recommends`.
3. Fetch the pinned source: `curl -fL -o /tmp/retrobot.tar.gz "https://github.com/rossimo/retrobot/archive/${VERSION}.tar.gz"` and `tar xf ... -C /app --strip-components=1`. Use `/app` only for the read-only app tree.
4. Install yarn. Upstream `npm -g yarn`. If the base provides yarn, do not reinstall it. Otherwise install yarn with `npm install -g yarn` pinned to a version (UNVERIFIED version).
5. `cd /app && yarn install --frozen-lockfile` (lockfile presence UNVERIFIED). Then clear caches with `YARN_CACHE_FOLDER=/tmp/yarn` so no cache lands in `/app` or `/config`.
6. `chown -R apps:apps /app && chmod -R 755 /app`. Do not add `forever` (upstream global) unless a start path needs it; `yarn start` is enough.
7. Cleanup: `rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*`.
8. License: `mkdir -p /usr/share/licenses/retrobot && cp /app/LICENSE /usr/share/licenses/retrobot/` (path inside the source archive UNVERIFIED; it is at repo root per the GitHub license detection).
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

ENV HOME=/tmp \
    YARN_CACHE_FOLDER=/tmp/yarn

VOLUME /config
WORKDIR /app
```

No `EXPOSE`: the app has no listener (section 1). Add one only if a port is confirmed.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "retrobot"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/rossimo/retrobot currentValue=master
  default = "<full commit SHA>"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/rossimo/retrobot"
}
```

Then the four standard targets (`image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }` copied from `apps/adguardhome-sync/docker-bake.hcl`. The `VERSION` must be a full commit SHA, since the Dockerfile fetches that exact archive. Validate with `docker buildx bake --print` from `apps/retrobot`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rossimo/retrobot"
ports: []
env: []
volumes:
  - path: /config
    required: false
dependencies: []
```

- `ports: []`: nothing is listened on (section 1). The schema rule "every port the container exposes" is then satisfied by an empty list. Do not invent ports.
- `env: []` until the real variable names are confirmed from the source (see section 10). Do not list `BOT_TOKEN`-style names by guess.
- `volumes`: the draft says the chart writes `/retrobot/data`. In ContainerForge the write path must be `/config`. Use `/config`, and map any bot data file to `/config` in `start.sh` if the source writes to a path (to be confirmed).
- `dependencies: []`: no database confirmed. The chat service is external.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data
cd /app || exit 1
exec yarn start
```

- Idempotent. Creates `/config/data` only if missing. Writes nothing to `/app`.
- The data path must match what the source really writes. Replace `/config/data` with the confirmed path, or symlink it at build time if the source uses a fixed path (open question, section 10).
- Bind and listen behavior: no listener. Readiness must come from the process staying alive and a log line (see section 8).
- `exec` so signals reach the Node process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/package.json
- /app/node_modules
- /usr/share/licenses/retrobot
```

- No `tcp` or `http` probes: there is no port (matches `ports: []`).
- Test runs with no env vars. If `yarn start` exits without a chat token, the test cannot prove readiness with a process check. Record this as a blocker (section 10). Do not weaken or drop the run check; do not add a fake token. If the source does start without a token, add a `runners` process-alive check following the `apps/bookstack` pattern (`runners: - entrypoint: ...`).
- Required-env code paths (token-dependent startup) are not exercised by this suite: list their files in `filePaths` and run that path by hand per the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/retrobot/data` (chart mount, draft) | `/config/data` (VOLUME `/config`). Confirm the source path first. |
| yarn cache (`~/.cache/yarn`) | `YARN_CACHE_FOLDER=/tmp/yarn` |
| npm/node HOME | `HOME=/tmp` (so tools do not write to `/root` or `/home`) |
| `ts-node` compile cache, if any | `/tmp` (set `TS_NODE_CACHE` only if the source reads a cache dir; UNVERIFIED) |
| apt lists/cache | removed in the build step |

- Runs as `apps` (`USER apps`). The upstream image had no `USER`, so it ran as root. The draft's security expectation of non-root (`runAsUser 568`) is consistent with the port.
- Draft expectations to reconcile: `readOnlyRootFilesystem: true`, `privileged: false`, no extra persistence beyond `/config`. These match ContainerForge defaults. Confirm the source writes nothing outside `/config` and `/tmp`, else adapt.

## 10. Risks, caveats and open questions

- Identity conflict (blocker until resolved): `d04ddd8` `package.json` says `libretro-webassembly-simple`, while the npm package `retrobot` is a different Slack retro bot (Apache-2.0). The draft's `npm:retrobot` binary is wrong for this app. Confirm the source repo and the commit before writing `VERSION`.
- Chart image `ghcr.io/rossimo/retrobot:latest` is not tied to a tag. The Dockerfile in the draft is from `d04ddd8`; confirm that the published image was built from it (UNVERIFIED).
- No port and no documented env vars. Readiness and config names are UNVERIFIED until the source's entry code is read.
- Bot token: required at runtime, supplied by the user. Do not bake it into the image. Confirm whether the source exits at start without it (affects the test, section 8).
- Node base: the porter table says Node maps to ubuntu; this plan uses python-node (budge precedent). Confirm the Node major version works with the source's dependencies.
- Native modules: `yarn install` may need `build-essential` and `python3` (draft inference). Do not add them unless the install fails; then remove them from the final image.
- Blockers: no arm64 issues are known (JS only), but arm64 has not been tested. `UNVERIFIED`.

## 11. Build and test steps

From `apps/retrobot` (one app at a time, per the protocol):

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe run, empty `/config`:

```sh
docker volume create retrobot-probe-config
docker run --rm -d --name retrobot-probe --read-only --tmpfs /tmp \
  -v retrobot-probe-config:/config retrobot:<version>
docker logs -f retrobot-probe
```

   Pass: container still running after the startup window, a readiness line from the source (for example a "connected" or "started" message; exact text UNVERIFIED), and no fatal error or repeated stack trace. Without a token the expected result may be a clean exit; if so, record it as the known limit, not a pass.
4. `forgetool containers test --image retrobot:<version> --config ./apps/retrobot/container-test.yaml`
5. Cleanup: `docker rm -f retrobot-probe; docker volume rm retrobot-probe-config`.
6. arm64 only if amd64 fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-retrobot`, commit `feat(retrobot): add new container`, target `main`.
- PR title matches the commit.
- Body: upstream source and commit SHA, base image and digest, ports (none) and volumes (`/config`), what was tested and what was not. State that the bot token was not available if it was not.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply. Do not check "Built container locally" unless the build and probe ran.
- Untested items to list: arm64 build, token-based startup, the readiness signal, and the npm identity question.
