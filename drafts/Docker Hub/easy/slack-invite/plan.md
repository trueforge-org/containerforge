# slack-invite — implementation plan
> Source: ./draft.md · Target: apps/slack-invite/ · Difficulty: easy to build, but functionally doubtful (see section 10) · Role: main · Verified on 2026-11-23 (re-checked 2026-11-24)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Upstream `ninthwalker/slack-invite` has **no releases or tags**. Latest and only relevant commit: `5f3a5f26499974c94e83f2b6f4c5db843f3e278b` (2017-03-10). `package.json` says `slack-invite-automation` `0.1.0`. The draft tag `latest` maps to this commit. |
| Renovate | `datasource=git-refs depName=https://github.com/ninthwalker/slack-invite currentValue=master versioning=loose`, `VERSION` = full commit SHA. Copy the exact annotation form from an existing `apps/*/docker-bake.hcl` using `datasource=git-refs` (UNVERIFIED which form Renovate honours for SHA defaults). With a 2017 head the value will never change. |
| License | **UNVERIFIED.** The fork has no `LICENSE` file (raw `/master/LICENSE` returns 404) and `package.json` has no `license` field. The original `outsideris/slack-invite-automation` (now archived) is MIT. Use `MIT` in the bake file, with a PR note, or reject the app if the owner will not accept an unlicensed fork. |
| Source URL | https://github.com/ninthwalker/slack-invite (the draft's `httpss://` link is a typo) |
| Download | `https://github.com/ninthwalker/slack-invite/archive/${VERSION}.tar.gz` (source tarball by commit) |
| Checksum | None published; commit SHA pins the content. |
| Upstream Dockerfile | https://github.com/ninthwalker/slack-invite/blob/master/Dockerfile reviewed: `FROM node:onbuild`, `EXPOSE 7879`, `COPY . /slack-invite`, `RUN npm install`, `CMD ./bin/www`. |
| Dependencies (package.json) | body-parser, cookie-parser, debug, dotenv ^2, express ^4.13, i18n ^0.7, jade ^1.11, morgan, request, serve-favicon. Start: `node ./bin/www`. |
| Env vars (config.js, README) | `COMMUNITY_NAME` (default `YOUR-TEAM-NAME`), `SLACK_URL` (default `YOUR-TEAM.slack.com`), `SLACK_TOKEN` (default `YOUR-ACCESS-TOKEN`), `INVITE_TOKEN` (optional, default none), `LOCALE` (default `en`; de, en, es, fr, ja, ko, pl, pt, pt-BR, tr, zh-CN, zh-TW), plus `PORT` (`bin/www`, default `7879`) |
| Port | **7879/http** (Dockerfile, `bin/www`). The draft's `3000` is wrong (inferred). `server.listen(port)` with no host, so it binds all interfaces. |
| State | None persisted. `i18n.configure({directory: __dirname + '/locales', autoReload: true})` can write missing keys to `locales/` (see section 9). |
| API used | `POST https://<SLACK_URL>/api/users.admin.invite` with legacy token. |

## 2. Target layout

```
apps/slack-invite/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: this is the repo's only Node-capable base (the draft names it). Check `node --version` and `npm --version` in it, since old deps (jade 1.x, i18n 0.7) may not like Node 24 (UNVERIFIED). Closest sibling: `apps/budge` (python-node, source tarball into `/app/www/public`, `npm install`, start.sh with `exec`). The python part is unused; accept it as the cost of reusing the only Node base, or ask the maintainers whether a plain node base is wanted.

## 4. Dockerfile

1. `FROM` above, `ARG VERSION` (commit SHA), `ARG TARGETARCH` not needed (pure JS; no native deps in package.json).
2. `USER root`, then one RUN:
   ```sh
   mkdir -p /app/slack-invite /usr/share/licenses/slack-invite
   curl -fsSL "https://github.com/ninthwalker/slack-invite/archive/${VERSION}.tar.gz" | tar xz -C /app/slack-invite --strip-components=1
   cd /app/slack-invite
   # stop i18n from writing missing keys into the read-only app dir
   sed -i "s#autoReload: true#autoReload: false,\n    updateFiles: false#" app.js
   npm install --omit=dev --no-audit --no-fund --cache /tmp/npm-cache
   rm -rf /tmp/npm-cache /tmp/* /root/.npm
   chown -R root:root /app && chmod -R 755 /app
   ```
   Verify the `sed` result with `grep -n updateFiles app.js` in the same RUN (`grep -q`) so the build fails if upstream changes. Also write a short `/usr/share/licenses/slack-invite/NOTICE` only if a LICENSE exists in the tarball (it does not at this commit; do not invent one).
3. `ENV NODE_ENV=production HOME=/config npm_config_cache=/tmp/npm-cache`.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 7879`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP = "slack-invite"`
- `VERSION` with the git-refs renovate comment, default `"5f3a5f26499974c94e83f2b6f4c5db843f3e278b"`; Dockerfile `ARG VERSION` consumes it.
- `LICENSE = "MIT"` (see section 1: UNVERIFIED for this fork; resolve before merge)
- `SOURCE = "https://github.com/ninthwalker/slack-invite/"`
- Standard targets: `docker-metadata-action`, `image` (args.VERSION, OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64 and linux/arm64), `group "default" { targets = ["image-local"] }`.
- Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ninthwalker/slack-invite/"
ports:
  - port: 7879
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "7879"
    required: false
  - name: COMMUNITY_NAME
    default: "YOUR-TEAM-NAME"
    required: false
  - name: SLACK_URL
    default: "YOUR-TEAM.slack.com"
    required: false
  - name: SLACK_TOKEN
    default: "YOUR-ACCESS-TOKEN"
    required: false
  - name: INVITE_TOKEN
    default: ""
    required: false
  - name: LOCALE
    default: "en"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
dependencies: []
```
Defaults equal the upstream `config.js` fallbacks, so the image starts with no env. The `/config` volume holds nothing the app persists; list it only because the repo convention declares it (set `required: false`). `SLACK_TOKEN` is a secret: pass it as env or a secret, never print it.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
export PORT="${PORT:-7879}"
export NODE_ENV=production
cd /app/slack-invite
exec node ./bin/www
```
Idempotent, no `/config` seeding needed, writes nothing to `/app`. The server binds all interfaces by default. `exec node` (not `npm start`) so signals reach node. Do not echo `SLACK_TOKEN`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '7879'
  path: /
tcp:
- port: '7879'
filePaths:
- /app/slack-invite/bin/www
- /app/slack-invite/node_modules/express
```
The index page renders from the defaults, so no env is needed. Set `timeoutSeconds` like `apps/budge` if it is set there; node start is fast. The code path that calls Slack (`POST /invite`) cannot be tested without a token, so it is outside the automated tests; test it manually (section 11).

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `i18n` `updateFiles` (default true) may rewrite `locales/*.json` when a key is missing. Disabled at build time (`updateFiles: false`, `autoReload: false`).
- `npm install` runs at build time only; the npm cache is in `/tmp` and removed. At runtime nothing writes to `/app`.
- `HOME=/config` so any dotfile goes to the persistent volume; the app uses none.
- Draft: chart runs as UID 0 with `readOnlyRootFilesystem false`; neither is required here (high port, no state). Runs as `apps` (568) on a read-only rootfs with `/tmp` tmpfs.
- Express `morgan` logs to stdout; no log files.

## 10. Risks, caveats and open questions

- **Likely non-functional against current Slack.** The app calls `users.admin.invite`, an undocumented endpoint that Slack retired for legacy tokens (UNVERIFIED current status; check Slack's changelog). Invite creation probably fails with an error such as `invalid_auth`/`method_deprecated`. The container will still start and render the page.
- The project is dead: last commit 2017-03-10, original (`outsideris/slack-invite-automation`) is archived. Dependencies are very old (jade 1.11, request, i18n 0.7, express 4.13 range) with known CVEs; `npm install` gives whatever semver allows.
- No license file in the fork (section 1).
- The draft's malformed link and port `3000` are corrected (7879).
- Draft caveat about the Slack token: it is required for real use; `INVITE_TOKEN` gives minimal protection against abuse. There is no rate limit.
- Build only needs the network; arm64 has no native modules, so no arm64 blocker.
- Open question for maintainers: ship at all, or skip the image because it cannot work against Slack's current API.

## 11. Build and test steps

```sh
cd apps/slack-invite
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create slack-invite-probe-config
docker run --rm -d --name slack-invite-probe --read-only --tmpfs /tmp \
  -v slack-invite-probe-config:/config slack-invite:5f3a5f26499974c94e83f2b6f4c5db843f3e278b
docker logs -f slack-invite-probe
forgetool containers test --image slack-invite:<VERSION> --config ./apps/slack-invite/container-test.yaml
docker rm -f slack-invite-probe; docker volume rm slack-invite-probe-config
```
Readiness signal: process stays up and port 7879 answers `GET /` with 200 (node prints nothing on start unless `DEBUG=*`; `bin/www` logs `Listening on port 7879` only with `DEBUG=slack-invite-automation:server`, UNVERIFIED). Manual check: `curl -s localhost:7879/ | grep -i community`, then a `POST /invite` with a fake token and confirm it reports `Failed!` and does not crash or write to `/app`.

## 12. PR checklist

- Branch `feat/add-slack-invite`, commit and PR title `feat(slack-invite): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State honestly what is untested: actual Slack invites, Node compatibility of 2017 dependencies, arm64 build, license of the fork, renovate behaviour on a SHA.
- Do not tick "Built container locally" unless it was built.
