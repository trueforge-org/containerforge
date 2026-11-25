# rss-to-telegram — implementation plan
> Source: ./draft.md · Target: apps/rss-to-telegram/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2.0.9` (latest tag; GitHub release published 2024-02-15, no assets). The draft's value is correct. Repo last pushed 2024-06-17, so upstream is stale. |
| Renovate | `// renovate: datasource=github-tags depName=BoKKeR/RSS-to-Telegram-Bot versioning=semver` (tags are plain semver `2.0.9`; no release assets) |
| License | CONFLICT. GitHub repo SPDX is `GPL-3.0` (https://api.github.com/repos/BoKKeR/RSS-to-Telegram-Bot). `package.json` says `"license": "MIT"` (https://raw.githubusercontent.com/BoKKeR/RSS-to-Telegram-Bot/3675d2e9c4d9731cec685a8417f7b724e2921e9a/package.json). UNVERIFIED which applies: read the `LICENSE` file at tag `2.0.9` before setting `LICENSE` in `docker-bake.hcl`. |
| Source URL | https://github.com/BoKKeR/RSS-to-Telegram-Bot |
| Download | Source tarball only: `https://github.com/BoKKeR/RSS-to-Telegram-Bot/archive/refs/tags/${VERSION}.tar.gz`. No binary assets. amd64 and arm64 are both `compile`. The draft's `yes` for both is corrected here. |
| Checksum source | None published. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/BoKKeR/RSS-to-Telegram-Bot/3675d2e9c4d9731cec685a8417f7b724e2921e9a/Dockerfile: two stages, both `FROM mhart/alpine-node:16` (Alpine, musl). Builder: `COPY . .`, `npm ci --omit=dev`, `npm run build`. Final: `mkdir config`, copies `lib/`, `dist/`, `package.json`, `node_modules/`, `prisma/`, `start_bot.sh`; `RUN apk add sqlite`; `ENTRYPOINT ["./start_bot.sh"]`. No ENV, EXPOSE, VOLUME, USER. |
| Node version | `.nvmrc` = `v16.14.2` (https://api.github.com/repos/BoKKeR/RSS-to-Telegram-Bot/contents/.nvmrc). Node 16 is EOL. Target node sibling is Node 26.13.1 (`apps/ubuntu/docker-bake.hcl`). Major version jump, untested. |
| Env vars (real) | From README Docker section (https://github.com/BoKKeR/RSS-to-Telegram-Bot#docker) and `.env.example` (https://api.github.com/repos/BoKKeR/RSS-to-Telegram-Bot/contents/.env.example): `TOKEN` (`chat:token`, Telegram bot token), `CHATID` (target chat ID), `DEBUG` (`true`/`false`), `REDIS_HOST`, `REDIS_PORT` (6379), `REDIS_USER`, `REDIS_PASSWORD`, `REDIS_MUTEX` (random value). |
| Ports | None. No `EXPOSE`. The bot is outbound-only to Telegram (polling vs webhook UNVERIFIED). |
| Data and config paths | `start_bot.sh` (same tag) uses `config/rss_bot_database.db` (SQLite, relative to `/app`), migrates a legacy Python `config/rss.db` into `config/backup_python_rss.db` and `config/rss_bot_database.db`, then runs `./node_modules/.bin/prisma migrate`. Prisma datasource URL: UNVERIFIED (prisma schema not fetched). |
| Dependencies | **Redis, required**, for the Bull queue (README: "This container uses Redis and Bull for queuing the messages"). This corrects the draft's "Hard dependency containers: no" and "Dependency containers: none". `apps/valkey` exists in this repo (Redis-compatible). |
| Docker Hub `bokker/rss.to.telegram` | Built on musl (Alpine). `copy-from amd64` = no, `copy-from arm64` = no. Do not use `COPY --from`. |

## 2. Target layout

Files under `apps/rss-to-telegram/`:

- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh` (migrates DB on first start, then `exec`s the bot)

No `defaults/` (config comes from env). No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Build and final stage: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (node sibling, as the draft says). Alternative: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (has Node 26.13.1, no Python). Pick the ubuntu base if Python is not needed; this app is Node only.
- Node version in `python-node` is UNVERIFIED: `apps/budge` comments say "Node 24" for its base, so check `node --version` in the base before building.
- Closest siblings: `apps/budge` (Node app on `python-node`, `/config` for the SQLite DB via `start.sh`), `apps/changedetection` (node).

## 4. Dockerfile

1. `FROM <base> AS build`: `ARG VERSION`, `ARG TARGETARCH`, `USER root`. `ENV npm_config_cache=/tmp/npm` (caches to `/tmp`).
2. Download and extract the source at the tag:
   ```dockerfile
   RUN curl -fL "https://github.com/BoKKeR/RSS-to-Telegram-Bot/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/rss.tar.gz && \
       mkdir -p /app && tar xzf /tmp/rss.tar.gz -C /app --strip-components=1 && rm /tmp/rss.tar.gz
   ```
3. `WORKDIR /app`, then `npm ci` (not `--omit=dev`, because `prisma` and `nest` CLIs may be devDependencies; decide after reading `package.json` devDependencies, UNVERIFIED) and `npm run build` (runs `prebuild`, `build`, `postbuild` scripts).
4. Prisma: `npx prisma generate` if the client needs generation (UNVERIFIED whether the build already runs it).
5. Final stage (same base): `USER root`:
   - `apt-get install -y --no-install-recommends sqlite3` (upstream `apk add sqlite`; `start_bot.sh` calls `sqlite3` for the legacy migration). `apt-get clean && rm -rf /var/lib/apt/lists/*`.
   - Copy the built tree: `COPY --from=build /app /app`.
   - `ln -s /config /app/config` so `config/...` paths in `start_bot.sh` land in `/config` (the `/app` tree is read-only at runtime, but the symlink is created at build time, so it is fine).
   - License: `/usr/share/licenses/rss-to-telegram/LICENSE` (from the tag's LICENSE file; see section 1 conflict).
6. Permissions: `chown -R apps:apps /app && chmod -R 755 /app` at build time, so `/app` is owned by `apps` but not writable at runtime through the read-only rootfs; `/config` is the only writable path.
7. Tail:
   ```dockerfile
   ENV HOME=/config TZ=Etc/UTC
   USER apps
   COPY --chmod=0755 . /
   VOLUME /config
   WORKDIR /app
   ```
   No `EXPOSE` (no ports). Upstream `ENTRYPOINT ["./start_bot.sh"]` is replaced by `start.sh` at `/`, via `CMD ["/start.sh"]` (or keep `ENTRYPOINT ["/start.sh"]`; decide once and match sibling apps).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rss-to-telegram"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=BoKKeR/RSS-to-Telegram-Bot versioning=semver
  default = "2.0.9"
}

variable "LICENSE" {
  default = "GPL-3.0"  // UNVERIFIED: repo says GPL-3.0, package.json says MIT; confirm from LICENSE at tag 2.0.9
}

variable "SOURCE" {
  default = "https://github.com/BoKKeR/RSS-to-Telegram-Bot"
}
```

Then the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Do not leave the `LICENSE` comment in the final file; set the verified value. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/BoKKeR/RSS-to-Telegram-Bot"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: TOKEN
    default: ""
    required: true
  - name: CHATID
    default: ""
    required: true
  - name: DEBUG
    default: "false"
    required: false
  - name: REDIS_HOST
    default: "valkey"
    required: true
  - name: REDIS_PORT
    default: "6379"
    required: false
  - name: REDIS_USER
    default: "default"
    required: false
  - name: REDIS_PASSWORD
    default: ""
    required: false
  - name: REDIS_MUTEX
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - valkey
```

Notes:
- `TOKEN` and `CHATID` are required with no safe default. The rule "required: true env vars MUST either have a non-empty default or be handled by start.sh": `start.sh` must exit with a clear message when they are empty (see section 7), so the empty default is handled there. Record this in the PR.
- `REDIS_HOST` default `valkey` is the ContainerForge sibling name, not the upstream default (`127.0.0.1`). Confirm the valkey app's service name when wiring the test (UNVERIFIED: naming convention for sibling hostnames).
- `REDIS_MUTEX` is a random value in the upstream example. Default empty; `start.sh` generates one into `/config` only if the app needs it (UNVERIFIED: whether the app requires it).
- `DEBUG` default is `false` (upstream example uses `true`; choose `false` for production).
- `dependencies: valkey` is a hard dependency (the bot fails without Redis queueing; not proven by a run, UNVERIFIED for startup without Redis).

## 7. start.sh

Requirements:
- Refuse to start without `TOKEN` and `CHATID`, with a clear message. Do not write the token to disk or print it.
- Migrate the DB on first start only. Upstream `start_bot.sh` does legacy migration and `prisma migrate`; keep that, under `/config`.
- Never write to `/app`: `/app/config` is a symlink to `/config`.
- `exec` the bot.

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${TOKEN:-}" || -z "${CHATID:-}" ]]; then
  echo "ERROR: TOKEN and CHATID must be set" >&2
  exit 1
fi

mkdir -p /config
cd /app
# upstream start_bot.sh does legacy sqlite migration and `prisma migrate`; reuse it as-is
exec ./start_bot.sh
```

- Decision: either run upstream `start_bot.sh` after the guard (the simplest, same path as upstream), or inline its steps. Prefer reusing upstream `start_bot.sh` copied into the image, and keep the guard in front of it. Check the script's `exec` behaviour (UNVERIFIED whether it `exec`s the bot; if not, add `exec` so signals reach node).
- Do not put the token into `/config` or the process list beyond what the app needs.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external valkey (Redis) and a Telegram token; full functional test not feasible in single-container suite
filePaths:
- path: /app/dist/main.js
- path: /config
```

- No `tcp` or `http` probes: `ports: []` in `settings.yaml`, so there is nothing to probe.
- The test runs with no env. With no `TOKEN`/`CHATID`, the guard exits 1, so a plain start in the test would fail. Handle it: either (a) assert the guard's failure as the expected behaviour (a process-exit check), or (b) run the test with the test harness's env if forgetool supports it (UNVERIFIED). Do not weaken: treat the guard path as the real code path to test, and record the narrowed behaviour in a comment.
- Confirm the `filePaths` schema key and file path (UNVERIFIED against forgetool schema, which was not fetched).
- Database-dependency exception: applies (hard dependency on valkey, does not start without it, and a sidecar in `container-test.yaml` is not feasible with the available primitives). Add the required comment above. Protocol step 3 is mandatory: run with a `valkey` sidecar manually.
- `timeoutSeconds`: start with 60 (Node app, no ports), tune after the first run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Upstream path | ContainerForge path |
| --- | --- | --- |
| SQLite DB (Prisma) | `config/rss_bot_database.db` relative to `/app` | `/app/config` symlink to `/config` (build time) |
| Legacy migration backup | `config/backup_python_rss.db` | `/config/backup_python_rss.db` (via the symlink) |
| npm caches | `~/.npm` | `/tmp/npm` (`npm_config_cache`) |
| Prisma engine files | `node_modules` (inside `/app`, read-only at runtime) | Generated at build time; runtime must not need to write them (UNVERIFIED; test under `--read-only`) |

Security expectations (from draft, reconciled):
- non-root: upstream `runAsUser 0` (chart). Ours uses `USER apps`.
- read-only rootfs: `/app` read-only at runtime, writes only to `/config` and `/tmp`. The protocol run (`--read-only --tmpfs /tmp`) is the check.
- privileged: not required.
- persistence: `/config` only.

## 10. Risks, caveats and open questions

- **Node 16 to Node 26 jump.** Upstream pins Node 16.14.2 (`.nvmrc`), and Prisma 3 and Nest 8 are old. Build may fail on Node 26. This is the main risk. If it fails, the fallback is a Node 16/18-compatible sibling (none exists in this repo; UNVERIFIED which node sibling is available). Record the decision in the PR.
- **Redis is required, not optional.** The draft said no dependency. Corrected in section 1 and section 6. The valkey app is the sibling.
- **Telegram token and chat ID** are external credentials. The bot cannot deliver a feed without them. Not testable in CI; the guard test covers the missing-token path only.
- **Prisma CLI availability.** `start_bot.sh` runs `./node_modules/.bin/prisma migrate`. If `prisma` is only in devDependencies and the image uses `npm ci --omit=dev`, the migration fails at runtime. UNVERIFIED: check `package.json` devDependencies. The Dockerfile in section 4 installs all deps for the build (step 3) and must keep `prisma` in the final `node_modules`.
- **License conflict**: GPL-3.0 (GitHub) vs MIT (`package.json`). Resolve before PR (section 1).
- **arm64**: no binary; source build with `npm ci`. Native modules (bcrypt-like deps) may need build tools (UNVERIFIED).
- **Upstream stale**: release 2024-02, repo pushed 2024-06. State in the PR.
- Draft corrections: dependency (Redis) and `amd64`/`arm64` = `compile`, and the Node version (16, not 26).
- Unverified: Prisma datasource URL, `start_bot.sh` `exec`, `REDIS_MUTEX` requirement, the sibling hostname for valkey, forgetool `filePaths` schema support, license at tag.

## 11. Build and test steps

From `apps/rss-to-telegram/`:

1. Pre-check base: `docker run --rm <base-image> node --version`. Record the result.
2. `docker buildx bake --print`: must exit 0.
3. Build: `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
4. Run the guard path (no token) with an empty `/config`:
   ```sh
   docker volume rm rss-to-telegram-probe-config 2>/dev/null || true
   docker run --rm --name rss-to-telegram-probe --read-only --tmpfs /tmp \
     -v rss-to-telegram-probe-config:/config rss-to-telegram:2.0.9
   ```
   Expected: exits 1 with `ERROR: TOKEN and CHATID must be set`.
5. Run the full path with a valkey sidecar and fake values (the token is a fake; no Telegram call succeeds, so the bot should fail at the Telegram step, not at start-up):
   ```sh
   docker network create rss-probe-net
   docker run -d --name rss-probe-valkey --network rss-probe-net valkey:<version>
   docker run --rm -d --name rss-to-telegram-probe --network rss-probe-net --read-only --tmpfs /tmp \
     -e TOKEN=0:fake -e CHATID=-1 -e REDIS_HOST=rss-probe-valkey \
     -v rss-to-telegram-probe-config:/config rss-to-telegram:2.0.9
   docker logs -f rss-to-telegram-probe
   ```
   Expected readiness signal: a line showing the Prisma migration succeeded and the bot started its Redis connection (exact text UNVERIFIED until the first run). A Telegram auth error is expected with a fake token; a crash on start-up is not.
6. Test: `forgetool containers test --image rss-to-telegram:2.0.9 --config ./apps/rss-to-telegram/container-test.yaml`.
7. Cleanup: `docker rm -f rss-to-telegram-probe rss-probe-valkey; docker network rm rss-probe-net; docker volume rm rss-to-telegram-probe-config`.
8. arm64: only after amd64 is green.

## 12. PR checklist

- Branch: `feat/add-rss-to-telegram`.
- Commit: `feat(rss-to-telegram): add new container`.
- PR title: `feat(rss-to-telegram): add new container`.
- PR description: `.github/PULL_REQUEST_TEMPLATE.md` sections and checkboxes; only check what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- Say what was not tested: the full Telegram delivery (fake token), arm64 build, Node 26 compatibility if the build fails, and any UNVERIFIED item above.
- Downstream: none (not a `FROM` base), so no `DOWNSTREAM_CHANGES.md`.
