# minetest — implementation plan
> Source: ./draft.md · Target: apps/minetest/ (not recommended, see section 2) · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Software | Minetest was renamed Luanti. `minetest/minetest` redirects to `luanti-org/luanti`. |
| Version | Latest stable release `5.18.0`, published 2026-10-29: https://github.com/luanti-org/luanti/releases/tag/5.18.0 |
| Already packaged | `apps/luanti` exists. Its `docker-bake.hcl` pins `VERSION = "5.18.0"`, which matches upstream latest. |
| Renovate | `datasource=github-releases depName=luanti-org/luanti versioning=loose` (same as `apps/luanti`). |
| License | GitHub reports `NOASSERTION` for `luanti-org/luanti` (LICENSE.txt). SPDX not confirmed here: UNVERIFIED. `apps/luanti` uses `AGPL-3.0-or-later` (not confirmed on a fetched page). |
| Source URL | https://github.com/luanti-org/luanti (draft used `minetest/minetest`, which redirects). |
| Release assets | Android apk, Windows zip/exe, macOS zip. No Linux server binary and no per-arch Linux download. Source: https://api.github.com/repos/luanti-org/luanti/releases/latest |
| apt option | `luanti-server` and `minetest-server` are in Ubuntu resolute (26.04) at version `5.10.0+dfsg-5+deb13u1build0.26.04.1`, which is older than upstream 5.18.0: https://packages.ubuntu.com/resolute/luanti-server , https://packages.ubuntu.com/resolute/minetest-server . `minetest-server` arm64 availability: UNVERIFIED. |
| Upstream linuxserver Dockerfile | https://raw.githubusercontent.com/linuxserver/docker-minetest/master/Dockerfile: `baseimage-alpine:3.20`, compiles the server from source, `ENV HOME=/config MINETEST_GAME_PATH=/config/.minetest/games`, `EXPOSE 30000/udp`, `VOLUME /config/.minetest`. Musl build, so not reused. |
| Ports | 30000/udp. No TCP port. |
| Env vars (linuxserver) | `HOME`, `MINETEST_GAME_PATH`. Server config is `minetest.conf`. |
| Write paths | `/config/.minetest` (worlds, games, config). |

## 2. Target layout

Not recommended. `apps/luanti` already packages this software from source on the python base, at the current upstream release. Creating `apps/minetest/` would duplicate an existing container with the same server binary and the same port.

If a separate `minetest` image is still wanted (for example, for a chart name), the only files needed are the five required ones (`Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`), and the `apps/luanti` files should be copied, not rewritten. Otherwise do nothing for this draft.

## 3. Base image

- `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`, as in `apps/luanti/Dockerfile`.
- Why: the server is built from source, and the python base already carries the build-time tooling used there. The draft's `ubuntu` base would also work with the apt route only.
- Closest sibling: `apps/luanti` (same app, same base).

## 4. Dockerfile

Not applicable: `apps/luanti/Dockerfile` already implements the source build (cmake `BUILD_SERVER=1`, luajit, leveldb, postgres, redis, prometheus-cpp, spatialindex, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 30000/udp`). The apt route (`apt install luanti-server`) would ship 5.10.0, which is older than the pinned 5.18.0, so it is not a valid replacement. The draft's "no compile" idea is rejected for this reason.

## 5. docker-bake.hcl

Not applicable: copy `apps/luanti/docker-bake.hcl` if a second target is ever needed. Its `VERSION` is already `5.18.0` with the renovate comment, and its `LICENSE` and `SOURCE` need the UNVERIFIED check in section 1 before any change.

## 6. settings.yaml

Not applicable: `apps/luanti/settings.yaml` already declares `30000/udp`, `TZ`, `CLI_ARGS`, `DATA_DIR` and `/config`. Do not add a second entry for the same server.

## 7. start.sh

Not applicable: `apps/luanti/start.sh` already seeds `/config/.minetest` (`minetest.conf`, games), falls back to `/tmp/.minetest` when `/config` is not writable, and `exec`s `luantiserver --port 30000 --config ...`.

## 8. container-test.yaml

Not applicable: `apps/luanti/container-test.yaml` uses `filePaths: /usr/bin/luantiserver` only, because the port is UDP and a `tcp` probe cannot test game health. A UDP check would be a new test pattern, so do not add one here without a sibling precedent.

## 9. Rootless and read-only-rootfs adaptations

Already handled by `apps/luanti`: runs as `apps`, state in `/config/.minetest`, `/tmp` fallback. The draft's chart expectation (`runAsUser 0`, `readOnlyRootFilesystem false`, `extra-persistence /config/.minetest`) comes from the linuxserver image and does not apply to the luanti container.

## 10. Risks, caveats and open questions

- Duplicate: `apps/luanti` is the same software (see section 2). This is the main finding.
- Draft says the image name is `minetest`. Upstream renamed the project to Luanti, so the name `luanti` is the correct one.
- UDP only: HTTP checks do not reflect game health (draft caveat, confirmed by upstream: only 30000/udp).
- apt route rejected: `luanti-server` 5.10.0 is older than the 5.18.0 upstream release. `minetest-server` arm64: UNVERIFIED.
- License in `apps/luanti` (`AGPL-3.0-or-later`) is not confirmed on a fetched page: UNVERIFIED.
- Blockers: none for `apps/luanti`. None for a duplicate, because it would not be built.

## 11. Build and test steps

Only if a separate `apps/minetest/` is approved. Then from `apps/minetest`:

1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe: `docker run --rm -d --name minetest-probe --read-only --tmpfs /tmp -v minetest-probe-config:/config minetest:5.18.0`, then `docker logs -f minetest-probe` and check the process is alive. Clean up with `docker rm -f minetest-probe; docker volume rm minetest-probe-config`.
4. `forgetool containers test --image minetest:5.18.0 --config ./container-test.yaml`.

For `apps/luanti` (recommended path), no new build is needed. Check its current version against upstream 5.18.0 only.

## 12. PR checklist

- Recommended: no PR. Close the draft as a duplicate of `apps/luanti`.
- If a PR is still wanted: branch `feat/add-minetest`, commit `feat(minetest): add new container`, PR template, Notes section `🤖 This PR is AI generated.`, CLA notice at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say that nothing was built or tested if that is the case.
