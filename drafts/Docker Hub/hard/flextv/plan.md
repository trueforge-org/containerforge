# flextv — implementation plan
> Source: ./draft.md · Target: apps/flextv/ · Difficulty: hard · Role: main · Verified on 2026-11-23 (partially: GitHub API returned 403, so only HTML pages were readable)

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | UNVERIFIED: https://github.com/d8ahazard/FlexTV shows an empty Releases section and no tags. Pin a commit SHA of the default branch instead (pick it at implementation time). |
| Renovate | `datasource=git-refs depName=d8ahazard/FlexTV packageName=https://github.com/d8ahazard/FlexTV` with `currentDigest=<sha>`, same style as `apps/kasmvnc` (`kasmtech/noVNC`). |
| License | UNVERIFIED: the README states none. The repo root lists `license.txt` and `gpl.txt`, which suggests GPL (version unknown). Read `license.txt` before setting `LICENSE`. |
| Source URL | https://github.com/d8ahazard/FlexTV |
| Language | **PHP, not Python.** The root has `index.php`, `api.php`, `log.php`, `PHPTail.php`, `composer.phar`, `php/`, `js/`, `css/`, `rw/`. The draft's Python/pip assumption is wrong and `python` must not be the base. |
| Per-arch download | Source tarball only (arch independent): `https://github.com/d8ahazard/FlexTV/archive/<sha>.tar.gz`. amd64 and arm64 both work for PHP code. |
| Checksum source | None published. Pin by commit SHA (git content addressed). |
| Port / config path / env vars | UNVERIFIED: the README and wiki (self-described as outdated) give none. 7979 in the draft is an inference. Do not invent env vars. |
| Upstream Dockerfile | None. Docker Hub `jcreynolds/flextv` has an empty description and was last updated 2019-05-17, so it is abandoned and cannot be inspected. The README says the branch is "beta development" and points users to the hosted app.phlexchat.com. |

Verdict: this app is unmaintained, undocumented for self-hosting, and the version/port/config location cannot be verified. Treat implementation as low confidence and do a spike (run the PHP files under php-fpm and read `rw/` writes) before committing to the PR.

## 2. Target layout

```
apps/flextv/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/default.conf     # nginx server block fronting php-fpm (reason: nginx is not provided by ubuntu base)
```
No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: PHP app, and there is no PHP base image in the repo, so use ubuntu plus apt `php8.5-fpm` and `nginx`, as `apps/bookstack` and `apps/phpmyadmin` do. Closest siblings: `apps/phpmyadmin` (PHP fed by a pinned download), `apps/bookstack`. Risk: a 2019-era codebase may break on PHP 8.5 (UNVERIFIED); if the spike fails, the app is a blocker.

## 4. Dockerfile

1. `ARG VERSION` (the commit SHA), `ARG TARGETARCH` (unused, PHP is arch independent; omit if unused).
2. `USER root`.
3. `apt-get install -y --no-install-recommends nginx php8.5-fpm php8.5-cli php8.5-curl php8.5-xml php8.5-mbstring php8.5-zip php8.5-gd` (extension list is a guess, trim after the spike; check against `grep extension` in the PHP source). `curl` is already in the base (bookstack uses it without installing). Pin `nginx=` the way `apps/nginx` does only if the image claims an nginx version; here the image version is the FlexTV commit, so apt packages are not version-pinned.
4. Configure php-fpm to pass env vars and to run as `apps` with a socket in `/tmp`: copy the `clear_env = no` sed from `apps/phpmyadmin/Dockerfile`; set `listen = /tmp/php-fpm.sock`, `pid = /tmp/php-fpm.pid`, `error_log = /dev/stderr`, drop `user/group` directives (non-root run).
5. Download: `curl -fL https://github.com/d8ahazard/FlexTV/archive/${VERSION}.tar.gz | tar xz -C /app/www --strip-components=1`.
6. Remap writable dirs to /config: remove `/app/www/rw`, `/app/www/log`, `/app/www/logs` (names from the repo listing) and symlink them to `/config/rw`, `/config/log`, `/config/logs`.
7. License: `mkdir -p /usr/share/licenses/flextv && cp /app/www/license.txt /app/www/gpl.txt /usr/share/licenses/flextv/`.
8. `ENV HOME=/config TMPDIR=/tmp`.
9. Cleanup `rm -rf /tmp/* /var/lib/apt/lists/*`.
10. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080` (non-root cannot bind 80; the draft's 7979 is not verified, so choose nginx 8080), `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP` = `flextv`
- `VERSION`: `// renovate: datasource=git-refs depName=d8ahazard/FlexTV packageName=https://github.com/d8ahazard/FlexTV currentDigest=<sha>` then `default = "<sha>"`.
- `LICENSE`: UNVERIFIED (likely `GPL-3.0-only` or `GPL-2.0-only`, confirm from `license.txt`).
- `SOURCE` = `https://github.com/d8ahazard/FlexTV`
- Targets: `docker-metadata-action`, `image` (args VERSION, labels source/licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default" { targets = ["image-local"] }`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`, `upstream_env_url: "https://github.com/d8ahazard/FlexTV"`.
- ports: `8080/tcp required: false`.
- env: `TZ` default `Etc/UTC`, required false. No other vars: upstream documents none.
- volumes: `/config` required true.
- dependencies: none (a Plex server is external, not a ContainerForge app).

## 7. start.sh

1. `mkdir -p /config/rw /config/log /config/logs /tmp/nginx-temp`.
2. Seed `/config/nginx.conf` and `/config/sites/default.conf` from `/defaults` with `cp -n` (same as `apps/nginx/docker-entrypoint.d/03-copyconfig.sh`) or, simpler, generate a nginx config in `/tmp` each start; keep it under `/tmp` so `/config` stays user-owned only for FlexTV data.
3. `php-fpm8.5 --nodaemonize --fpm-config /tmp/php-fpm.conf &`.
4. `exec nginx -c /config/nginx.conf -g 'daemon off;'` listening `0.0.0.0:8080`, `root /app/www`, `fastcgi_pass unix:/tmp/php-fpm.sock`, temp paths in `/tmp` (copy from `apps/nginx/defaults/nginx.conf`).
Idempotent, never writes to /app.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120   # copy value from apps/bookstack-style PHP sibling after the first run
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/www/index.php
```
Keep the `http` probe on `/` only if `index.php` answers 200 without a Plex token (UNVERIFIED); otherwise drop it and keep the `tcp` probe on 8080 (every settings.yaml port needs a probe).

## 9. Rootless and read-only-rootfs adaptations

- Draft says runs as root (UID 0) and `readOnlyRootFilesystem: false`. Target: `USER apps`, read-only rootfs.
- Upstream write paths (UNVERIFIED, from the repo folder names): `rw/`, `log/`, `logs/`, plus whatever `index.php` writes at runtime. Symlinked into `/config` at build time. Verify with `docker run --read-only` and watch for PHP warnings.
- php-fpm socket, pid, nginx temp, sessions (`session.save_path=/tmp`) go to `/tmp`. `composer.phar` is not run at runtime (vendored dependencies must be installed at build time with `composer install --no-dev`, if a `composer.json` exists; UNVERIFIED because none appears in the root listing).
- No extra persistence beyond `/config`, as the draft says.

## 10. Risks, caveats and open questions

- Draft wrongly assumes Python; the code is PHP. Update the draft's base to ubuntu + php-fpm.
- Abandoned project (Docker Hub image 2019, "beta development" branch), no releases, no license statement in the README. Possible blocker: legal clarity and PHP 8.5 compatibility.
- Needs a Plex server and token (draft inference, plausible). Port and URL are unknown.
- No arm64 issue (pure PHP).
- Open: exact PHP extensions, listening port, config writes. Resolve with a spike before opening a PR.

## 11. Build and test steps

```sh
cd apps/flextv
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create flextv-probe-config
docker run --rm -d --name flextv-probe --read-only --tmpfs /tmp -v flextv-probe-config:/config flextv:<sha>
docker logs -f flextv-probe        # expect nginx started and no php-fpm fatal; port 8080 open
forgetool containers test --image flextv:<sha> --config ./apps/flextv/container-test.yaml
docker rm -f flextv-probe; docker volume rm flextv-probe-config
```
Readiness signal: nginx worker processes up, php-fpm "ready to handle connections", `curl localhost:8080/` returns a response.

## 12. PR checklist

- Branch `feat/add-flextv`, commit `feat(flextv): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested items honestly: build, rootless run, PHP 8.5 compatibility, port, Plex connectivity, arm64.
- Do not check "Built container locally" unless it was done.
