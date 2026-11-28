# sinusbot — implementation plan
> Source: ./draft.md · Target: apps/sinusbot/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | SinusBot 1.1f (tarball `sinusbot-1.1f-amd64.tar.bz2`) | https://raw.githubusercontent.com/gamer92000/sinusbot-docker/966f042fce2ab6a93c7fa50e39aff335ebd81e9a/Dockerfile (label), install.sh via gh api |
| Release date | UNVERIFIED: no vendor release page or date fetched | — |
| Upstream image | `ghcr.io/gamer92000/sinusbot-docker:latest`, built from commit 966f042 | draft.md |
| Renovate | UNVERIFIED: no datasource fits a closed vendor tarball; GitHub releases API returns 404 on the source repo | gh api repos/gamer92000/sinusbot-docker/releases/latest |
| License | UNVERIFIED: no SPDX id for the closed-source bot. Vendor FAQ: Linux version needs no license since v1.0.1, but "a valid license for Teamspeak / a valid hosting provider" is required | https://sinusbot.github.io/docs/faq/general |
| Binary amd64 | https://michael.frie.se/sinusbot-1.1f-amd64.tar.bz2 (URL from install.sh) | https://api.github.com/repos/gamer92000/sinusbot-docker/contents/install.sh?ref=966f042fce2ab6a93c7fa50e39aff335ebd81e9a |
| Checksum | UNVERIFIED: none published or fetched | — |
| arm64 | none: vendor ships amd64 only; FAQ says no ARM TS client | https://sinusbot.github.io/docs/faq/general |
| Upstream Dockerfile | `FROM debian:bookworm-slim`; apt (curl, python3, jq, Xvfb, x11vnc, X11/audio/graphics libs); en_US.UTF-8 locale; WORKDIR /opt/sinusbot; install.sh per component (sinusbot, yt-dlp, deno, text-to-speech, teamspeak); ENTRYPOINT entrypoint.sh; no USER (root); VOLUME data and scripts; EXPOSE 8087; HEALTHCHECK curl /api/v1/botId | https://raw.githubusercontent.com/gamer92000/sinusbot-docker/966f042fce2ab6a93c7fa50e39aff335ebd81e9a/Dockerfile |
| Upstream entrypoint | chown -R on the app dir, drops to UID/GID via setpriv (0 becomes 9987), links config.ini to data/config.ini, runs `yt-dlp -U` at start, optional `OVERRIDE_PASSWORD` | gh api contents entrypoint.sh at 966f042 |
| Env vars | LC_ALL, LANG, LANGUAGE (Dockerfile); UID, GID, OVERRIDE_PASSWORD (entrypoint.sh) | as above |
| Ports | 8087/tcp http (EXPOSE and HEALTHCHECK). 9987/udp and 10101/tcp are UNVERIFIED and are not listed | Dockerfile |
| Other components | TeamSpeak client, x86_64 only, from teamspeak.com client.json; yt-dlp; deno x86_64 zip. All UNVERIFIED for this plan | install.sh |

Upstream Dockerfile reviewed: yes. Checksum source: none.

## 2. Target layout

- `apps/sinusbot/Dockerfile`
- `apps/sinusbot/docker-bake.hcl`
- `apps/sinusbot/settings.yaml`
- `apps/sinusbot/container-test.yaml`
- `apps/sinusbot/start.sh`
- `apps/sinusbot/defaults/` only if a default `config.ini` template is needed (reason: seed `/config` when missing)

Do not use `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a FROM base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`
- Why: generic Ubuntu userland, the vendor tarball is a glibc binary with its own Qt runtime. The draft agrees (no runtime image).
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 4. Dockerfile

1. `ARG VERSION=1.1f`, `ARG TARGETARCH`. Fail the build unless `TARGETARCH=amd64`, since arm64 is impossible.
2. `USER root` only for installs, then `USER apps` at the end.
3. apt: install only the runtime libraries not already in the base image. The draft's list is inferred (bzip2, libglib2.0-0, libnss3, libxcomposite1, libxdamage1, libxtst6, libxkbcommon0, libpulse0). Check each against the base, and pin versions as the Dockerfile rules require.
4. Download `https://michael.frie.se/sinusbot-${VERSION}-amd64.tar.bz2` with curl. Verify a checksum: none is published, so record an explicit `UNVERIFIED` note in the Dockerfile and in section 10.
5. Extract to `/app/sinusbot/` (binary and default scripts), keeping `/app` free of writable state. Ship the license text to `/usr/share/licenses/sinusbot/` if the tarball has one (UNVERIFIED).
6. ENV: move caches and HOME to `/tmp`; `LANG`/`LC_ALL` as upstream; `TMPDIR=/tmp`.
7. `COPY --chmod=0755 . /`
8. `EXPOSE 8087`, `VOLUME /config`, `USER apps`, `ENTRYPOINT ["/start.sh"]`.

Not included (see section 9): the TeamSpeak client install, TTS install, and the Xvfb/x11vnc stack. They are open questions.

## 5. docker-bake.hcl

- `APP = "sinusbot"`, `SOURCE = "https://github.com/gamer92000/sinusbot-docker"`, `LICENSE = "UNVERIFIED"` until the vendor license is confirmed. The bake file must match the real license.
- `variable "VERSION"` default `"1.1f"`, with a renovate comment. The datasource is UNVERIFIED: no standard datasource fits a vendor tarball. Use the datasource the repo already uses for non-GitHub downloads, if one exists, and check `apps/` for a sibling example first.
- Four standard targets (`docker-metadata-action`, `image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }`. `image-all` would fail for arm64 by design, so mark it amd64 only and say so.
- Validate with `docker buildx bake --print` from `apps/sinusbot`.

## 6. settings.yaml

- Schema header and `schema_version: 1`, `upstream_env_url: https://github.com/gamer92000/sinusbot-docker`.
- `ports`: 8087/tcp, http, `required: true`. No other ports until confirmed.
- `env`: `OVERRIDE_PASSWORD` (default empty, not required), as read by the upstream entrypoint. `UID`/`GID` are not listed: the new start.sh does not read them (no `setpriv`; `UID` is also a read-only shell variable). Defaults must match the new start.sh.
- `volumes`: `/config` (persistent data and config).
- `dependencies`: none.

## 7. start.sh

- Idempotent. Seed `/config/config.ini` from a template only when missing. Never overwrite it.
- Create `/config/data` and `/config/scripts` on first start, then link them into the app directory so `/app` stays read-only. Create the symlinks at build time where the target is inside `/config`, or handle them in start.sh using `/tmp` for runtime-only paths.
- Do not run `yt-dlp -U` at start (it writes and needs network). Keep the yt-dlp path as a fixed location if the bot needs it. Mark yt-dlp as an open question.
- Do not use `setpriv` or `chown -R`. The container already runs as `apps`.
- If `OVERRIDE_PASSWORD` is set, pass it to the binary on start, as upstream does. Keep it out of logs.
- Bind the web UI to `0.0.0.0` (check the bot's `config.ini` `ListenAddress`/`Port` options at runtime; UNVERIFIED).
- End with `exec` on the sinusbot binary so signals reach it.

## 8. container-test.yaml

- forgetool schema header from a sibling app.
- `tcp` probe on 8087. `http` probe on `/api/v1/botId` (the upstream healthcheck path) on 8087. Accept a 200 response; check the sibling for the expected status convention.
- `filePaths`: `/config/config.ini` (created on first start), `/app/sinusbot`.
- `timeoutSeconds`: copy the value from a sibling with a similar startup time. Set a longer value because the bot starts slowly (UNVERIFIED).
- Tests run with no env vars, so the `OVERRIDE_PASSWORD` path is not covered. Note that in a comment and run it by hand.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/sinusbot/data` (VOLUME) | `/config/data` (persistent), linked into the app directory |
| `/opt/sinusbot/scripts` (VOLUME) | `/config/scripts`, seeded from defaults on first start |
| `config.ini` (symlink to data) | `/config/config.ini`, seeded when missing |
| yt-dlp self-update and cache | `/tmp` or disabled; UNVERIFIED whether the bot needs yt-dlp at all |
| chown of the app directory | removed |
| setpriv drop to UID/GID | removed; the process runs as `apps` |
| root user | `apps` (fixed; no UID/GID env) |

Draft security expectations to reconcile: upstream runAsUser 0, readOnlyRootFilesystem false, no privileged. The target is rootless and read-only, so the chart's expectations are not applied.

## 10. Risks, caveats and open questions

- Blocker: closed-source vendor tarball, amd64 only. arm64 is not possible.
- Blocker: license. The Linux version needs a TeamSpeak license or a valid hosting provider (FAQ). Confirm before publishing.
- UNVERIFIED: ports 9987/udp and 10101/tcp, the checksum, the renovate datasource, and the release date.
- The TeamSpeak client, TTS and Xvfb stack are not in this plan. A bot that needs a TeamSpeak client cannot be fully tested without a TeamSpeak server. Test only the web API on 8087.
- Upstream runs as root with setpriv. Porting to `apps` may break the bot's own file writes; confirm during step 11.
- Draft caveats (inferred): a TeamSpeak server must be reachable for the bot to connect; the full feature set needs a license.

## 11. Build and test steps

1. `cd apps/sinusbot && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name sinusbot-probe --read-only --tmpfs /tmp -v sinusbot-probe-config:/config ghcr.io/trueforge-org/sinusbot:1.1f` (use the local tag from `image-local`)
4. `docker logs -f sinusbot-probe` until idle. Expected signal: the web API answers on 8087 and the process stays up. The exact readiness line is UNVERIFIED; confirm it on the first run.
5. `forgetool containers test --image <image>:1.1f --config ./apps/sinusbot/container-test.yaml`
6. Clean up: `docker rm -f sinusbot-probe; docker volume rm sinusbot-probe-config`.

## 12. PR checklist

- Branch `feat/add-sinusbot`, commit `feat(sinusbot): add new container`, target `main`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: TeamSpeak connection, license, arm64 (not applicable), the OVERRIDE_PASSWORD path, and any UNVERIFIED items above.
