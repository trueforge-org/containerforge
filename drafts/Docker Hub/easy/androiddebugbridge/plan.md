# androiddebugbridge — implementation plan
> Source: ./draft.md · Target: apps/androiddebugbridge/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | v1.1.0 (GitHub release, published 2026-01-29). The draft's image is `barnybbb/adb-hass-androidtv:latest` (rolling). Note: `package.json` still says 1.0.0. |
| Renovate | `datasource=github-releases depName=BLBurgess/adb-hass-androidtv versioning=semver` |
| License | MIT ("Copyright (c) 2026 BLBurgess"); the script header says MIT too. |
| Source URL | https://github.com/BLBurgess/adb-hass-androidtv |
| What is shipped | One bash script `files/androidtv-connect.sh` (200 on tag `v1.1.0`: `https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v1.1.0/files/androidtv-connect.sh`, sha256 of the file at that tag `2f0752401a605a452cfddc146d86c9c265ff94f18a4e519627798f53b6f60e81`, computed 2026-11-23). Arch-neutral. |
| adb binary | Ubuntu 26.04 (resolute) package `adb` `1:34.0.5-12build1` (amd64, arm64, armhf, ppc64el, riscv64). The draft's `android-tools-adb` also exists on resolute (a package page is listed) but `adb` is the real package; use `adb`. |
| yq | Already installed in the ubuntu base (`/usr/local/bin/yq`, mikefarah, per-arch). Do not download it again. |
| Checksum | Upstream publishes none for the script. Use the tag URL (immutable by convention) and, optionally, pin the sha256 above. |
| Upstream Dockerfile reviewed | https://github.com/BLBurgess/adb-hass-androidtv/blob/main/Dockerfile (alpine, tini, downloads Google platform-tools zip for linux x86_64 (amd64 only), copies yq amd64, bakes an insecure shared ADB key from BuildKit secrets into `/root/.android`, `EXPOSE 5037`, `ENTRYPOINT tini -- androidtv-connect.sh`) |
| Env vars (README and script) | `devicelist` (required; comma list `host[:port][:auth_code:auth_port]`), `bootwait` (10), `checkfreq` (300), `enable_adb_usb` (no; accepts 1/yes/true/0/no/false). Lower-case names are real. `config.yml` (in the config dir) overrides env. Optional script overrides: `CONFIG_FILE`, `YQ_BIN`, `ADB_BIN`. |
| Ports | 5037/tcp: `adb -a -P 5037 server nodaemon` (listens on all interfaces, unauthenticated). |
| Paths | Hard-coded `CONFIG_DIR=/opt/androidtv-connect` (config.yml, `.paired_devices`, `androidtv-connect.log` + rotated logs). `ADB_BIN` defaults to `/opt/platform-tools/adb`. ADB RSA key: default `~/.android/adbkey` (HOME is `/config` in the base). |
| Behaviour | The script exits 1 when no devices are configured. |

## 2. Target layout

```
apps/androiddebugbridge/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` needed (config is user-created; an example may be added later). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: shell wrapper plus an apt package (draft). Closest sibling: `apps/adguardhome-sync` (single downloaded artifact, `/app`, `start.sh`); `apps/valkey` for apt install in a Dockerfile.

## 4. Dockerfile

1. `FROM`; `ARG VERSION`; `USER root`.
2. `ENV ADB_BIN=/usr/bin/adb YQ_BIN=/usr/local/bin/yq ANDROID_USER_HOME=/config/.android` (script honours `ADB_BIN` and `YQ_BIN`; `ANDROID_USER_HOME` makes the key location explicit, UNVERIFIED for adb 34.0.5, `HOME=/config` already covers `~/.android`).
3. `apt-get update && apt-get install -y --no-install-recommends adb && rm -rf /var/lib/apt/lists/*`. No apt pin: the tagged version is the wrapper, not adb (state this in the PR). Check `adb` and `bash`, `xargs`, `seq` are not duplicated (bash and coreutils are already in the base; `findutils` for `xargs` is expected in the ubuntu base, verify with `command -v xargs`).
4. Install the script and license:
   ```sh
   mkdir -p /app /usr/share/licenses/androiddebugbridge && \
   curl -fsSL -o /app/androidtv-connect.sh "https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v${VERSION#v}/files/androidtv-connect.sh" && \
   curl -fsSL -o /usr/share/licenses/androiddebugbridge/LICENSE "https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v${VERSION#v}/LICENSE" && \
   chmod 0755 /app/androidtv-connect.sh && \
   ln -s /config /opt/androidtv-connect
   ```
   The symlink satisfies the hard-coded `CONFIG_DIR=/opt/androidtv-connect` without patching the script and without a writable rootfs (`mkdir -p` on a symlink to an existing dir is a no-op). Check at build: `test -L /opt/androidtv-connect`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5037`, `WORKDIR /config`, `VOLUME /config`. Final `USER apps`.

## 5. docker-bake.hcl

- `APP` = `androiddebugbridge`; `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=BLBurgess/adb-hass-androidtv versioning=semver
  default = "1.1.0"
  ```
  (URL uses `v${VERSION#v}`, so it works for both forms; confirm how the repo's renovate returns `v` tags, `adguardhome-sync` stores none.)
- `LICENSE` = `MIT`; `SOURCE` = `https://github.com/BLBurgess/adb-hass-androidtv`
- 4 targets and `default` group copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

- Header + `schema_version: 1`; `upstream_env_url: "https://github.com/BLBurgess/adb-hass-androidtv"`.
- `ports`: `5037` tcp `required: false`.
- `env`: `devicelist` default "" (not required: a `config.yml` in `/config` works too), `bootwait` "10", `checkfreq` "300", `enable_adb_usb` "no", `TZ` "Etc/UTC". All `required: false`.
- `volumes`: `/config` required `true` (ADB key, `config.yml`, pairing records, logs).
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/.android
export ANDROID_USER_HOME=/config/.android

if [[ -z "${devicelist:-}" && ! -f /config/config.yml ]]; then
  echo "[androiddebugbridge] No devicelist env and no /config/config.yml: starting a bare ADB server on 5037 only." >&2
  exec /usr/bin/adb -a -P 5037 server nodaemon
fi
exec /app/androidtv-connect.sh
```
Reasons: the upstream script exits 1 without devices, and the container test runs with no env, so the fallback keeps the server and port 5037 alive. The ADB key is generated by adb on first connect into `/config/.android` (persisted; devices stay authorized across restarts, which fixes the draft's key-persistence caveat). The upstream insecure shared key baked at build time is intentionally NOT reproduced. `exec` keeps the script as the process under `tini`; its own trap handles SIGTERM. No `/app` writes; adb server logs go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '5037'
filePaths:
- /app/androidtv-connect.sh
- /usr/bin/adb
- /usr/local/bin/yq
- /usr/share/licenses/androiddebugbridge/LICENSE
```
The tcp probe relies on the bare-server fallback in `start.sh`. Not a database app; no narrowing. A functional test of device connection needs a real device and is left to the manual run; run it per section 11. Add `timeoutSeconds: 60` or copy a sibling value if the first adb start is slow.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/opt/androidtv-connect` (config.yml, `.paired_devices`, logs with rotation) | Symlink to `/config` created at build; files appear in `/config`. |
| `/root/.android/adbkey(.pub)` | `ANDROID_USER_HOME` and `HOME` = `/config/.android`, generated at runtime, persisted. |
| `/opt/platform-tools/adb` | Replaced by apt `/usr/bin/adb` via `ADB_BIN`. |
| adb server temp log (`/tmp/adb.<uid>.log`) | `/tmp` (tmpfs) already. |
| `mktemp` in `cleanup_pairings` | `/tmp`. |

Draft expectations: chart runs as UID 0 with writable rootfs; both are dropped (UID 568, read-only rootfs). Not privileged: USB ADB (`enable_adb_usb`) would need `/dev/bus/usb` access and is UNVERIFIED and likely not usable without device mapping; network ADB is the supported path. Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- Draft: devices must have ADB debugging on and the key authorized; the key now persists in `/config/.android`, so authorize once.
- Security: the ADB server is exposed unauthenticated on 5037 on all interfaces (`-a`, same as upstream). Do not expose beyond the trusted network.
- UNVERIFIED: wireless pairing (`adb pair`) with Ubuntu's adb 34.0.5 and the script's `grep`/`stat` use; test with a real device if available.
- The script pairing record file stores pairing codes in `/config/.paired_devices` (upstream design).
- UNVERIFIED: whether `ANDROID_USER_HOME` is read by adb 34.0.5 (HOME fallback should work anyway).
- The script's yq calls use `yq eval` syntax (mikefarah v4); base provides the latest mikefarah build (unpinned `latest` in the ubuntu base).
- Not blockers: no musl, no GPU, no privileged, arm64 fine (apt `adb` exists for arm64).

## 11. Build and test steps

```sh
cd apps/androiddebugbridge
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name androiddebugbridge-probe --read-only --tmpfs /tmp -v androiddebugbridge-probe-config:/config androiddebugbridge:1.1.0
docker logs -f androiddebugbridge-probe   # expect the "bare ADB server" notice; port 5037 open (e.g. docker exec ... bash -c '</dev/tcp/127.0.0.1/5037')
docker rm -f androiddebugbridge-probe
# second run with the script path
docker run --rm -d --name androiddebugbridge-probe --read-only --tmpfs /tmp -e devicelist=192.0.2.10 -e bootwait=2 -v androiddebugbridge-probe-config:/config androiddebugbridge:1.1.0
docker logs androiddebugbridge-probe      # expect "Starting ADB server...", "Valid host ...", "Failed to connect" warning (no device), still running
docker rm -f androiddebugbridge-probe; docker volume rm androiddebugbridge-probe-config
forgetool containers test --image androiddebugbridge:1.1.0 --config ./apps/androiddebugbridge/container-test.yaml
```
Success: container stays up, port 5037 open, no stack traces, `/config/androidtv-connect.log` is written on the second run.

## 12. PR checklist

- Branch `feat/add-androiddebugbridge`; commit and title `feat(androiddebugbridge): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes has `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested unless run: both architectures, real device connection and pairing, USB mode, key persistence across restarts, `forgetool` run.
- Standard checklist: minimal scope, instruction files followed, version aligned, rootless and read-only, empty `/config` works, no downstream impact, `bake --print` ran.
