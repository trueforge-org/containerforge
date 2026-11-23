# memcached — implementation plan
> Source: ./draft.md · Target: apps/memcache/ (already exists; do not create apps/memcached) · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Existing container | `apps/memcache/` already exists in this repo (Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml). The draft says "a memcache sibling exists to reuse", and it is the same software. The recommended outcome is to point the chart at `ghcr.io/trueforge-org/memcache` and make only small test fixes there. |
| Version | Upstream latest tag is `1.6.45` (memcached/memcached has no GitHub releases, only tags; `1.6.44`, `1.6.43` before it). The Ubuntu 26.04 (resolute) archive has `memcached 1.6.40-1` in the release pocket and `1.6.40-1ubuntu0.3` in updates (Launchpad). `1.6.45-1ubuntu1` exists only for newer Ubuntu series. The existing app pins `1.6.40-1`, so the image contains the version it is tagged with. |
| Renovate | The existing `docker-bake.hcl` has the renovate line disabled because of repology networking issues (`// repologydepName=ubuntu_26_04/memcached versioning=loose`). A working datasource is not verified (UNVERIFIED). |
| License | `BSD-3-Clause` (upstream `LICENSE`: "Copyright (c) 2003, Danga Interactive, Inc."). The Ubuntu package ships its own `/usr/share/doc/memcached/copyright`, so no extra license step is needed for an apt install. |
| Source (`SOURCE`, `upstream_env_url`) | https://memcached.org (existing app) / https://github.com/memcached/memcached |
| Port | `11211/tcp`. The docs (https://docs.memcached.org/serverguide/configuring/) show `tcpport 11211`, `maxbytes 67108864` (64 MB) and `maxconns 1024` as defaults, and say memcached listens on TCP only since 1.5.6. |
| Bind address | The docs page does not state the `-l` default. The draft's worry about "localhost only" comes from Ubuntu's `/etc/memcached.conf` (`-l 127.0.0.1`), which is only read by the service script. We run the binary directly with no `-l`. UNVERIFIED: confirm with `ss -ltn` inside the container and a connection from another container. |
| Env vars | memcached reads none. Options are command-line flags (`-m`, `-c`, `-t`, `-l`, `-p`). |
| Checksum / download | Not applicable (apt package from the Ubuntu archive; apt verifies signatures). The draft's "copy-from bitnamisecure/memcached" is not needed. |
| Upstream Dockerfile reviewed | None (`-` in the draft; bitnami secure image is closed). Reviewed the repo's own `apps/memcache/Dockerfile`: `FROM ubuntu`, `apt-get install -y --no-install-recommends "memcached=${VERSION}"`, `USER apps`, `EXPOSE 11211`, `CMD ["memcached"]`. |

## 2. Target layout

No new app folder. Existing layout of `apps/memcache/` stays:

```
apps/memcache/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
```

- Planned edit: only `container-test.yaml` (add the missing port probe, section 8).
- No `start.sh`: the container runs `memcached` directly via `CMD` (the base entrypoint execs it when no `/start.sh` exists). No `defaults/`, `etc/`, `scripts/`, `health/`. No `root/`.
- `DOWNSTREAM_CHANGES.md`: check first whether another Dockerfile uses `ghcr.io/trueforge-org/memcache` as a `FROM`; none is expected (memcached is a leaf service), so no file is expected.
- If maintainers insist on a separate name `apps/memcached` (matching the chart name), copy these four files unchanged, with `APP = "memcached"`. That duplicates an image, so it is not recommended.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

Copied from the existing `apps/memcache/Dockerfile` (the same digest as the `26.04` reference). Memcached comes from apt on the ubuntu base, as the draft says. Closest sibling: `apps/valkey` (pinned apt package, port 6379).

## 4. Dockerfile

No change planned. For reference, the existing steps are:

1. `FROM` as above; `ARG VERSION`.
2. `USER root`.
3. `apt-get update && apt-get install -y --no-install-recommends "memcached=${VERSION}"`, then purge and remove apt lists and `/tmp` (the version pin ties the image to `VERSION`).
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 11211`, `CMD ["memcached"]`.

Optional follow-up, only if requested: add a `test "$(memcached --version | awk '{print $2}')" = "${VERSION%%-*}"` check after the install, to prove the image holds the tagged version. `VOLUME /config` is not added because the cache is in memory.

## 5. docker-bake.hcl

No change planned. Current values: `APP=memcache`, `VERSION=1.6.40-1`, `LICENSE=BSD-3-Clause`, `SOURCE=https://memcached.org`, standard four targets and the default group. Run `cd apps/memcache && docker buildx bake --print` only if the file is touched. Re-enabling renovate (so that the apt version follows Ubuntu updates) is a separate decision because of the repology issue noted in the file.

## 6. settings.yaml

No change planned. Current file declares port `11211/tcp`, env `TZ` and volume `/config` (`required: true`). Memcached does not use `/config`, but the entry is harmless and consistent with the base; leave it. No `dependencies:`. (Do not add env vars: memcached reads none.)

## 7. start.sh

Not applicable: the container runs `memcached` directly. To tune it, users pass flags as the container command, for example `memcached -m 256 -c 2048`. Do not add an env-to-flag wrapper unless the chart needs one (it would be a new interface, not an upstream one).

## 8. container-test.yaml

Currently only `runners: - entrypoint: memcached --version`. `settings.yaml` lists port 11211, so the coverage rule wants a probe. Planned content (keep the existing runner, add the port):

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

runners:
- entrypoint: memcached --version
tcp:
- port: '11211'
```

Nothing is weakened. `timeoutSeconds` stays at the default (memcached starts instantly). No env vars needed.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: none. memcached keeps data in RAM and has no pid file when run in the foreground. UID 568 (`apps`) is not root, so memcached needs no `-u`.
- Draft expectations (non-root yes, read-only rootfs yes, no persistence) already hold; `/tmp` is not even needed.
- The cache is empty after every restart by design.

## 10. Risks, caveats and open questions

- **This draft is a duplicate of the existing `apps/memcache`.** The right action is to switch the chart to `ghcr.io/trueforge-org/memcache`, not to add a second image. Ask maintainers if a name `memcached` is required.
- Bind address needs a real check from another container (UNVERIFIED, see section 1). If it listens on localhost only, add `-l 0.0.0.0` to `CMD`.
- No authentication in the default setup (no SASL); keep it on an internal network, as the draft says.
- Version drift: upstream is at 1.6.45, the Ubuntu 26.04 archive at 1.6.40 (security fixes are backported by Ubuntu with `ubuntu0.N` suffixes that the pin `1.6.40-1` does not take).
- `apt-get install memcached=1.6.40-1` only works while that exact version stays in the archive; a move of the pin to the updates pocket version is a possible future fix.
- Blockers: none (no musl, GPU, privileged or arm64 issue; apt covers both architectures).

## 11. Build and test steps

```sh
cd apps/memcache
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create memcache-probe-config
docker run --rm -d --name memcache-probe --read-only --tmpfs /tmp \
  -v memcache-probe-config:/config memcache:1.6.40-1
docker logs memcache-probe      # memcached is silent by default; the container must still be running
docker exec memcache-probe ss -ltn   # expect 0.0.0.0:11211 (or *:11211), not 127.0.0.1
docker rm -f memcache-probe; docker volume rm memcache-probe-config
forgetool containers test --image memcache:1.6.40-1 --config ./apps/memcache/container-test.yaml
```

Readiness signal: memcached logs nothing at default verbosity, so use the open port and the running container as the signal. If the image has no `ss`, probe the port from a second container.

## 12. PR checklist

- Branch `feat/add-memcached` per the porter convention, or better `fix/memcache-test-port` for the small change; commit `feat(memcache): ...` or `fix(memcache): add tcp probe for port 11211`. (If a new app is still demanded, use `feat(memcached): add new container`.)
- Use `.github/PULL_REQUEST_TEMPLATE.md`, check only boxes that apply, and put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` shows status).
- Pre-completion: `--print` OK, read-only run with an empty `/config`, test passes with the new probe, nothing weakened.
- Untested so far: nothing was built or run for this plan; the bind address and the new `tcp` probe are unverified; the chart switch to `ghcr.io/trueforge-org/memcache` is outside this repo.
