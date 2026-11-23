# newyearcountdownclock — implementation plan
> Source: ./draft.md · Target: apps/newyearcountdownclock/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags upstream (README lists only `latest`). Pin the draft's commit `a1c6bede2351d2912dcd25e7d15e30f82be6b12f`. Whether it is still master HEAD is UNVERIFIED (134 commits on master; the last-commit date was not shown). Re-check HEAD at implementation time. |
| Renovate | `datasource=git-refs depName=https://github.com/modem7/Docker-NewYearCountdown currentValue=master` |
| License | MIT (LICENSE in repo root). The countdown code is credited to patrickgold/newyear-countdown; its license is UNVERIFIED, check before shipping. SPDX `MIT`. |
| Source URL | https://github.com/modem7/Docker-NewYearCountdown |
| Download | `https://github.com/modem7/Docker-NewYearCountdown/archive/<sha>.tar.gz` (source archive; static files, arch-independent) |
| Checksum source | None; commit SHA pin only. |
| Layout | `src/` (`index.html`, `countdown.html`, `countdown.js`, `countdown.css`, `countdown.scss`, `favicon.svg`), `conf/nginx-site.conf`, `Dockerfile`, `LICENSE`, `README.md`. |
| Upstream Dockerfile | `nginxinc/nginx-unprivileged` alpine, copies `src/` to `/usr/share/nginx/html/`, `conf/nginx-site.conf` to `/etc/nginx/conf.d/default.conf`, EXPOSE 8080, healthcheck `curl 127.0.0.1:8080/healthz`, runs as UID 101. |
| nginx-site.conf | listen 8080, `/healthz` returns 200, `try_files`, static asset `expires 5d`, 404 -> `/index.html`, security headers (nosniff, X-Frame-Options DENY, no-referrer, CSP same-origin with inline script/style), gzip level 6. |
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
  docker-entrypoint.d/10-copyconfig.sh   # only if the base's 03 script does not already seed it (see section 7)
```

No `start.sh`: the nginx base runs `nginx -c /config/nginx.conf` through the ubuntu entrypoint (same as `apps/it-tools`, which has no start.sh). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`

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
3. `COPY --chmod=0755 . /` (brings `defaults/` and `docker-entrypoint.d/` from the allow-list).
4. `USER apps`; `COPY --chmod=0755 . /` as the final directive pair; `WORKDIR /usr/share/nginx/html` (like it-tools).
5. `EXPOSE 8080` is inherited from the base; repeat for clarity. `VOLUME /config`.
6. No `CMD`: inherit the base `CMD ["nginx","-c","/config/nginx.conf","-g","daemon off;"]`.

## 5. docker-bake.hcl

`APP=newyearcountdownclock`; `VERSION` default `"a1c6bede2351d2912dcd25e7d15e30f82be6b12f"` (update if HEAD moved) preceded by `// renovate: datasource=git-refs depName=https://github.com/modem7/Docker-NewYearCountdown currentValue=master`; `LICENSE="MIT"`; `SOURCE="https://github.com/modem7/Docker-NewYearCountdown"`. Four standard targets plus `group "default"` per `apps/it-tools/docker-bake.hcl`. Validate with `docker buildx bake --print`.

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

Not applicable: no `start.sh` is shipped (nginx base entrypoint, see `apps/it-tools`). Config seeding is handled by the `docker-entrypoint.d` scripts, which must stay idempotent:

`defaults/default.conf` (own file, content adapted from upstream `conf/nginx-site.conf`, verified behaviors only):

```nginx
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    server_name _;
    root /usr/share/nginx/html;

    location = /healthz { access_log off; return 200; }
    location / { try_files $uri $uri/ /index.html; }
    # plus the upstream gzip block, `expires 5d` asset location and security headers
}
```

Because the base's `03-copyconfig.sh` does `cp -n /defaults/default.conf /config/sites/default.conf` and our `COPY . /` overrides `/defaults/default.conf`, the file is seeded only when missing. Verify this in round 1; if the base script does not run first, add `docker-entrypoint.d/10-copyconfig.sh` doing `mkdir -p /config/sites && cp -n /defaults/default.conf /config/sites/default.conf` (use `cp -n`, unlike it-tools which overwrites on every start). Copy the full upstream header values (CSP etc.) from `conf/nginx-site.conf` at the pinned commit rather than from this summary.

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
- /usr/share/nginx/html/countdown.js
```

Port 8080 is the only port in settings.yaml and has an HTTP probe. Timeout: nginx siblings set none. Test runs without env; nothing needs env.

## 9. Rootless and read-only-rootfs adaptations

- nginx writes: pid `/tmp/nginx.pid`, temp and cache dirs under `/tmp` (set in the base's `/config/nginx.conf`), logs to stdout/stderr. Site content in `/usr/share/nginx/html` is read-only at runtime.
- Draft says chart runs as UID 0 with writable rootfs: not needed. Run as `apps` (568), port 8080 (unprivileged), read-only rootfs OK. No extra persistence.
- Upstream CSP/headers keep working; confirm that the page needs no external hosts (UNVERIFIED), otherwise adjust CSP.

## 10. Risks, caveats and open questions

- Draft caveats: the countdown uses the visitor's browser timezone; the chart pulled `:latest`, which we replace with a pinned commit.
- Upstream has no releases, so the version is a commit SHA that renovate will bump; confirm the draft commit is HEAD.
- The nginx base's config seeding behavior is assumed from `apps/nginx` and `apps/it-tools` sources; check on first run.
- Third-party license of the original countdown (patrickgold/newyear-countdown) UNVERIFIED.
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
- Untested at planning time: docker build, arm64, config seeding by the base scripts, CSP behavior in a browser, current upstream HEAD.
