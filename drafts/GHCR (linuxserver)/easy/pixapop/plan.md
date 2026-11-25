# pixapop — implementation plan
> Source: ./draft.md · Target: apps/pixapop/ · Difficulty: blocked (draft says easy; upstream contradicts it) · Role (main/sidecar): main · Verified on 2026-11-25

Blocker: the draft assumes a static JavaScript gallery served by nginx. The upstream linuxserver Dockerfile shows a PHP 7 + Composer + Yarn application with ImageMagick, built on Alpine. Do not port as an nginx static site. Recommended action: hold this draft until the upstream app's runtime is confirmed (PHP version, whether it needs a PHP-FPM process, and whether the repo `bierdok/pixapop` still exists).

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable version | UNVERIFIED: `gh api repos/bierdok/pixapop/releases/latest` and `/tags` returned 404 (repo not found by the GitHub API) | GitHub API |
| Draft container tag | `ghcr.io/linuxserver/pixapop:v1.2-ls15` | draft.md |
| Upstream Dockerfile | linuxserver/docker-pixapop@932504b80918: `FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.12`; installs ImageMagick and PHP 7 modules (curl, ctype, dom, exif, iconv, imagick, intl, phar); Composer; `composer install`, `yarn install`, `yarn build` in /var/www/html; `EXPOSE 80`; `VOLUME /config /photos`; `COPY root/ /`; no ENTRYPOINT/CMD | https://raw.githubusercontent.com/linuxserver/docker-pixapop/932504b80918/Dockerfile |
| Download | `https://github.com/bierdok/pixapop/archive/${PIXAPOP_RELEASE}.tar.gz`; `PIXAPOP_RELEASE` unpinned, falls back to the latest-release API | same |
| Renovate | UNVERIFIED (no pinned upstream version) | — |
| License | UNVERIFIED (repo not retrievable) | — |
| Per-arch | Source is architecture-neutral, but the PHP/ImageMagick runtime is per base image: UNVERIFIED for arm64 | — |
| Checksum | UNVERIFIED (none in Dockerfile) | — |
| Env vars | COMPOSER_ALLOW_SUPERUSER, COMPOSER_HOME, APP_ENV=prod (build-time) | Dockerfile |

## 2. Target layout

Cannot be decided until the runtime is confirmed. If the app is a PHP site, `apps/pixapop/` would need: `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`, and probably `etc/` for nginx and PHP-FPM config (reason: PHP needs a process manager). No `root/`.

## 3. Base image

- Draft: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`, alternative `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Neither is verified to provide PHP 7. PHP 7 is EOL and is not in ubuntu 26.04 apt (UNVERIFIED for this base). Likely needs a PHP 8.x port of the app, which is a code change upstream of ContainerForge.
- Closest sibling: `apps/it-tools` or `apps/theme-park` (nginx static) for static parts only.

## 4. Dockerfile

Not writable yet. Expected shape if PHP 8.x runs on the ubuntu base:
1. `ARG VERSION`, `USER root`, apt install php-fpm, php modules (imagemagick, gd, intl, exif, curl), composer, nginx (if the nginx base is not used).
2. Download the release tarball, verify it against a checksum if upstream publishes one (none found).
3. `composer install --no-dev`, `yarn build` in a build stage, then copy only the built output into `/app`.
4. `COPY --chmod=0755 . /`, `USER apps`, `EXPOSE 80`, `VOLUME /config /photos`.
Caches (composer, yarn) go to `/tmp`.

## 5. docker-bake.hcl

- `APP = "pixapop"`, `VERSION` with a renovate annotation once a tag is confirmed (UNVERIFIED).
- `LICENSE` and `SOURCE = "https://github.com/bierdok/pixapop"` (source URL UNVERIFIED: the GitHub API returned 404; the draft's link is a user profile `https://github.com/bierdok`).
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url` (UNVERIFIED).
- `ports`: 80 http (required).
- `env`: none verified. Do not invent.
- `volumes`: `/config`, `/photos` (per upstream VOLUME).
- `dependencies`: none.

## 7. start.sh

- Idempotent. Seed config into `/config` only when missing.
- Photos path `/photos` is read-only for the gallery; thumbnails/cache to `/tmp` or `/config/cache` (UNVERIFIED: the upstream write paths were not confirmed).
- Start PHP-FPM and nginx (or the single server), bind `0.0.0.0:80`, `exec` the final process.

## 8. container-test.yaml

- forgetool header from a sibling nginx app.
- `http` probe on 80; `timeoutSeconds` from `apps/it-tools` or similar.
- Cannot write the functional probe until the runtime is confirmed.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (UID 568). Nginx needs a `/tmp` for temp and pid files, and PHP sessions/cache need `/tmp`.
- Upstream writes: uploads/thumbnail cache paths UNVERIFIED. Draft's read-only expectation "possible" is not confirmed; the PHP app likely writes.
- Draft's non-root "possible" is contradicted by the chart's `runAsUser 0` for the linuxserver image; the ContainerForge version must run as `apps`.

## 10. Risks, caveats and open questions

- PHP 7 runtime (EOL) vs the ContainerForge bases (no PHP 7). Largest blocker.
- Upstream repo `bierdok/pixapop` returned 404 via the GitHub API; the release and license cannot be verified.
- Draft's amd64/arm64 "yes*" is unconfirmed. ImageMagick and PHP extensions must exist for arm64.
- The gallery only shows photos placed in `/photos` (draft caveat, not verified).
- Confidence in the draft is low; the "static" premise is wrong per the upstream Dockerfile.

## 11. Build and test steps

Not run. When unblocked:
1. `cd apps/pixapop && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name pixapop-probe --read-only --tmpfs /tmp -v pixapop-probe-config:/config pixapop:<version>`; expect nginx and PHP-FPM listening on 80.
4. Cleanup, then `forgetool containers test --image pixapop:<version> --config ./apps/pixapop/container-test.yaml`.

## 12. PR checklist

- Do not open a PR until the blocker is resolved.
- When opened: branch `feat/add-pixapop`, commit `feat(pixapop): add new container`, PR template at `.github/PULL_REQUEST_TEMPLATE.md`.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what was not tested (no build was run, upstream runtime unverified).
