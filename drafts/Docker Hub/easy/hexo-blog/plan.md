# hexo-blog — implementation plan
> Source: ./draft.md · Target: apps/hexo-blog/ · Difficulty: easy (draft says easy; medium in practice because of first-start network and a baked starter) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Tracked version | `hexo-cli` 4.3.2 (what the reference image `fletchto99/hexo-dev-blog` pins in its `package.json`). npm latest of `hexo-cli` is also 4.3.2 (checked on npm registry). |
| Hexo core | `hexo` 8.1.2 (GitHub release v8.1.2, npm latest). Needs Node >= 20.19.0. Comes from the blog's own `package.json` in `/config`, not from the image. |
| Other pieces | `hexo-server` 3.0.0 (npm latest). `hexo-starter` (git clone made by `hexo init`). |
| Renovate | `// renovate: datasource=npm depName=hexo-cli` (versioning default, semver) |
| License | MIT (`hexo`, `hexo-cli`, `hexo-server`: npm registry license field; `hexojs/hexo` LICENSE exists). SPDX `MIT`. |
| Source URL | https://github.com/hexojs/hexo (SOURCE; same as draft "Source repository") |
| Download | npm package, no per-arch binary. `npm install hexo-cli@4.3.2`. Pure JS, so amd64 and arm64 are the same. |
| Checksum | npm registry integrity (`package-lock.json` / npm's own sha512 integrity check). No separate checksum file. |
| Upstream Dockerfile reviewed | https://github.com/fletchto99/hexo-dev-docker (commit b92ba8c). `FROM node:26-bookworm-slim`, apt `rsync openssh-client tini`, `npm ci` of hexo-cli, `EXPOSE 8080`, `CMD /setup/run.sh`. |
| Upstream start logic (`setup/run.sh`) | Requires `/config`. If `/config` is empty runs `hexo init /config`. If `HEXO_PLUGINS` is set runs `npm install -C /config <plugin>@latest ...`. Then `hexo clean --cwd /config` and `exec hexo server --cwd /config -p 8080 --debug --draft`. |
| Real env vars | `HEXO_PLUGINS` (space separated list of npm plugin names). Nothing else is read by the reference image. |
| Port | **8080/http**. The draft says 4000 (inferred, hexo's own default). The reference image really uses 8080 (`-p 8080`, `EXPOSE 8080`). Use 8080: matches ContainerForge convention and the TrueCharts chart. |
| Bind address | `hexo-server` default `ip` is undefined, documented as "Bind to all IP address by default" (`::` with fallback to `0.0.0.0`). Still verify from a second container. |
| Data path | `/config` holds the whole blog (`_config.yml`, `source/`, `themes/`, `node_modules/`, `db.json`, `public/`). |

## 2. Target layout

```
apps/hexo-blog/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: the starter blog is baked at `/app/hexo-starter` during the build (see section 4) so first start works offline. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses this image as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: the draft proposes `python-node`, but the ubuntu base already installs Node (`NODE_VERSION` 26.13.1 in `apps/ubuntu/docker-bake.hcl`, in `/usr/local`), npm, yarn and git (`hexo init` needs git). Python is not needed, so python-node is wasted size. Closest siblings: `apps/it-tools` (npm build on ubuntu), `apps/thelounge` (node app, `start.sh` with `exec`).

## 4. Dockerfile

1. `FROM` line above, `ARG VERSION`, `ARG TARGETARCH` (not needed for arch mapping, JS only; omit TARGETARCH).
2. `ENV NPM_CONFIG_CACHE=/tmp/.npm NPM_CONFIG_UPDATE_NOTIFIER=false NPM_CONFIG_FUND=false NPM_CONFIG_AUDIT=false HOME=/tmp` for the build and runtime, and `ENV PATH=/app/hexo-cli/node_modules/.bin:$PATH`. Caches in `/tmp`, never `/config`. (Base sets `HOME=/config`; override it to `/tmp` so `npm`/`git` scratch never lands in `/config`.)
3. `USER root`, then one RUN:
   - `mkdir -p /app/hexo-cli && npm install --prefix /app/hexo-cli --omit=dev hexo-cli@${VERSION}` (npm verifies the sha512 integrity of every tarball).
   - Bake the starter: `hexo init --no-install /app/hexo-starter`, then `npm install --prefix /app/hexo-starter --omit=dev`, then `test -f /app/hexo-starter/node_modules/hexo/package.json`. Do not let `hexo init` install: in hexo-cli 4.3.2 (`lib/console/init.ts`) it prefers `yarn`, which the ubuntu base ships, and an install failure is only a warning, so the build would pass without `node_modules`. A failed `git clone` also only warns and copies the CLI's bundled assets instead, so decide whether that fallback is acceptable. `init` removes the `.git` directories itself.
   - License files: `mkdir -p /usr/share/licenses/hexo-blog && cp /app/hexo-cli/node_modules/hexo-cli/LICENSE /usr/share/licenses/hexo-blog/LICENSE-hexo-cli` and the same for `/app/hexo-starter/node_modules/hexo/LICENSE` (check the exact file names after install; fail the build if missing).
   - `chown -R apps:apps /app && chmod -R 755 /app`; `npm cache clean --force; rm -rf /tmp/* /tmp/.npm`.
   - No apt packages (git, curl, ca-certificates already in base). Nothing to pin.
4. `USER apps`
5. `COPY --chmod=0755 . /`
6. `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP` = `hexo-blog`
- `VERSION`: `// renovate: datasource=npm depName=hexo-cli` then `default = "4.3.2"`
- `LICENSE` = `MIT`
- `SOURCE` = `https://github.com/hexojs/hexo`
- Targets copied from `apps/bazarr/docker-bake.hcl`: `docker-metadata-action`, `image` (args VERSION, labels source and licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Validate: `docker buildx bake --print` from `apps/hexo-blog`.
- Version alignment: Dockerfile `ARG VERSION` consumes this value (hexo-cli version). Note in the PR that image tag = hexo-cli version, while hexo core version is chosen by the blog's `package.json`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/hexojs/hexo"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: HEXO_PLUGINS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`dependencies`: none (nothing to list). `HEXO_PLUGINS` is read by `start.sh` (same meaning as the reference image).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

cd /config

# Seed only when the blog is missing. Unrelated files (lost+found, tool dot-directories) are tolerated,
# but a partial blog is not overwritten.
if [ ! -f /config/_config.yml ]; then
  if [ -e /config/package.json ] || [ -e /config/source ]; then
    echo "ERROR: /config has blog files but no _config.yml; refusing to overwrite them." >&2
    exit 1
  fi
  cp -a /app/hexo-starter/. /config/
fi

if [ -n "${HEXO_PLUGINS:-}" ]; then
  read -r -a plugins <<< "${HEXO_PLUGINS}"
  npm install --no-audit --no-fund --prefix /config "${plugins[@]}"
fi

# db.json and public/ are regenerated
hexo clean --cwd /config
exec hexo server --cwd /config -p 8080 --draft
```

`cp -a` copies hidden files and keeps the relative `node_modules/.bin` links (UNVERIFIED: that it does not fail on preserving attributes of a `/config` mount not owned by `apps`). Unlike the reference image, `@latest` is not forced on every start (users can write `name@latest` themselves). `--draft` as in the reference image; `--debug` dropped. No `-i`, so hexo-server binds all interfaces. The npm cache goes to `/tmp/.npm` through the ENV.

The script writes only to `/config` and `/tmp`, never to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
http:
- port: '8080'
  path: /
filePaths:
- /app/hexo-cli/node_modules/.bin/hexo
- /app/hexo-starter/_config.yml
```

`http` waits for TCP first, so the port is covered. The test needs no env vars (empty `/config` is seeded from the baked starter, no network). Timeout 180 as in the python/node siblings; raise to 240 if the first start is slow on CI.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `hexo init` clone and `npm install` at runtime (root-owned, needs internet) | Done at build time into `/app/hexo-starter`; copied to `/config` on first start. |
| npm cache `~/.npm` | `NPM_CONFIG_CACHE=/tmp/.npm`, `HOME=/tmp`. |
| `db.json`, `public/`, `node_modules/` | Live in `/config` (needed persistently: `node_modules` holds plugins and themes). |
| `/app` | Never written at runtime; owned by `apps`, mode 755. |

Draft security expectations: TrueCharts runs as UID 0 with `readOnlyRootFilesystem: false`; here UID 568 (`apps`), `--read-only` plus `/tmp` tmpfs. No privileged, no capabilities. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- `hexo server` is a development server (draft caveat): fine as a blog preview, not a hardened production host. Recommend `hexo generate` plus a static host for production; not in scope.
- Plugin install at start needs internet (draft caveat, now limited to when `HEXO_PLUGINS` is set). Native-compile plugins would need build tools that are not in the base; UNVERIFIED which plugins in the wild need them.
- Draft port 4000 was inferred and is wrong for the reference image: use 8080.
- Baked starter drifts: `hexo-starter` is cloned from its default branch at build time, so its content is not covered by the renovate `VERSION`. Accept, or pin a commit with a second `ARG` plus `git-refs` renovate annotation (open question for the maintainer).
- Draft "python-node" base replaced by plain ubuntu (Node is in it). Confirm with the maintainer.
- UNVERIFIED: exact license file names inside the installed npm packages; check after `npm install`.
- No blockers (not musl-only, no GPU, no privileged, arm64 works).

## 11. Build and test steps

```sh
cd apps/hexo-blog
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create hexo-blog-probe-config
docker run --rm -d --name hexo-blog-probe --read-only --tmpfs /tmp \
  -v hexo-blog-probe-config:/config hexo-blog:4.3.2
docker logs -f hexo-blog-probe
```

Expected readiness line: `Hexo is running at http://localhost:8080/ . Press Ctrl+C to stop.` (hexo-server log); the container stays up and port 8080 answers. Also check from another container: `curl http://hexo-blog-probe:8080/`. Run twice on the same volume to confirm the second start skips seeding. Then:

```sh
forgetool containers test --image hexo-blog:4.3.2 --config ./apps/hexo-blog/container-test.yaml
docker rm -f hexo-blog-probe; docker volume rm hexo-blog-probe-config
```

Also run once with `-e HEXO_PLUGINS="hexo-wordcount"` (needs internet) because the test cannot set env vars.

## 12. PR checklist

- Branch `feat/add-hexo-blog`, commit and PR title `feat(hexo-blog): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` (type: New container/image); only tick boxes that truly apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Pre-completion list: `bake --print` ok, `image-local` build ok, empty-`/config` read-only run ok, `forgetool` test ok, no assertion weakened, scratch containers and volumes removed.
- State honestly what was not tested (until done): arm64 build, `HEXO_PLUGINS` path, bind from another container, production use.
