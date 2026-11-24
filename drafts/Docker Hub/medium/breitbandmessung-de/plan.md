# breitbandmessung-de — implementation plan
> Source: ./draft.md · Target: apps/breitbandmessung-de/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No tags or releases exist. Latest commit on `master`: `4cd4038a826b01ff433534f36f6a130fb7ac9635` (2023-11-11). `package.json` says 1.2.0. The draft's image tag is `latest`. This plan pins the commit SHA as `VERSION` (full SHA). Upstream is unmaintained since 2023-11. |
| Renovate | `datasource=git-refs`, `depName=https://github.com/shneezin/breitbandmessung-node`, `versioning=loose` (tracks `master`). UNVERIFIED: renovate's git-refs datasource needs `currentValue=master`; if the annotation cannot track a bare SHA, drop renovate for this app and document it in the bake file. |
| License | `package.json`: `"license": "MIT"`. No LICENSE file in the repo; README says "Feel free to use and improve the script". Use `MIT` and ship a note. |
| Source | https://github.com/shneezin/breitbandmessung-node |
| Download | https://github.com/shneezin/breitbandmessung-node/archive/4cd4038a826b01ff433534f36f6a130fb7ac9635.tar.gz (source; no binary) |
| Checksum | None published. UNVERIFIED. `yarn.lock` pins JS dependencies. |
| What it is | **Not a web app.** A Puppeteer script (`index.js`) that opens https://breitbandmessung.de/test, runs the measurement, downloads the CSV into `EXPORT_PATH` and exits. `entrypoint.sh` optionally runs it via cron (`crond`) according to `config/config.cfg`. There is **no port**; the draft's `3000/http (inferred)` is wrong. |
| Config | `config/config.cfg` (keys `timezone`, `crontab`, `crontab2`, `run_once`, `run_on_startup`), fallback `config.cfg.defaults`: `timezone=UTC`, `crontab=0 */2 * * *`, `run_once=true`, `run_on_startup=true` |
| Env read by `index.js` | `START_HEADLESS` (default `true`), `EXPORT_PATH` (default `/export/`). Launch args are hard-coded `--no-sandbox --disable-setuid-sandbox`. |
| Upstream Dockerfile | reviewed (commit 4cd4038): `node:16.16.0-alpine` + apk chromium/ttf-freefont/nss/tini, `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1`, `PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser`, puppeteer `^19.3.0` (installed in `/` and again in `/usr/src/app`), `/export` dir. `Dockerfile.debian` uses `node:16.16.0-bullseye-slim` with `install-packages.sh`. |

## 2. Target layout

```
apps/breitbandmessung-de/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.cfg       # seeded copy of upstream config.cfg.defaults
```
`defaults/` is on the `.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: Node runtime for the script (the repo has no node-only base). The draft's alternative, plain ubuntu plus apt chromium, does not work: on Ubuntu the apt `chromium-browser`/`chromium` packages are snap stubs that cannot run in a container (well-known Ubuntu behaviour; not re-verified for 26.04). Closest sibling: `apps/changedetection` (python-node plus a Playwright browser dependency) and `apps/budge`.

## 4. Dockerfile

1. `ARG VERSION` (full commit SHA), `ARG TARGETARCH`, `USER root`.
2. `# renovate: datasource=github-releases depName=aptible/supercronic` `ARG SUPERCRONIC_VERSION=0.2.51` (latest v0.2.51, MIT, per-arch assets `supercronic-linux-amd64` / `supercronic-linux-arm64`); `# renovate: datasource=npm depName=playwright` `ARG PLAYWRIGHT_VERSION=1.65.1` (latest release v1.65.1).
3. `ENV PLAYWRIGHT_BROWSERS_PATH=/app/browsers PUPPETEER_SKIP_DOWNLOAD=1`.
4. One `RUN`:
   - Fetch the script source: `mkdir -p /app && curl -fsSL "https://github.com/shneezin/breitbandmessung-node/archive/${VERSION}.tar.gz" | tar xz -C /app --strip-components=1`.
   - Install JS deps with the upstream lockfile: `cd /app && PUPPETEER_SKIP_DOWNLOAD=1 yarn install --frozen-lockfile --production` (keeps the `puppeteer ^19.3.0` package that `index.js` requires; yarn cache redirected to `/tmp` with `YARN_CACHE_FOLDER=/tmp/.yarn`; whether `yarn` is present in the base is UNVERIFIED, otherwise `npm install -g yarn`).
   - Browser: `npx --yes playwright@${PLAYWRIGHT_VERSION} install --with-deps chromium` (installs Chromium plus its apt libraries into `/app/browsers`; works on amd64 and arm64). UNVERIFIED on Ubuntu 26.04 (Playwright officially lists older Ubuntu releases). Then `ln -s "$(find /app/browsers -type f -name chrome -path '*chrome-linux*' | head -n1)" /usr/local/bin/chromium` and set `ENV PUPPETEER_EXECUTABLE_PATH=/usr/local/bin/chromium`.
   - Supercronic: `curl -fsSL -o /usr/local/bin/supercronic "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}"`, verify with the per-arch SHA1 printed in the release notes (`sha1sum -c`), `chmod 755`. Checksum values must be copied from the release page at implementation time; amd64 is `1692066e350a88ff4d7d6474fe3c7a6c41ec5e89`, and the arm64 hash is one of the other two values on that page (mapping UNVERIFIED).
   - License note: `mkdir -p /usr/share/licenses/breitbandmessung-de` and write a NOTICE (MIT per `package.json`; supercronic MIT; Chromium notices from the Playwright install).
   - `rm -rf /tmp/* /var/lib/apt/lists/*`; `chown -R apps:apps /app`.
5. `ENV HOME=/config EXPORT_PATH=/config/export` (tmp and Chromium profile go to `/tmp`; keep the cache out of `/config`).
6. `USER apps`
7. `COPY --chmod=0755 . /`
8. `VOLUME /config`; no `EXPOSE` (no port).
9. `WORKDIR /app`.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "breitbandmessung-de" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/shneezin/breitbandmessung-node versioning=loose
  default = "4cd4038a826b01ff433534f36f6a130fb7ac9635"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/shneezin/breitbandmessung-node" }
```
Standard 4 targets + default group (copy from `apps/adguardhome-sync`), `image-all` amd64 and arm64. Validate with `docker buildx bake --print`. Because the tag is a 40-char SHA, consider shortening to 12 chars in the image tag only if `docker-metadata-action` allows it (UNVERIFIED).

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/shneezin/breitbandmessung-node"`.
- ports: none (the container opens no port). Omit the `ports` block or leave it empty, matching how a sibling without ports does it (UNVERIFIED which form the forgetool schema prefers; check against a no-port sibling such as `apps/limnoria` pattern before implementation).
- env: `TZ` default `"Etc/UTC"` required false; `EXPORT_PATH` default `"/config/export"` required false (read by `index.js`); `START_HEADLESS` default `"true"` required false (read by `index.js`). Schedule options are not env vars but keys in `/config/config.cfg` (`crontab`, `run_once`, `run_on_startup`), documented here.
- volumes: `/config` required true (config.cfg and `export/` result CSVs).
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/export /tmp/run
[[ -s /config/config.cfg ]] || cp /defaults/config.cfg /config/config.cfg
get() { grep -E "^$1=" -m1 /config/config.cfg | cut -d= -f2-; }
RUN_ONCE="$(get run_once)"; RUN_ON_STARTUP="$(get run_on_startup)"; CRON="$(get crontab)"
export TZ="${TZ:-$(get timezone)}"
cd /app
if [[ "${RUN_ON_STARTUP}" == "true" ]]; then node /app/index.js || echo "measurement failed"; fi
[[ "${RUN_ONCE}" == "true" ]] && exit 0
echo "${CRON} node /app/index.js" > /tmp/run/crontab
exec supercronic /tmp/run/crontab
```
- Idempotent; `config.cfg` is seeded only when missing. The seeded `defaults/config.cfg` mirrors upstream (`timezone=UTC`, `crontab=0 */2 * * *`, `run_on_startup=true`) but sets **`run_once=false`** so the container stays running under a Deployment (deliberate deviation from upstream `true`; flagged in section 10).
- Replaces upstream's root-only `crond` and `/etc/localtime` symlink with `supercronic` and the `TZ` variable.
- No writes to `/app`; Chromium profile and downloads use `/tmp` (set `TMPDIR=/tmp`); results go to `$EXPORT_PATH`. Note: `index.js` also runs `chmod 777` on the export path, harmless.
- No network listener, so no bind-address concern. `exec supercronic` keeps signals working.

## 8. container-test.yaml

There is no port to probe (section 6 lists none), and the measurement needs the public internet, so the container itself is not started. Verify the install with runner output checks, following `apps/jbops` and `apps/limnoria`:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# No listener: the app is a scheduled Puppeteer script that needs the internet,
# so only verify the install. forgetool splits cmd on whitespace (no shell
# quoting), so commands are kept space-free.
timeoutSeconds: 180
runners:
- entrypoint: /usr/local/bin/chromium
  cmd: --version
  expectedOutput: Chrom
- entrypoint: /usr/local/bin/node
  cmd: -p require('/app/node_modules/puppeteer/package.json').name+'-ok'
  expectedOutput: puppeteer-ok
- entrypoint: /usr/local/bin/supercronic
  cmd: -version
  expectedOutput: v0.2

mainRunner:
  enabled: false
```
UNVERIFIED: the node binary path (`/usr/local/bin/node` vs `/usr/bin/node`) in `python-node` and the exact `chromium --version` and `supercronic -version` output formats; confirm at the build step and keep the assertions equally strong. Runs with no env vars.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/export` (CSV results, `error-screenshot.png`, chmod 777) | `/config/export` via `EXPORT_PATH` |
| `/usr/src/app/config/config.cfg` | `/config/config.cfg` |
| `/etc/localtime` symlink, `/root/project_env.sh`, `crontab` for root | dropped; `TZ` env and supercronic with a crontab in `/tmp/run` |
| Chromium user-data dir and crash dumps | default temp dir under `/tmp` |
| `/dev/shm` for Chromium | needs a bigger shm (`--shm-size`, or an `emptyDir` with `medium: Memory` on Kubernetes); `index.js` cannot pass `--disable-dev-shm-usage` without patching |

Draft expectations: chart ran UID 0, `readOnlyRootFilesystem: false`, persistence `/export`. Plan: UID 568, read-only rootfs, persistence `/config` (export in `/config/export`). Not privileged; Chromium runs with `--no-sandbox` as hard-coded upstream.

## 10. Risks, caveats and open questions

- Draft's port 3000 and "web UI" are wrong: there is no server, so there is no readiness port, only logs and exit status.
- Upstream is unmaintained (last commit 2023-11); the target page's CSS selectors in `index.js` will break when breitbandmessung.de changes its UI. Measurement requires the live site, so it cannot be tested in CI.
- Chromium source: Ubuntu's apt chromium is a snap stub, so this plan uses Playwright's Chromium. Playwright support for Ubuntu 26.04 and Puppeteer 19 compatibility with a modern Chromium build are both UNVERIFIED. Alternatives: bump `puppeteer` to a current release (needs `index.js` edits), or ship amd64 only.
- Puppeteer 19 downloads no browser on arm64 by itself; the Playwright route covers arm64 but that is UNVERIFIED too.
- `run_once=false` default differs from upstream; a Job-style use would set `run_once=true`.
- Version is a git SHA: renovate tracking and image tags are awkward.
- Licensing is only declared in `package.json`.

## 11. Build and test steps

```sh
cd apps/breitbandmessung-de
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name breitbandmessung-de-probe --read-only --tmpfs /tmp --shm-size=1g \
  -v breitbandmessung-de-probe-config:/config breitbandmessung-de:4cd4038a826b01ff433534f36f6a130fb7ac9635
docker logs -f breitbandmessung-de-probe
forgetool containers test --image breitbandmessung-de:4cd4038a826b01ff433534f36f6a130fb7ac9635 --config ./apps/breitbandmessung-de/container-test.yaml
docker rm -f breitbandmessung-de-probe; docker volume rm breitbandmessung-de-probe-config
```
Expected readiness: no listener, so the pass signal is the container still running with `supercronic` started (`level=info msg="starting"`), a first measurement attempt logged (or a clear network error when offline) and `/config/config.cfg` seeded. For a one-shot check, run with `run_once=true` in `/config/config.cfg` and confirm the CSV appears in `/config/export` on a machine with internet access.

## 12. PR checklist

- Branch `feat/add-breitbandmessung-de`; commit and PR title `feat(breitbandmessung-de): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; Notes contains `🤖 This PR is AI generated.` and records the corrections to the draft (no web port, SHA-pinned version).
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: Chromium launch under read-only rootfs, an actual speed measurement, arm64, renovate tracking of the git SHA.
- Check "Built container locally" only if it was built.
