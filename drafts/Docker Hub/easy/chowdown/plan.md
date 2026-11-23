# chowdown — implementation plan
> Source: ./draft.md · Target: apps/chowdown/ · Difficulty: easy (draft) but needs a Jekyll build stage · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases and no tags exist. The draft pins the moving `gh-pages` branch zip. Latest commit on `gh-pages`: `48d56ea7a0115f722653dac6466b861f7eed4ca3` ("beef", 2025-10-28). Pin this commit as `VERSION`. |
| Renovate | `datasource=git-refs depName=https://github.com/clarklab/chowdown currentValue=gh-pages` (same pattern as `apps/tvheadend/docker-bake.hcl`, which tracks `master` with a commit SHA default) |
| License | Unlicense (public domain; LICENSE file in repo root) |
| Source | https://github.com/clarklab/chowdown (site https://chowdown.io) |
| **Important correction to the draft** | `gh-pages` is **Jekyll source, not a built static site** ("This is a Jekyll build"; `_config.yml`, `_layouts`, `_includes`, `_recipes`, `_components`). The upstream docker image (https://github.com/gregyankovoy/docker-chowdown/blob/9f355c82d5e74d0da93ec86d9cb32541ca6ca45c/Dockerfile) installs Ruby plus Jekyll and runs `jekyll serve --host=0.0.0.0` on port 4000. Serving the zip contents with nginx as-is would not work; the site must be built with Jekyll. |
| `_config.yml` (partial read) | `baseurl: "https://chowdown.io"`, `markdown: kramdown`, `permalink: /:title:output_ext`, collections `components` and `recipes` (both `output: true`), `exclude: [Gemfile, Gemfile.lock, Rakefile, README.md]`, English and German translations. No `plugins`/`gems` key, and no `Gemfile` in the repo (raw URL 404). So stock Jekyll is enough. |
| Jekyll | Ubuntu 26.04 (resolute) universe has `jekyll` 4.4.1+dfsg-2 (arch all); RubyGems latest is jekyll 4.4.1 (MIT). Builder-only, so no version pin needed in the final image. |
| Checksum | none published. Pinning a full commit SHA in the download URL is the integrity control. |
| Archive URL | `https://github.com/clarklab/chowdown/archive/<sha>.tar.gz` (the draft uses `.../archive/refs/heads/gh-pages.zip`, unversioned) |
| Upstream Dockerfile reviewed | the gregyankovoy one above (Alpine, broken as written: missing unzip command, missing `\`, obsolete `--no-ri`). Its `chowdown.sh` copies source dirs into `/config` and runs `jekyll serve` there, so users can edit recipes in `/config`. |
| Port | upstream container 4000 (Jekyll). Ours: 8080/tcp from the ContainerForge nginx base (rootless, not 80 as the draft says). |
| Env vars | none read by the app. `PUID`/`PGID` in the upstream script are only echoed. |

## 2. Target layout

```
apps/chowdown/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
```

- No `start.sh`: the nginx base already starts nginx through its CMD and `/docker-entrypoint.d` (siblings `apps/it-tools` and `apps/theme-park` also have none).
- No `defaults/`, `docker-entrypoint.d/`: the nginx base seeds `/config/nginx.conf` and `/config/sites/default.conf` (`root /usr/share/nginx/html; index index.html index.htm;`, listen 8080), which already serves the Jekyll output. Add a custom `defaults/default.conf` plus `docker-entrypoint.d/10-copyconfig.sh` (it-tools pattern) only if the first run shows the permalinks need `try_files`, see section 10.
- No `root/`, no `DOWNSTREAM_CHANGES.md`. Nearest sibling: `apps/theme-park` (build stage, then copy files into the nginx image).

## 3. Base image

Runtime stage (exact line from `apps/theme-park/Dockerfile`):

```
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f
```

Builder stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder` (the draft's "alternative runtime image: ubuntu" is only needed for the build). Jekyll is Ruby, so the python base is not useful.

## 4. Dockerfile

1. Builder:
   ```dockerfile
   FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb... AS builder
   ARG VERSION
   USER root
   WORKDIR /tmp/src
   ENV HOME=/tmp
   RUN apt-get update && apt-get install -y --no-install-recommends jekyll && rm -rf /var/lib/apt/lists/*
   RUN curl -fsSL "https://github.com/clarklab/chowdown/archive/${VERSION}.tar.gz" | tar xz --strip-components=1 \
       && jekyll build --source /tmp/src --destination /tmp/site --baseurl "" --disable-disk-cache
   ```
   - Universe must be enabled in the base (the stock ubuntu image enables it; if the apt lookup fails, run `add-apt-repository -y universe`, `software-properties-common` is in the base). Package pin is not needed (builder only, not in the final image).
   - `--baseurl ""` overrides `https://chowdown.io`. After the build check for leftovers: `grep -rl 'https://chowdown.io' /tmp/site`; if hits remain (templates using `site.url` or hardcoded links), strip them with `sed -i 's|https://chowdown.io||g'` as `apps/theme-park` does for its host.
   - Fail the build if the output is empty: `test -f /tmp/site/index.html`.
2. Final stage:
   ```dockerfile
   FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f...
   USER root
   COPY --from=builder --chown=568:568 /tmp/site/ /usr/share/nginx/html/
   COPY --from=builder --chown=568:568 /tmp/src/LICENSE /usr/share/licenses/chowdown/LICENSE
   USER apps
   COPY --chmod=0755 . /
   WORKDIR /usr/share/nginx/html
   ```
   Keep `COPY --chmod=0755 . /` (required). `EXPOSE 8080` and `VOLUME /config` are inherited from the nginx base; repeat them explicitly for clarity (as it-tools does implicitly). No `apt` in the final stage; the draft's `unzip` is not needed (tar.gz, and unzip is in the ubuntu base anyway).
3. `ARG VERSION` must be declared in the builder stage and equals the bake default (the commit SHA).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "chowdown" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/clarklab/chowdown currentValue=gh-pages
  default = "48d56ea7a0115f722653dac6466b861f7eed4ca3"
}
variable "LICENSE" { default = "Unlicense" }
variable "SOURCE"  { default = "https://github.com/clarklab/chowdown" }
```

Standard targets: `docker-metadata-action`, `default` -> `image-local`, `image` (args VERSION, OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`; the tag is a 40-char SHA, as for tvheadend and kasmvnc), `image-all` (`linux/amd64`, `linux/arm64`). Run `docker buildx bake --print`. The built output is architecture independent HTML; both platforms just reuse the nginx base.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/clarklab/chowdown"
ports:
  - port: 8080
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

Same shape as `apps/it-tools/settings.yaml` and `apps/theme-park/settings.yaml` (check whether siblings omit `dependencies` entirely and do the same). `NGINX_PORT` from the nginx base is not listed because the seeded `default.conf` hard-codes 8080. `/config` is listed because the nginx base keeps its generated config there (it is not user data for chowdown).

## 7. start.sh

Not applicable: no `start.sh`. The nginx base's CMD `nginx -c /config/nginx.conf -g "daemon off;"` and its `docker-entrypoint.d/03-copyconfig.sh` (seeds `/config/nginx.conf` and `/config/sites/default.conf` with `cp -n`, creates `/config/sites`) provide idempotent empty-`/config` startup, listen on all interfaces (8080), write temp and cache dirs to `/tmp`, and nginx is the long-running process under tini. Verify these facts in the nginx app files at implementation time rather than re-implementing them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /

filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/licenses/chowdown/LICENSE
```

The probe on `/` matches `apps/it-tools` and `apps/theme-park`; the port is the only one in `settings.yaml`. No env vars are required, and no `timeoutSeconds` is used by the nginx siblings (add 120 only if the run is slow). Optional extra `http` check on a recipe page after the first build shows a real permalink (UNVERIFIED which file names exist).

## 9. Rootless and read-only-rootfs adaptations

- Upstream container wrote the whole site into `/config` (chmod 777) and ran `jekyll serve` as root; the draft chart had root, `readOnlyRootFilesystem: false`, no extra persistence. Reconciled: the site is built at image build time into `/usr/share/nginx/html` (owned 568, read-only at runtime). Runtime writes are only nginx's `/tmp` paths and `/config` (nginx config seeded by the base), UID 568, read-only rootfs compatible, port 8080 instead of 80/4000.
- Jekyll's `.jekyll-cache` and `_site` are confined to `/tmp` in the builder (`--disable-disk-cache`, destination under `/tmp`); nothing from the build stage except the output and the license is copied.
- Not privileged.

## 10. Risks, caveats and open questions

- Draft says "static site, no runtime code": corrected above; a Jekyll build stage is required. Verify the build succeeds with the distro Jekyll 4.4.1 (the site was written for the GitHub Pages Jekyll 3.x, so deprecated syntax warnings or errors are possible; fix with the smallest change or install a matching `jekyll` gem version in the builder instead).
- Behaviour change versus the upstream docker image: users can no longer drop their own recipes into `/config` and have Jekyll rebuild them live. Recipes baked into the image are upstream's samples only. If user recipes are a requirement, this needs a different design (a runtime Jekyll build in `start.sh`, Ruby in the final image); out of scope for "easy".
- `permalink: /:title:output_ext` produces `/recipe-name.html` style URLs, so the default nginx location works; but links without `.html` would 404. If the first run shows that, add `try_files $uri $uri.html $uri/ =404;` via an `it-tools`-style `defaults/default.conf` and `docker-entrypoint.d/10-copyconfig.sh` (it-tools copies with plain `cp` so the base's default is overridden; replicate that).
- Unversioned upstream: `VERSION` is a commit SHA; renovate on a branch ref produces a PR per commit. The repo is lightly maintained (last commit 2025-10-28).
- Build needs internet (GitHub and the Ubuntu archive).
- The site may load external assets (fonts, CDN scripts, analytics); not audited. Check the rendered HTML for external hosts and mention in the PR.
- No blockers: no musl, no GPU, no privilege, amd64 and arm64.

## 11. Build and test steps

```sh
cd apps/chowdown
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name chowdown-probe --read-only --tmpfs /tmp \
  -v chowdown-probe-config:/config chowdown:48d56ea7a0115f722653dac6466b861f7eed4ca3
docker logs -f chowdown-probe
```

- Expected readiness signal: entrypoint lines about copying the default NGINX config, then nginx running with no `[emerg]` or `[crit]` lines; port 8080 open. `curl -sI http://<container-ip>:8080/` returns 200 and a body mentioning "Chowdown"; also fetch one recipe URL and the CSS file; `grep -c 'chowdown.io'` on the HTML should be 0 apart from legitimate external links.
- Cleanup: `docker rm -f chowdown-probe; docker volume rm chowdown-probe-config`.
- `forgetool containers test --image chowdown:48d56ea7a0115f722653dac6466b861f7eed4ca3 --config ./apps/chowdown/container-test.yaml`.
- Max 10 rounds; do not weaken the `http` probe.

## 12. PR checklist

- Branch `feat/add-chowdown`, commit and PR title `feat(chowdown): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick "New container/image" and only the boxes that apply; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- Notes: Jekyll build stage (draft assumed static), port 8080, no live recipe editing, pinned to commit 48d56ea, base images (nginx 1.28.3 digest, ubuntu 26.04 digest).
- Untested until run: Jekyll 4.4.1 build, arm64 build, permalink behaviour in nginx, external asset references.
- Checklist: app-scoped, instructions read, `VERSION` aligned between bake and Dockerfile `ARG`, rootless and read-only OK, empty `/config` OK (nginx base seeds it), `bake --print` run, no DOWNSTREAM file.
