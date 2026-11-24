# lancache-monolithic — implementation plan
> Source: ./draft.md · Target: apps/lancache-monolithic/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags upstream (master, 150 commits). Draft tag `latest`. Track by commit; UNVERIFIED current SHA. |
| Renovate | `datasource=git-refs depName=https://github.com/lancachenet/monolithic versioning=loose`. nginx itself comes from the base image `nginx:1.28.3`. |
| License | MIT (verified). nginx is BSD-2-Clause (from base). `LICENSE`: `MIT`. |
| Source | https://github.com/lancachenet/monolithic |
| Downloads | No binary. Upstream is a config overlay on `lancachenet/ubuntu-nginx`, plus git clone of https://github.com/uklans/cache-domains. Both architectures: nginx image is multi-arch; config is arch-independent. |
| Checksum | None published; pin git refs. |
| Upstream Dockerfile | https://github.com/lancachenet/monolithic/blob/master/Dockerfile reviewed. Apt: jq git ca-certificates. Env: GENERICCACHE_VERSION=2, CACHE_MODE=monolithic, WEBUSER=www-data, CACHE_INDEX_SIZE=500m, CACHE_DISK_SIZE=1000g, MIN_FREE_DISK=10g, CACHE_MAX_AGE=3560d, CACHE_SLICE_SIZE=1m, UPSTREAM_DNS="8.8.8.8 8.8.4.4", BEAT_TIME=1h, LOGFILE_RETENTION=3560, CACHE_DOMAINS_REPO, CACHE_DOMAINS_BRANCH=master, NGINX_WORKER_PROCESSES=auto, NGINX_LOG_FORMAT=cachelog. Ports 80 443 8080. Volumes /data/logs /data/cache /data/cachedomains /var/www. Healthcheck `curl http://127.0.0.1/lancache-heartbeat`. Docs list `CACHE_MEM_SIZE` (500m) instead of CACHE_INDEX_SIZE: naming differs between docs and Dockerfile, UNVERIFIED which the overlay reads. |
| Overlay (tree only) | `etc/nginx/nginx.conf`, `workers.conf`, `conf.d/*`, `sites-available/10_cache.conf 20_upstream.conf 30_metrics.conf` plus `cache.conf.d/`, `upstream.conf.d/`, `stream-available/10_sni.conf`, `etc/supervisor/conf.d/heartbeat.conf`, `hooks/*`, `scripts/{cache_test,getconfig,heartbeat}.sh`. Contents not read: UNVERIFIED. |

## 2. Target layout
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- `etc/nginx/...`: adapted copy of the upstream overlay (nginx.conf, conf.d, sites-available, stream-available). Reason: `etc/` is in the dockerignore allow-list.
- `scripts/`: heartbeat/getconfig helpers adapted from upstream (no supervisor).
- No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (draft names nginx as runtime; the overlay is nginx config). Closest siblings: `apps/nginx` base, `apps/it-tools`, `apps/theme-park`. UNVERIFIED: the base nginx has the modules the config needs (`slice`, `stream`, `stream_ssl_preread`, `realip`); check `nginx -V`. If missing, fall back to ubuntu + apt `nginx-full`, pinned.

## 4. Dockerfile
1. `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends jq git ca-certificates` only for those not in base (check).
3. `git clone --depth=1` cache-domains at pinned `CACHE_DOMAINS_REF` into `/app/cachedomains` (read-only in image).
4. Licenses to `/usr/share/licenses/lancache-monolithic/` (repo MIT, cache-domains license).
5. `ENV` defaults from section 6.
6. `setcap cap_net_bind_service=+ep` on the nginx binary only if keeping 80/443 (see section 9).
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 80 443 8080`, `VOLUME /config /data/cache /data/logs` (decide), `CMD ["/start.sh"]`.

## 5. docker-bake.hcl
APP `lancache-monolithic`; VERSION with renovate git-refs comment; LICENSE `MIT`; SOURCE `https://github.com/lancachenet/monolithic`; args VERSION (+ CACHE_DOMAINS_REF with its own renovate comment). Standard targets and `group "default"`. Validate `docker buildx bake --print`.

## 6. settings.yaml
- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/lancachenet/monolithic"`.
- ports: 80 tcp (cache HTTP, required), 443 tcp (SNI passthrough), 8080 tcp (metrics, upstream EXPOSE; UNVERIFIED what 30_metrics serves).
- env (defaults per upstream Dockerfile): `UPSTREAM_DNS` ("8.8.8.8 8.8.4.4"), `CACHE_INDEX_SIZE` (500m), `CACHE_DISK_SIZE` (1000g), `MIN_FREE_DISK` (10g), `CACHE_MAX_AGE` (3560d), `CACHE_SLICE_SIZE` (1m), `BEAT_TIME` (1h), `LOGFILE_RETENTION` (3560), `CACHE_DOMAINS_REPO`, `CACHE_DOMAINS_BRANCH` (master), `NGINX_WORKER_PROCESSES` (auto), `NGINX_LOG_FORMAT` (cachelog). Only list those start.sh/templates actually consume.
- volumes: `/config` (generated state), `/data/cache` and `/data/logs` (draft chart uses /data/cache, /data/logs, /data/prefill). `/data/prefill` is dropped: prefill image is out of scope.
- dependencies: none hard. Optional: lancache-dns (missing, planned as separate container), lancache-prefill ❌ (missing).

## 7. start.sh
- Idempotent; `mkdir -p /data/cache /data/logs /data/cachedomains /tmp/nginx` (cache dirs on mounted volumes or `/config`).
- Generate maps from cache-domains (port of upstream `15_generate_maps.sh`, `getconfig.sh`) into `/tmp/nginx/maps`; render nginx confs from env into `/tmp/nginx`.
- Reject a config where `/data/cache` is not writable with a clear error.
- Heartbeat: replace the supervisor `heartbeat.sh` with a background loop or drop it.
- `exec nginx -c /tmp/nginx/nginx.conf -g 'daemon off;'` with `pid /tmp/nginx/nginx.pid`, temp paths under `/tmp/nginx`, logs to stdout/stderr (or `/data/logs`).

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '80'
- port: '443'
- port: '8080'
http:
- port: '80'
  path: /lancache-heartbeat
  statusCode: 204   # UNVERIFIED: read 90_lancache_heartbeat.conf for the real status
filePaths:
- /app/cachedomains
- /tmp/nginx/nginx.conf   # only if generated at start; otherwise move the check to a runner
```
If the test harness reaches the container only after start, a `runners` entry `nginx -t -c /tmp/nginx/nginx.conf` is an alternative. Timeout 120 estimated from nginx siblings.

## 9. Rootless and read-only-rootfs adaptations
- Ports 80 and 443 are below 1024: either setcap on nginx (needs `NET_BIND_SERVICE`) or listen on 8080/8443 inside and map outside. Upstream metrics already use 8080, so internal HTTP/HTTPS defaults must be chosen (open question).
- Write paths upstream: `/data/cache`, `/data/info`, `/data/logs`, `/tmp/nginx`, `/var/log/tallylog`, `/etc/nginx/sites-enabled` symlinks (build time), `/data/cachedomains` (git clone at runtime). Remap config and temp to `/tmp/nginx`; cache and logs to volumes; cachedomains to image `/app` (read-only) with optional `/tmp` refresh.
- Upstream chowns to `www-data` and runs as root; ours runs `USER apps` (UID 568 assumed, check base), so mounted volumes must be writable by that user.
- Draft says root, writable rootfs, extra persistence /data/cache, /data/logs, /data/prefill: reconciled as above.

## 10. Risks, caveats and open questions
- `lancache-prefill` (ghcr.io/ich777/lancache-prefill, third-party) is a missing dependency and is excluded.
- Needs lancache-dns (not yet in repo) or other DNS redirect; clients cannot cache HTTPS (443 is passthrough only).
- Large disk needs (default 1000g) with no quota.
- Hooks and templates not read; porting `10_setup.sh`, `15_generate_maps.sh`, `20_perms_check.sh` needs care.
- Docs/Dockerfile disagree on `CACHE_MEM_SIZE` vs `CACHE_INDEX_SIZE`.
- Base nginx modules UNVERIFIED. Host ports 80/443 conflicts.

## 11. Build and test steps
```sh
cd apps/lancache-monolithic
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create lancache-monolithic-probe-config
docker run --rm -d --name lancache-monolithic-probe --read-only --tmpfs /tmp \
  -v lancache-monolithic-probe-config:/config \
  -v lancache-monolithic-probe-cache:/data/cache -v lancache-monolithic-probe-logs:/data/logs \
  lancache-monolithic:<VERSION>
docker logs -f lancache-monolithic-probe
forgetool containers test --image lancache-monolithic:<VERSION> --config ./apps/lancache-monolithic/container-test.yaml
docker rm -f lancache-monolithic-probe; docker volume rm lancache-monolithic-probe-config lancache-monolithic-probe-cache lancache-monolithic-probe-logs
```
Expected readiness: no `nginx: [emerg]`, heartbeat URL answers, ports 80/443 (or chosen) open.

## 12. PR checklist
- Branch `feat/add-lancache-monolithic`; commit `feat(lancache-monolithic): add new container`; target `main`; template filled; Notes include `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at planning time: build, nginx module availability, non-root bind on 80/443, caching behavior, arm64.
- Pre-completion: bake --print, USER apps, empty /config, version alignment; no DOWNSTREAM_CHANGES.md.
