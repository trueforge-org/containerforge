# newyearcountdownclock — implementation plan
> Source: ./draft.md · Target: apps/newyearcountdownclock/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags upstream. Pin master HEAD `393458057f1380dd0f83bed447c6ac740e342a08` (2026-11-14, checked 2026-11-25). The draft's commit `a1c6bede2351d2912dcd25e7d15e30f82be6b12f` is 5 commits older; the diff touches only `.gitattributes` and `.github/workflows/`, so `src/` and `conf/` are identical. |
| Renovate | `datasource=git-refs depName=https://github.com/modem7/Docker-NewYearCountdown currentValue=master` |
| License | MIT (LICENSE in repo root), SPDX `MIT`. The countdown is credited to patrickgold/newyear-countdown, which GitHub also reports as MIT. |
| Source URL | https://github.com/modem7/Docker-NewYearCountdown |
| Download | `https://github.com/modem7/Docker-NewYearCountdown/archive/<sha>.tar.gz` (source archive; static files, arch-independent) |
| Checksum source | None; commit SHA pin only. |
| Layout | `src/` (`index.html`, `countdown.html`, `countdown.js`, `countdown.css`, `countdown.scss`, `favicon.svg`), `conf/nginx-site.conf`, `Dockerfile`, `LICENSE`, `README.md`. |
| Upstream Dockerfile | `nginxinc/nginx-unprivileged` alpine, copies `src/` to `/usr/share/nginx/html/`, `conf/nginx-site.conf` to `/etc/nginx/conf.d/default.conf`, EXPOSE 8080, healthcheck `curl 127.0.0.1:8080/healthz`, runs as UID 101. |
| nginx-site.conf | listen 8080, `location /healthz` returns 200, `location /` uses `try_files $uri $uri/ =404`, `error_page 404 /index.html`, static asset `expires 5d`, security headers (nosniff, X-Frame-Options DENY, no-referrer, CSP `default-src 'self'` with inline script/style), gzip level 6. `index.html` is a meta refresh to `countdown.html`; no external URLs were found in the HTML, JS or CSS. |
| Ports | 8080/tcp (HTTP). The draft's 8080 matches. |
| Env | None read by the app. |

## 2. Target layout

```
apps/newyearcountdownclock/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/default.conf     # site config adapted from upstream conf/nginx-site.conf
```

No `start.sh`: the nginx base runs `nginx -c /config/nginx.conf` through the ubuntu entrypoint (same as `apps/it-tools`, which has no start.sh). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1`

Why: static site, exactly what `apps/it-tools` and `apps/theme-park` do. `curl` and `tar` come from the ubuntu layer, so no apt step. The nginx base already provides `/config/nginx.conf` seeding (`docker-entrypoint.d/03-copyconfig.sh`: `cp -n /defaults/nginx.conf` and `/defaults/default.conf`) and includes `/config/sites/*.conf`. Closest sibling: `apps/it-tools`.

## 4. Dockerfile

1. `ARG VERSION` (commit SHA); `USER root`.
2. `RUN set -eux`:
   - `mkdir -p /tmp/src /usr/share/licenses/newyearcountdownclock`
   - `curl -fsSL "https://github.com/modem7/Docker-NewYearCountdown/archive/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /tmp/src`
   - `cp -r /tmp/src/src/. /usr/share/nginx/html/` (replace the default content: `rm -rf /usr/share/nginx/html/*` first, this folder is the nginx base's placeholder)
   - `cp /tmp/src/LICENSE /usr/share/licenses/newyearcountdownclock/`
   - `chown -R 568:568 /usr/share/nginx/html && chmod -R 755 /usr/share/nginx/html`; `rm -rf /tmp/src`.
   - Do not copy `countdown.scss` if size matters (harmless otherwise).
3. `USER apps`; `COPY --chmod=0755 . /` (brings `defaults/` from the allow-list; overrides the base's `/defaults/default.conf`).
4. `WORKDIR /usr/share/nginx/html` (like it-tools).
5. `EXPOSE 8080` is inherited from the base; repeat for clarity. `VOLUME /config`.
6. No `CMD`: inherit the base `CMD ["nginx","-c","/config/nginx.conf","-g","daemon off;"]`.

## 5. docker-bake.hcl

`APP=newyearcountdownclock`; `VERSION` default `"393458057f1380dd0f83bed447c6ac740e342a08"` (update if HEAD moved) preceded by `// renovate: datasource=git-refs depName=https://github.com/modem7/Docker-NewYearCountdown currentValue=master`; `LICENSE="MIT"`; `SOURCE="https://github.com/modem7/Docker-NewYearCountdown"`. Four standard targets plus `group "default"` per `apps/it-tools/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/modem7/Docker-NewYearCountdown"
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
```

(TZ is the repo-wide convention in it-tools/nginx; the countdown itself runs in the visitor's browser.) `dependencies`: none.

## 7. start.sh

Not applicable: no `start.sh` is shipped (nginx base entrypoint, see `apps/it-tools`). Config seeding is handled by the base's `docker-entrypoint.d/03-copyconfig.sh`, so this app adds no script:

`defaults/default.conf` (own file, content adapted from upstream `conf/nginx-site.conf`, verified behaviors only):

```nginx
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    server_name _;
    root /usr/share/nginx/html;

    index index.html;
    error_page 404 /index.html;

    location /healthz { return 200; }
    location / { try_files $uri $uri/ =404; }
    # plus the upstream gzip block, `expires 5d` asset location and security headers
}
```

Because the base's `03-copyconfig.sh` does `cp -n /defaults/default.conf /config/sites/default.conf` and our `COPY . /` overrides `/defaults/default.conf`, the file is seeded only when missing. Verify this in round 1. Because of `cp -n`, a later change to the shipped `default.conf` does not reach an existing `/config`. Copy the full upstream header values (CSP etc.) from `conf/nginx-site.conf` at the pinned commit rather than from this summary.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
- port: '8080'
  path: /healthz
filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/nginx/html/countdown.html
- /usr/share/nginx/html/countdown.js
```

Port 8080 is the only port in settings.yaml and has an HTTP probe. Timeout: nginx siblings set none. Test runs without env; nothing needs env.

## 9. Rootless and read-only-rootfs adaptations

- nginx writes: pid `/tmp/nginx.pid`, temp and cache dirs under `/tmp` (set in the base's `/config/nginx.conf`), logs to stdout/stderr. Site content in `/usr/share/nginx/html` is read-only at runtime.
- Draft says chart runs as UID 0 with writable rootfs: not needed. Run as `apps` (568), port 8080 (unprivileged), read-only rootfs OK. No extra persistence.
- Upstream CSP/headers can be kept: no external hosts were found in the page sources (browser behaviour UNVERIFIED).

## 10. Risks, caveats and open questions

- Draft caveats: the countdown uses the visitor's browser timezone; the chart pulled `:latest` pinned by digest (`sha256:7a3b00067ae17a7c8792f184a91542ed20218d690e65b370444d8a43ac3acf88`), which we replace with a pinned commit.
- Upstream has no releases, so the version is a commit SHA. UNVERIFIED: whether the shared Renovate setup bumps it from this `git-refs` comment (same style as `apps/tvheadend`).
- The nginx base's config seeding behavior is assumed from `apps/nginx` and `apps/it-tools` sources; check on first run.
- No blockers (static files, arch independent).

## 11. Build and test steps

```sh
cd apps/newyearcountdownclock
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name newyearcountdownclock-probe --read-only --tmpfs /tmp \
  -v newyearcountdownclock-probe-config:/config newyearcountdownclock:<sha>
docker logs -f newyearcountdownclock-probe
docker exec newyearcountdownclock-probe ls /config /config/sites
# from outside the container: curl -fsS http://<container-ip>:8080/healthz && curl -fsS http://<container-ip>:8080/ | head
forgetool containers test --image newyearcountdownclock:<sha> --config ./apps/newyearcountdownclock/container-test.yaml
docker rm -f newyearcountdownclock-probe; docker volume rm newyearcountdownclock-probe-config
```

Readiness: entrypoint prints the copyconfig lines and "Executing" for the nginx command; nginx starts without `[emerg]`, container stays up, `/healthz` returns 200. Restart on the same volume to confirm idempotency.

## 12. PR checklist

- Branch `feat/add-newyearcountdownclock`, commit/PR title `feat(newyearcountdownclock): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes; check only applicable boxes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Confirm VERSION alignment, `bake --print`, `USER apps`, license shipped, 8080 probed.
- Untested at planning time: docker build, arm64, config seeding by the base scripts, CSP behavior in a browser.
