# wdosg — implementation plan
> Source: ./draft.md · Target: apps/wdosg/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/SoulRaven80/wdosg (Node/Express server for DOS games via js-dos) |
| Latest stable | `v1.3.9` (tags sorted: v1.3.6 to v1.3.9; Docker Hub tags `latest`, v1.3.9, v1.3.8 ...) |
| Renovate | `datasource=github-tags depName=SoulRaven80/wdosg versioning=semver` (tags carry a `v` prefix) |
| License | GPL-3.0. The `LICENSE` file is the GNU GPL version 3 text. UNVERIFIED whether "only" or "or later" (no source header read); `package.json` says `ISC`, which conflicts, so the `LICENSE` file is taken as authoritative and the PR should note the conflict. Use `GPL-3.0-only` |
| Source | `https://github.com/SoulRaven80/wdosg/archive/refs/tags/v1.3.9.tar.gz` (same for both arches; JS only, plus the native `sqlite3` dependency) |
| Checksum source | None published (no release assets). The pinned tag is the integrity anchor. Tag `v1.3.9` points to `5cc2cc88b08b722d63e68df8a061b47f7c2d22a4` |
| Upstream Dockerfile | Reviewed (identical at `db267e9`, `v1.3.9` and master): `FROM node:23-alpine3.19`, `WORKDIR /app`, `COPY . .`, `RUN npm install`, `EXPOSE 3001`, `CMD ["node","index"]` |
| Draft correction | The draft guesses port 3000. The real default is `3001` (`process.env.PORT \|\| 3001` in `index.js`, `EXPOSE 3001`, README compose example) |
| Repo content at v1.3.9 | `index.js`, `config.js`, `package.json`, `package-lock.json`, `backend/`, `public/`, `bundle_template/` (referenced by `config.js`), `.env` (sample values, no dotenv dependency, so it is unused at runtime), `eslint.config.js`, `Dockerfile`, `LICENSE`, `README.md` |
| Env vars (README plus code) | `TWITCH_CLIENT_ID`, `TWITCH_CLIENT_SECRET` (IGDB metadata; `DISABLED` turns it off), `LOG_LEVEL` (`info`), `TOKEN_SECRET` (default `secret`, a weak fallback), `GAMES_LIBRARY` (default `<app dir>/wdosglibrary`), `DB_PATH` (default `<app dir>/database`), `EMAIL_SERVICE`, `EMAIL_USER`, `EMAIL_PASS`, `SERVER_FRIENDLY_URL`, `PORT`. Docker-secret variants read as files: `TWITCH_CLIENT_ID_FILE`, `TWITCH_CLIENT_SECRET_FILE`, `TOKEN_SECRET_FILE`, `EMAIL_PASS_FILE` |
| Startup behavior | At v1.3.9, `index.js` calls `process.exit(1)` when `TWITCH_CLIENT_ID` or `TWITCH_CLIENT_SECRET` is empty. On master the same check only logs a warning and sets the ID to `DISABLED`. The release is therefore a crash without env, which matters for the empty-env container test |
| Temp dir | `./tmp/` relative to the cwd (file upload temp dir, cleared at start) |
| Readiness log | `Application ready. Server listening on port <port>` (pino-pretty output) |
| Dependencies | `sqlite3@^5.1.7` (native module: prebuilt download or node-gyp compile), `express@^4.21.1`, `pino@^9.5.0`, `pino-pretty@^13.0.0`, `nodemailer@^6.9.16`, `adm-zip@^0.5.16`, `image-downloader@^4.3.0`, others; dev deps are jest/eslint (not needed) |

## 2. Target layout

```
apps/wdosg/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` or `etc/`: the app creates its own database and library directories. `root/` is not used. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: Node app, and the draft names `python-node`. It supplies `node`, `npm` and a Python for `node-gyp`. Closest siblings: `apps/thelounge` and `apps/budge` (npm install into `/app`, state in `/config`). UNVERIFIED: the Node major in the base; `sqlite3@5` needs a supported Node (upstream uses Node 23), so check `node -v` in the first build and adjust only if it fails.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (not used for URLs because the source is arch-independent).
2. `USER root`.
3. `ENV HOME=/config NODE_ENV=production NPM_CONFIG_CACHE=/tmp/npm-cache NPM_CONFIG_UPDATE_NOTIFIER=false`.
4. One `RUN` (the pattern is `apps/budge/Dockerfile`):
   - apt build tools only as a fallback for `sqlite3` when no prebuilt binary matches: `apt-get update && apt-get install -y --no-install-recommends build-essential python3` (python3 is in the base; list it anyway only if missing). Purge `build-essential` at the end, as budge does.
   - `mkdir -p /app/wdosg /usr/share/licenses/wdosg`
   - `(curl -fsSL -o /tmp/wdosg.tar.gz "https://github.com/SoulRaven80/wdosg/archive/refs/tags/v${VERSION#v}.tar.gz")` then `tar xzf /tmp/wdosg.tar.gz -C /app/wdosg --strip-components=1`
   - `cd /app/wdosg && npm ci --omit=dev --no-audit --no-fund` (a `package-lock.json` exists at v1.3.9; if `npm ci` fails on a lockfile mismatch, fall back to `npm install --omit=dev`)
   - `cp LICENSE /usr/share/licenses/wdosg/LICENSE`
   - `chown -R apps:apps /app && chmod -R u=rwX,go=rX /app`
   - `npm cache clean --force`, `apt-get purge -y --auto-remove build-essential`, `apt-get clean`, `rm -rf /tmp/* /var/lib/apt/lists/*`
5. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 3001`; `VOLUME /config`; `WORKDIR /config`.
6. Do not add `ENV GAMES_LIBRARY`/`DB_PATH` in the Dockerfile; start.sh defaults them (keeps defaults in one place).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "wdosg" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=SoulRaven80/wdosg versioning=semver
  default = "1.3.9"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/SoulRaven80/wdosg" }
```

Standard targets as in `apps/adguardhome-sync/docker-bake.hcl` (`docker-metadata-action`, `image`, `image-local`, `image-all` for amd64 and arm64, `group "default"`). Run `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/SoulRaven80/wdosg"`.
- `ports`: `3001` / `tcp` / `required: false`.
- `env` (defaults equal start.sh):
  - `TZ` / `Etc/UTC`
  - `PORT` / `3001`
  - `LOG_LEVEL` / `info`
  - `TWITCH_CLIENT_ID` / `DISABLED`
  - `TWITCH_CLIENT_SECRET` / `DISABLED`
  - `TOKEN_SECRET` / `""` (start.sh generates and persists one when empty; upstream's own fallback `secret` is weak)
  - `GAMES_LIBRARY` / `/config/wdosglibrary`
  - `DB_PATH` / `/config/database`
  - `EMAIL_SERVICE`, `EMAIL_USER`, `EMAIL_PASS`, `SERVER_FRIENDLY_URL` / `""`
  - the `*_FILE` secret variants as optional empty entries (`TWITCH_CLIENT_ID_FILE`, `TWITCH_CLIENT_SECRET_FILE`, `TOKEN_SECRET_FILE`, `EMAIL_PASS_FILE`)
  - all `required: false`.
- `volumes`: `/config` / required true (database and game library both live there).
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
export PORT="${PORT:-3001}"
export GAMES_LIBRARY="${GAMES_LIBRARY:-/config/wdosglibrary}"
export DB_PATH="${DB_PATH:-/config/database}"
mkdir -p "$GAMES_LIBRARY" "$DB_PATH" /tmp/tmp

# v1.3.9 exits when IGDB credentials are empty; DISABLED turns IGDB off (README)
if [ -z "${TWITCH_CLIENT_ID:-}" ] && [ -z "${TWITCH_CLIENT_ID_FILE:-}" ]; then export TWITCH_CLIENT_ID=DISABLED; fi
if [ -z "${TWITCH_CLIENT_SECRET:-}" ] && [ -z "${TWITCH_CLIENT_SECRET_FILE:-}" ]; then export TWITCH_CLIENT_SECRET=DISABLED; fi

# stable session secret, generated once and never overwritten
if [ -z "${TOKEN_SECRET:-}" ] && [ -z "${TOKEN_SECRET_FILE:-}" ]; then
  [ -s /config/.token_secret ] || (umask 077; head -c 48 /dev/urandom | base64 | tr -d '\n=/+' > /config/.token_secret)
  TOKEN_SECRET="$(cat /config/.token_secret)"; export TOKEN_SECRET
fi

cd /tmp   # the app writes ./tmp/ relative to cwd, so uploads land in /tmp/tmp
exec node /app/wdosg/index.js
```

- Idempotent, writes only to `/config` and `/tmp`, never `/app`.
- `index.js` has no listen host argument, so `app.listen(port)` binds all interfaces (Node default `::`), which satisfies the "listen on all interfaces" rule; confirm from outside the container in the manual run.
- `cd /tmp` with `node /app/wdosg/index.js`: `config.js` resolves static `public/` and `bundle_template/` from the script's own directory (`import.meta.url`), not the cwd, so running from `/tmp` is safe (UNVERIFIED for every router; if a startup error mentions a relative path, set `WORKDIR` accordingly).
- `exec node` is the final long-running process.
- Secrets stay out of the process list and files except the generated session secret (mode 0600).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3001'
filePaths:
- /app/wdosg/index.js
- /app/wdosg/node_modules/sqlite3
```

No `http` probe: unauthenticated requests are redirected or rejected by `verifyToken`, and the exact status of `/` was not confirmed. The test runs without env, which only works because start.sh defaults the IGDB variables to `DISABLED`. The email, `*_FILE` and TOKEN_SECRET-generation paths are not covered by the test and must be run by hand (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/database` (default `DB_PATH`, SQLite) | `DB_PATH=/config/database` |
| `/app/wdosglibrary` (default `GAMES_LIBRARY`, games, metadata, attachments, saves) | `GAMES_LIBRARY=/config/wdosglibrary` |
| `./tmp/` relative to cwd (upload temp; wiped at startup) | cwd `/tmp`, so it is `/tmp/tmp`; the tmpfs is ephemeral by design |
| npm cache | `NPM_CONFIG_CACHE=/tmp/npm-cache` |
| Session secret in env only | Generated once into `/config/.token_secret` |
| Chart: UID 568, read-only rootfs, PVCs at `/app/database` and `/app/wdosglibrary` | Both PVC paths collapse into the single `/config` volume. Anyone migrating must mount data at `/config/database` and `/config/wdosglibrary` (or set the env vars) |

UNVERIFIED: any other path the app might write under its own directory (for example generated game pages under `public/`). The README says each game is "deployed into a separate directory", which is the library path; the first read-only run will reveal a violation as an `EROFS` error.

## 10. Risks, caveats and open questions

- The build downloads a tag tarball and runs `npm ci`; it needs network access and is only as reproducible as the lockfile.
- `sqlite3` is native: arm64 and amd64 both need either a matching prebuilt (downloaded from GitHub during install) or a `node-gyp` compile. Test both arches; the compile fallback is why `build-essential` is in the plan.
- v1.3.9 exits without IGDB variables, but master does not. start.sh papers over this for v1.3.9; once a newer release adopts master's behavior, the defaults become harmless.
- `TOKEN_SECRET` upstream default is `secret`; the generated value fixes that for the container, but anyone setting it by env must keep it stable.
- wDOSg is not meant for the open internet (README caution), and registration is local; document that.
- License mismatch: `LICENSE` (GPLv3) against `package.json` (`ISC`). Confirm with upstream or the maintainers.
- Docker image upstream is Alpine (musl); `sqlite3` prebuilts for glibc exist, so this is a plus.
- The `.env` file in the repo is a sample and is not loaded.
- Draft listed port 3000 as inferred; corrected to 3001.

## 11. Build and test steps

```sh
cd apps/wdosg
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create wdosg-probe-config
docker run --rm -d --name wdosg-probe --read-only --tmpfs /tmp \
  -v wdosg-probe-config:/config wdosg:1.3.9
docker logs -f wdosg-probe     # expect: Application ready. Server listening on port 3001
docker exec wdosg-probe curl -sSI http://127.0.0.1:3001/
forgetool containers test --image wdosg:1.3.9 --config ./apps/wdosg/container-test.yaml
docker rm -f wdosg-probe; docker volume rm wdosg-probe-config
```

Manual extra runs: restart with the same volume and check that `/config/.token_secret` and the database persist; run once with `-e TOKEN_SECRET=x -e TWITCH_CLIENT_ID=DISABLED` to check the env path; upload a small js-dos bundle through the UI (or API) to confirm the library write lands in `/config/wdosglibrary` with no `EROFS` error. Repeat the build for `linux/arm64` if possible.

## 12. PR checklist

- Branch `feat/add-wdosg`; commit and PR title `feat(wdosg): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` fully; tick only what applies.
- `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; `license/cla` shows the status.
- State untested items: arm64 build, the native module fallback, game upload and library write path, email sending, IGDB with real credentials.
- Pre-completion: bake print, build, empty-`/config` read-only run, forgetool test, no weakened assertions, cleanup done.
