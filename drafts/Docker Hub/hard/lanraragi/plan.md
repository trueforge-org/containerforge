# lanraragi — implementation plan
> Source: ./draft.md · Target: apps/lanraragi/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 0.9.82 (GitHub tag `v.0.9.82`, "Born In a UFO", released 07 Nov). Draft tag `v.0.9.41` is outdated. |
| Renovate | `datasource=github-releases depName=Difegue/LANraragi versioning=loose extractVersion=^v\.(?<version>.+)$` (tags have a dot after `v`). |
| License | MIT. UNVERIFIED: the repo page was not fetched for the license; confirm in LICENSE before writing `LICENSE`. |
| Source | https://github.com/Difegue/LANraragi |
| Downloads | Source tarball only: `https://github.com/Difegue/LANraragi/archive/refs/tags/v.${VERSION}.tar.gz` (release assets are only `LANraragi.msi` plus source archives). Architecture-independent (Perl/Node); native pieces built with CPAN/npm per arch. |
| Checksum | None published. Record the sha256 of the tarball in the Dockerfile and update it with Renovate bumps (open question). |
| Upstream Dockerfile | https://github.com/Difegue/LANraragi/blob/dev/tools/build/docker/Dockerfile reviewed. Alpine 3.24 base, user `koyomi` 9001, s6-overlay (`ENTRYPOINT //init`). Apt-equivalent packages: tzdata valkey valkey-cli perl perl-io-socket-ssl perl-local-lib libffi vips (+jxl, heif, poppler) shadow procps-ng; build adds g++ make nodejs npm perl-dev libarchive-dev libffi-dev. Perl deps from `cpanfile`, frontend via `npm`. Env: LRR_UID=9001, LRR_GID=9001, LRR_NETWORK=http://*:3000, MOJO_PROXY=1, MOJO_REVERSE_PROXY=1, LRR_AUTOFIX_PERMISSIONS=1, S6_*. Port 3000. Volumes: `content`, `thumb`, `database`, `lib/LANraragi/Plugin/Sideloaded`, `lib/LANraragi/Plugin/Managed` under `/home/koyomi/lanraragi`. Healthcheck `wget --spider http://127.0.0.1:3000`. Upstream now bundles Valkey, not Redis. |

## 2. Target layout
- `Dockerfile` (multi-stage: build with CPAN/npm, runtime copies result)
- `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- `defaults/lrr.conf` only if the upstream `lrr.conf` and `redis.conf` need modification; otherwise copy from the tarball at build time.
- No `root/` (upstream s6 service tree is not ported). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
Perl has no ContainerForge base; the draft's `python-node` alternative is not needed since Node is only a build tool, so use ubuntu with `nodejs npm` in the build stage only. Closest siblings: `apps/bookstack` (build-from-source app stack), `apps/valkey` (valkey packages).

## 4. Dockerfile
1. Build stage (ubuntu): `ARG VERSION`; apt `build-essential perl cpanminus libffi-dev libarchive-dev libssl-dev nodejs npm curl ca-certificates libvips-dev`; download the tarball, verify sha256, extract to `/build/lanraragi`.
2. `cpanm --notest --installdeps . -l /build/lanraragi/local` (UNVERIFIED install command; upstream uses `cpanfile` + `local::lib`); `npm ci --omit=dev` / `npm install` for frontend per upstream `package.json`; strip `.map` files. Caches: `npm_config_cache=/tmp/npm`, `PERL_CPANM_HOME=/tmp/cpanm`.
3. Final stage: `USER root`; apt runtime packages `perl libvips42t64`-style runtime libs (exact 26.04 names UNVERIFIED), `libarchive13t64`, `libffi8`, `imagemagick` not needed (upstream uses vips), `valkey-server=<PACKAGE_VERSION>` (pin and check against base, as `apps/valkey/Dockerfile`), `ghostscript` and `poppler-utils` for PDFs (upstream uses poppler; UNVERIFIED).
4. `COPY --from=build /build/lanraragi /app/lanraragi`; `chown -R apps:apps /app`.
5. Licenses to `/usr/share/licenses/lanraragi/`.
6. `ENV LRR_NETWORK=http://*:3000 MOJO_PROXY=1 MOJO_REVERSE_PROXY=1 HOME=/config` (+ data dir env if verified).
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl
APP `lanraragi`; VERSION `0.9.82` with the renovate comment from section 1; PACKAGE_VERSION for valkey if pinned; LICENSE `MIT` (verify); SOURCE `https://github.com/Difegue/LANraragi`. Standard targets: `docker-metadata-action`, `image` (args VERSION), `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64+arm64), default group. `docker buildx bake --print`.

## 6. settings.yaml
- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/Difegue/LANraragi"`.
- ports: 3000 tcp (required). Valkey on 6379 is bound to 127.0.0.1 only and not exposed, so it is not listed (settings must list only ports the container exposes).
- env: `LRR_NETWORK` (default `http://*:3000`), `MOJO_PROXY` (1), `MOJO_REVERSE_PROXY` (1), `TZ` (Etc/UTC). Data directory vars (`LRR_DATA_DIRECTORY`, `LRR_THUMB_DIRECTORY`, `LRR_TEMP_DIRECTORY`): UNVERIFIED, confirm in upstream docs before listing. Upstream `LRR_UID/GID/AUTOFIX_PERMISSIONS` are s6-only: omit.
- volumes: `/config` (required, holds content, thumb, database, plugins).
- dependencies: none (Valkey runs in-container; `valkey` ✅ exists as a separate image but upstream expects localhost).

## 7. start.sh
- `mkdir -p /config/{content,thumb,database,plugins/Sideloaded,plugins/Managed} /tmp/lrr`.
- Start Valkey: `valkey-server --bind 127.0.0.1 --port 6379 --dir /config/database --daemonize no &` (use upstream `redis.conf` as base), wait for `valkey-cli ping` = PONG. UNVERIFIED: upstream's redis.conf contents and the lrr.conf/redis address the app expects.
- Link or configure the app to use `/config/content` and `/config/thumb` (symlinks inside `/app` are not possible because /app is read-only; use env vars or config set in `/config`). UNVERIFIED how upstream selects directories; may need `lrr.conf` override.
- Forward signals: trap TERM to stop Valkey, or `wait -n`.
- `exec perl ./script/launcher.pl -d ./script/lanraragi` style launch (UNVERIFIED: read upstream `tools/build/docker/s6/.../run` scripts).

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/lanraragi/package.json
- /app/lanraragi/lib/LANraragi.pm
healthCommands:
- command: valkey-cli -h 127.0.0.1 ping
  expectedContent: PONG
  matchContent: true
```
UNVERIFIED: `expectedContent`/`matchContent` keys (no sibling uses them; check the forgetool schema). Timeout 180 is an estimate (UNVERIFIED as a schema default) (Perl startup plus Valkey).

## 9. Rootless and read-only-rootfs adaptations
- Upstream runs s6 as root then drops to `koyomi` (9001). Ours is `USER apps`; remove s6, `LRR_UID/GID`, permission autofix.
- Write paths upstream: `content/`, `thumb/`, `database/` (Valkey dump), plugin dirs, `temp/` (inside the app dir), `lrr.conf`. Remap: content/thumb/database/plugins to `/config`; temp to `/tmp/lrr`. UNVERIFIED which env/config sets these.
- Draft: root, writable rootfs, extra persistence `database` and `content`: reconciled to `/config/database` and `/config/content` (single volume).

## 10. Risks, caveats and open questions
- Multiple processes (app and Valkey) in one container; health depends on both.
- Source build via CPAN needs a toolchain and may be slow, and arm64 build time is untested.
- Upstream moved from Alpine/musl to its own image; porting to glibc Ubuntu may change CPAN module behavior (ImageMagick vs vips; Image::Magick may not be needed now).
- App-dir writes (temp, logs, plugin installs) must be redirected away from the read-only `/app`; this is the main unknown.
- Version tag has a leading `v.`, needing `extractVersion`.
- No published checksum.

## 11. Build and test steps
```sh
cd apps/lanraragi
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create lanraragi-probe-config
docker run --rm -d --name lanraragi-probe --read-only --tmpfs /tmp \
  -v lanraragi-probe-config:/config lanraragi:0.9.82
docker logs -f lanraragi-probe
forgetool containers test --image lanraragi:0.9.82 --config ./apps/lanraragi/container-test.yaml
docker rm -f lanraragi-probe; docker volume rm lanraragi-probe-config
```
Expected readiness: Mojolicious "Listening at http://*:3000" style line (UNVERIFIED exact text), UI answers on 3000.

## 12. PR checklist
- Branch `feat/add-lanraragi`; commit `feat(lanraragi): add new container`; target `main`; PR template filled; Notes include `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at planning time: build, Perl/CPAN install, startup, read-only rootfs, arm64, the Valkey wiring.
- Pre-completion: bake --print, version alignment, USER apps, empty /config; no DOWNSTREAM_CHANGES.md.
