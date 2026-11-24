# openspeedtest — implementation plan
> Source: ./draft.md · Target: apps/openspeedtest/ · Difficulty: hard in the draft, realistically easy (static files on the nginx base) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No release or tag exists (`/releases` empty, `/tags` returns `[]`). Pin the commit `f4263546f50694a154fdd27a03000390949068df` of `main` (2026-04-22, message "Updated"). Draft tag `latest` is rolling. |
| Renovate | `datasource=git-refs depName=https://github.com/openspeedtest/Speed-Test versioning=loose` (same pattern as `apps/nextcloud-imaginary/docker-bake.hcl`, which pins a commit SHA). |
| License | MIT (`License.md`, copyright OpenSpeedTest). SPDX `MIT`. |
| Source URL | https://github.com/openspeedtest/Speed-Test |
| Docker packaging | https://github.com/openspeedtest/Docker-Image (Dockerfile reviewed). It is public, so the draft's "no public Dockerfile" caveat is wrong. |
| Per-arch download | Not applicable: static HTML/JS/CSS, one tarball `https://github.com/openspeedtest/Speed-Test/archive/<sha>.tar.gz` for every arch. |
| Checksum source | None published. The tarball is addressed by commit SHA, which pins the content. Record this in the Dockerfile comment. |
| Web root contents | `index.html`, `hosted.html`, `assets/`, `downloading` (a 30 MB file used as the download payload), `upload` (empty file, POST target), `License.md`. |
| Upstream runtime | `nginx/nginx-unprivileged:stable-alpine`, HTTP 3000 and HTTPS 3001 (env `HTTP_PORT`, `HTTPS_PORT`, `CHANGE_CONTAINER_PORTS`, `ENABLE_LETSENCRYPT`, `DOMAIN_NAME`, `USER_EMAIL`, `SET_USER`, `ALLOW_ONLY`, `SET_SERVER_NAME`, `VERIFY_OWNERSHIP`). The draft ports 8080/8443 are not upstream; 8080 is the ContainerForge nginx port. |
| nginx behaviour needed | `error_page 405 =200 $uri` (so POST to static `/upload` returns 200), `client_max_body_size 35m`, `Cache-Control: no-store`, permissive CORS headers, `access_log off`, `gzip off` for the payload files. All from `files/OpenSpeedTest-Server.conf`. |
| Upstream TLS | `files/nginx.crt` and `nginx.key` are a public key pair committed to the repo. Do not ship them. |

## 2. Target layout

```
apps/openspeedtest/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/default.conf   # overrides the nginx base's /defaults/default.conf, copied to /config/sites by the base entrypoint script
```
No `start.sh`: the nginx base `CMD` and `docker-entrypoint.d` do the work (same as `apps/it-tools` and `apps/theme-park`). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` for the final stage, and `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for a small download stage (curl and tar are in the ubuntu base). Closest sibling: `apps/theme-park` (builder stage then COPY into nginx, `USER apps`).

## 4. Dockerfile

1. Stage `fetch` on ubuntu: `ARG VERSION`, `USER root`, `WORKDIR /tmp`, `curl -fsSL https://github.com/openspeedtest/Speed-Test/archive/${VERSION}.tar.gz | tar xz --strip-components=1`. No apt packages.
2. Final stage `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f...`, `USER root` (needed for `COPY --chown` into `/usr/share/nginx/html` as in theme-park).
3. `RUN rm -rf /usr/share/nginx/html/*` then `COPY --from=fetch --chown=568:568 /tmp/index.html /tmp/hosted.html /tmp/assets /tmp/downloading /tmp/upload` into `/usr/share/nginx/html/` (copy the directory `assets` as a directory, files individually; check the result with `ls`).
4. `COPY --from=fetch /tmp/License.md /usr/share/licenses/openspeedtest/LICENSE`.
5. No ENV changes needed: the base already sets pid and all temp paths to `/tmp` in `/defaults/nginx.conf`.
6. `USER apps`, then `COPY --chmod=0755 . /` (brings `defaults/default.conf` to `/defaults/default.conf`, replacing the base's copy), `WORKDIR /usr/share/nginx/html`.
7. `EXPOSE 8080` is already set by the nginx base (repeat it explicitly). `/config` is the persistent path (seeded by the base entrypoint script). Do not add TLS.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "openspeedtest" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/openspeedtest/Speed-Test versioning=loose
  default = "f4263546f50694a154fdd27a03000390949068df"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/openspeedtest/Speed-Test" }
```
Plus `target "docker-metadata-action" {}`, `group "default" { targets = ["image-local"] }`, `target "image"` (args `VERSION`, labels source and licenses), `target "image-local"` (inherits image, `output = ["type=docker"]`, `tags = ["${APP}:${VERSION}"]`) and `target "image-all"` (linux/amd64, linux/arm64), copied from `apps/it-tools/docker-bake.hcl`. The image tag becomes the 40-char SHA; acceptable, matching how nextcloud-imaginary uses a SHA. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header + `schema_version: 1`, `upstream_env_url: "https://github.com/openspeedtest/Speed-Test"`.
- ports: `8080` tcp, `required: false`.
- env: `TZ` default `Etc/UTC`, `required: false`. Nothing else: upstream's env vars (`HTTP_PORT`, `ENABLE_LETSENCRYPT`, ...) are consumed by an upstream entrypoint script that this image does not have, so they must not be listed.
- volumes: `/config` `required: true` (holds `nginx.conf` and `sites/`).
- dependencies: none.

## 7. start.sh

Not applicable: the nginx base `CMD ["nginx","-c","/config/nginx.conf","-g","daemon off;"]` is the final process, and the base `docker-entrypoint.d/03-copyconfig.sh` seeds `/config/nginx.conf` and `/config/sites/default.conf` with `cp -n` (idempotent, empty `/config` safe). `defaults/default.conf` content:
- `listen 8080 default_server; listen [::]:8080 default_server; server_name _; root /usr/share/nginx/html; index index.html;`
- `client_max_body_size 35m; error_page 405 =200 $uri; access_log off; gzip off; server_tokens off; sendfile on; tcp_nodelay on; tcp_nopush on;`
- `location /` with `Cache-Control: no-store, no-cache, max-age=0, no-transform`, `Access-Control-Allow-Origin *`, the CORS allow headers/methods, `if_modified_since off; expires off; etag off;`, and the OPTIONS `return 200` block, all copied from upstream `OpenSpeedTest-Server.conf`.
- the static-asset `location ~* ...` block with `expires 365d` and gzip for css/js/svg, but **not** for `downloading` and `upload`.
- Drop: the `ssl` listeners, `ssl_*` lines, `error_log /dev/null` and the acme-challenge location.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/nginx/html/downloading
- /usr/share/nginx/html/upload
- /usr/share/licenses/openspeedtest/LICENSE
```
Port 8080 is the only port in settings.yaml and has an http probe. No `timeoutSeconds` (theme-park and it-tools omit it; nginx starts in seconds). No env vars are needed, so the test exercises every code path.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID 0, `readOnlyRootFilesystem: false`; the image runs as `apps` (568) with a read-only rootfs.
- nginx writes: pid `/tmp/nginx.pid`, temp dirs `/tmp/*_temp`, cache `/tmp/nginx-cache` (all set in the base `/defaults/nginx.conf`); logs go to stdout/stderr via the base symlinks.
- Upload test bodies (up to 35 MB) are buffered in `/tmp/client_temp`, so `/tmp` must be at least 35 MB per concurrent upload.
- Web root `/usr/share/nginx/html` is read-only and never written (upstream's `SET_SERVER_NAME`/`VERIFY_OWNERSHIP` sed edits are intentionally not ported).
- No extra persistence (draft: none).

## 10. Risks, caveats and open questions

- No tags: renovate git-refs will open a PR for every commit on `main`; confirm the repo's renovate config handles `git-refs` for `datasource=git-refs` (precedent: nextcloud-imaginary, kasmvnc). UNVERIFIED: exact renovate behaviour for this repo, not run.
- HTTPS (3001 upstream) is dropped; terminate TLS at the ingress. The Speed-Test client talks to the same origin, so a reverse proxy must not buffer or gzip `/downloading` and `/upload`.
- Accuracy depends on the proxy path and on `no-store` headers being kept; keep upstream's header block intact.
- Draft blocker "no public Dockerfile" is resolved: the packaging Dockerfile is public and trivial.
- arm64: no native code, so no arch risk.

## 11. Build and test steps

```sh
cd apps/openspeedtest
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name openspeedtest-probe --read-only --tmpfs /tmp -v openspeedtest-probe-config:/config openspeedtest:f4263546f50694a154fdd27a03000390949068df
docker logs -f openspeedtest-probe        # expect nginx running with no [emerg]/[crit]; "[00-copyconfig]" line seen
curl -sS -o /dev/null -w '%{http_code} %{size_download}\n' http://<container-ip>:8080/downloading   # 200 30457280-ish bytes
curl -sS -X POST --data-binary @/dev/zero --max-filesize 1 http://<container-ip>:8080/upload        # or head -c 5M; expect 200
docker rm -f openspeedtest-probe; docker volume rm openspeedtest-probe-config
forgetool containers test --image openspeedtest:f4263546f50694a154fdd27a03000390949068df --config ./apps/openspeedtest/container-test.yaml
```
Success signal: container stays up, `GET /` returns 200, POST `/upload` returns 200.

## 12. PR checklist

- [ ] Branch `feat/add-openspeedtest`, commit and title `feat(openspeedtest): add new container`, target `main`.
- [ ] PR body follows `.github/PULL_REQUEST_TEMPLATE.md`, only applicable boxes checked.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] `docker buildx bake --print` clean, VERSION aligned between bake and Dockerfile `ARG`.
- [ ] State honestly what is untested (arm64 build, upload speed accuracy behind a proxy, renovate git-refs behaviour) and do not tick "Built container locally" unless it was.
