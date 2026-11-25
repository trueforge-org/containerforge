# rickroll — implementation plan
> Source: ./draft.md · Target: apps/rickroll/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Upstream | https://github.com/modem7/docker-rickroll (default branch `master`, last push 2026-11-14) |
| Version | No product version exists. The repo has one release, `video-assets-v1` (assets only). Upstream image tag is `latest`. Proposal: pin a commit of `master`; HEAD on 2026-11-25 is `db8d928c7a6af1b7cd4b4b12653ef5f1ec161fee` (recheck at implementation time). |
| Renovate | `datasource=git-refs depName=https://github.com/modem7/docker-rickroll currentValue=master` with `VERSION` = the pinned commit SHA (same comment form as `apps/tvheadend/docker-bake.hcl`). |
| License | MIT (GitHub API `license.spdx_id`). The video content license is not stated, see section 10. |
| Source URL | https://github.com/modem7/docker-rickroll |
| Assets | Release `video-assets-v1` (published 2026-07-07): `video.mp4` 29,760,963 B sha256 `7fe57b3d2f695e13ff7431e094a74960ea4f6b847a0c4472ce5b414d7ca7937e`; `video-480p.mp4` 61 MB; `video-720p.mp4` 116 MB; `video-1080p.mp4` 224 MB sha256 `6ca8c737a5ecdea2228fdc0a2f48e1daf5ad52dfa8bede7aa2e6478122971108`; `video-2160p.mp4`; `video4k.mkv`. URL pattern `https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/<name>`. Architecture independent (static file), so no per-arch URLs. |
| Checksum source | GitHub asset digests (sha256 above) from the releases API. No separate checksum file. |
| Current upstream Dockerfile | Builds on `nginxinc/nginx-unprivileged:1.31.7-alpine`, downloads `video-1080p.mp4` by default (ARG `VIDEO_URL`), copies `scripts/*.sh` and `scripts/index/80-index.sh` to `/docker-entrypoint.d/`, EXPOSE 8080, health on 9090 `/healthz`. The draft's pinned commit `40cce76b...` is older and used `video.mp4`. |
| Scripts | `40-roll.sh` (sed-expands compressed lyrics text), `70-nginx.sh` (writes `/etc/nginx/nginx.conf`, port from `PORT` default 8080, `VIDEO_FILE` default `video.mp4`, health server on 9090), `index/80-index.sh` (writes `/usr/share/nginx/html/index.html`). |
| Env (80-index.sh) | `TITLE` (Rickroll), `PRE_TITLE` (Loading...), `HEADLINE` (empty), `HEIGHT` (100vh), `WIDTH` (100%), `OBJECT_FIT` (cover), `LOOP` (true), `VIDEO_FILE` (video.mp4; value with `://` is a full URL), `OVERLAY` (random; `error`, `loading`). Values are inserted unescaped into HTML/JS. |
| Env (70-nginx.sh) | `PORT` (8080), `VIDEO_FILE` (video.mp4) |
| Port | 8080 http (page); 9090 is only an upstream health endpoint. The draft's port 80 is wrong for a rootless image. |
| Upstream Dockerfile reviewed | https://github.com/modem7/docker-rickroll/blob/40cce76bf9f796d5171584624793f62db4bc9e84/Dockerfile (draft pin) and `master` Dockerfile. |

## 2. Target layout

```
apps/rickroll/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/default.conf         # nginx server block, copied to /config/sites/default.conf
  docker-entrypoint.d/10-copyconfig.sh
  docker-entrypoint.d/80-index.sh   # adapted from upstream, writes /tmp/html/index.html
```
- Follow `apps/it-tools` (nginx base with `defaults/` and `docker-entrypoint.d/`). The nginx base starts via its CMD (`nginx -c /config/nginx.conf`), so there is no `start.sh` (it-tools and theme-park have none either); the entrypoint scripts below take its place.
- No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`

Reason: static page served by nginx. Closest siblings: `apps/it-tools` and `apps/theme-park` (both nginx base, port 8080, `COPY --chmod=0755 . /`).
Optional builder stage on `ubuntu` is not needed: `curl` is available in the nginx base's ubuntu layer (confirm; otherwise use a throwaway `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS video` stage like `apps/theme-park` uses a builder).

## 4. Dockerfile

1. Stage `video` (ubuntu base, `USER root`): `ARG VIDEO_NAME=video.mp4`, `ARG VIDEO_SHA256=7fe57b3d...937e`; `curl -fsSL -o /video.mp4 https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/${VIDEO_NAME}`; `echo "${VIDEO_SHA256}  /video.mp4" | sha256sum -c -`.
2. Final stage `FROM` the nginx base, `ARG VERSION` (pinned commit SHA), `USER root`.
3. `COPY --from=video --chown=568:568 /video.mp4 /usr/share/nginx/html/video.mp4` (read-only at runtime).
4. Fetch the upstream `scripts/index/80-index.sh` at `${VERSION}` only if you want to track upstream; otherwise copy the adapted file from `docker-entrypoint.d/` (MIT notice must be kept). License file: `/usr/share/licenses/rickroll/LICENSE` fetched from `https://raw.githubusercontent.com/modem7/docker-rickroll/${VERSION}/LICENCE.txt` (upstream spells it `LICENCE.txt`).
5. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /usr/share/nginx/html`, `EXPOSE 8080`, `VOLUME /config` (as it-tools; the nginx base already sets `CMD`).
- No apt packages.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "rickroll" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/modem7/docker-rickroll currentValue=master
  default = "db8d928c7a6af1b7cd4b4b12653ef5f1ec161fee"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/modem7/docker-rickroll" }
```
Standard four targets and `group "default"` from `apps/it-tools/docker-bake.hcl`; `image-all` platforms amd64 + arm64. `apps/it-tools` uses a `github-releases` comment, so take the `git-refs` form from `apps/tvheadend`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/modem7/docker-rickroll"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: HEADLINE
    default: ""
    required: false
  - name: HEIGHT
    default: "100vh"
    required: false
  - name: LOOP
    default: "true"
    required: false
  - name: OBJECT_FIT
    default: "cover"
    required: false
  - name: OVERLAY
    default: "random"
    required: false
  - name: PRE_TITLE
    default: "Loading..."
    required: false
  - name: TITLE
    default: "Rickroll"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: WIDTH
    default: "100%"
    required: false
volumes:
  - path: /config
    required: true
```
`VIDEO_FILE` and `PORT` are left out on purpose: the video is baked in and the port is fixed at 8080 for rootless nginx. No dependencies.

## 7. docker-entrypoint.d scripts (instead of start.sh)

- `10-copyconfig.sh` (as it-tools): `mkdir -p /config/sites && cp /defaults/default.conf /config/sites/default.conf`. Overwrites each start because the file is image-managed.
- `80-index.sh`: adapt upstream so it writes to `/tmp/html/index.html` (not `/usr/share/nginx/html`), keeps `set -eu`, and exits non-zero never on unset vars (use `${VAR:-default}`). Escape values for HTML/JS or document that env is trusted.
- `defaults/default.conf`: server on `listen 8080 default_server; listen [::]:8080 default_server;`, `location = / { root /tmp/html; try_files /index.html =404; }`, `location = /video.mp4 { root /usr/share/nginx/html; }`; keep `/config/nginx.conf` from the base (seeded by the base's `03-copyconfig.sh` with `cp -n`). Use `location / { return 302 /; }` for other paths if desired.
- UNVERIFIED: whether the ubuntu nginx package has `ngx_http_mp4_module`; do not use `mp4;`. Plain byte-range serving works for seeking.
- `apps/ubuntu/entrypoint.sh` runs the executable `/docker-entrypoint.d/*.sh` files in `sort -V` order, then `exec`s the CMD when there is no `/start.sh`. The base's `03-copyconfig.sh` runs first, and `COPY --chmod=0755` makes this app's scripts executable. `docker-entrypoint.d/` and `defaults/` are in the `.dockerignore` allow-list.
- `80-index.sh` must `mkdir -p /tmp/html` (the tmpfs is empty at start). Drop upstream's final `exec "$@"`, and hard-code `/video.mp4` instead of reading `VIDEO_FILE`, because `settings.yaml` does not declare it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
- port: '8080'
  path: /video.mp4
filePaths:
- /usr/share/nginx/html/video.mp4
- /usr/share/licenses/rickroll/LICENSE
```
Port 8080 is the only declared port. Test runs with default env, so the index page is generated with defaults.

## 9. Rootless and read-only-rootfs adaptations

- Draft/chart: runAsUser 0, readOnlyRootFilesystem false; draft expects read-only rootfs. Target: user `apps`, read-only rootfs.
- Upstream writes `/etc/nginx/nginx.conf` and `/usr/share/nginx/html/index.html` at start. Remap: nginx conf comes from `/config` (base image), generated HTML to `/tmp/html`. Video stays in read-only `/usr/share/nginx/html`.
- nginx temp/cache paths already point at `/tmp` in the base `nginx.conf`.
- Port 80 in the chart becomes 8080; upstream health port 9090 is dropped.

## 10. Risks, caveats and open questions

- Copyright: the video is a copy of a commercial music video and `40-roll.sh` embeds the song lyrics. The repo license is MIT, which cannot cover that content. A maintainer must decide whether publishing this to ghcr.io is acceptable before implementation. This is the main blocker; if declined, close the draft as won't-do.
- Draft caveat: the build needs internet and the `video-assets-v1` asset to remain available. Mitigated by sha256 pin; the build fails closed if the asset changes.
- Size: `video.mp4` is about 30 MB; upstream now defaults to the 1080p file (224 MB). Choose the small file unless asked; expose `VIDEO_NAME` build arg only.
- No version scheme: the image tag will be a commit SHA, which renovate may handle poorly. Confirm the convention with maintainers.
- No `00-index` style scripts from upstream are copied wholesale; `40-roll.sh` is not ported (lyrics).
- No arm64 or amd64 blockers.

## 11. Build and test steps

```sh
cd apps/rickroll
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name rickroll-probe -p 8080:8080 --read-only --tmpfs /tmp -v rickroll-probe-config:/config rickroll:<VERSION>
docker logs -f rickroll-probe     # expect the nginx start with no "Permission denied" or "Read-only file system"
curl -fsS http://localhost:8080/ | head   # reach it from another container as well
curl -fsSI -H 'Range: bytes=0-99' http://localhost:8080/video.mp4   # expect 206
docker rm -f rickroll-probe; docker volume rm rickroll-probe-config
forgetool containers test --image rickroll:<VERSION> --config ./apps/rickroll/container-test.yaml
```

## 12. PR checklist

- Branch `feat/add-rickroll`, commit and PR title `feat(rickroll): add new container`, target `main`.
- PR template filled; Notes carry `🤖 This PR is AI generated.`
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: renovate `git-refs` annotation, entrypoint scripts, arm64, and anything not actually built or run.
- Mention the copyright question in the PR description so a maintainer decides.
