# factorioservermanager — implementation plan
> Source: ./draft.md · Target: apps/factorioservermanager/ · Difficulty: hard · Role: main · Verified on 2026-11-24

Corrections to the draft: FSM is a prebuilt Go binary (not Node), so the base is plain `ubuntu`, not `python-node`. The headless Factorio download is public and needs no account. The FSM binary is amd64-only, so the image is amd64-only.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | FSM `0.10.1` (latest release, published 2021-03-09; draft matches). Last commit on master 2024-07-13. Factorio headless stable is `2.1.25` per `https://factorio.com/api/latest-releases` |
| Renovate | `datasource=github-releases depName=OpenFactorioServerManager/factorio-server-manager versioning=semver` |
| License | MIT (GitHub). Factorio itself is proprietary, so it is NOT baked into the image (see section 4) |
| Source URL | https://github.com/OpenFactorioServerManager/factorio-server-manager |
| Download amd64 | `https://github.com/OpenFactorioServerManager/factorio-server-manager/releases/download/0.10.1/factorio-server-manager-linux-0.10.1.zip` (zip holds `factorio-server-manager/{factorio-server-manager,app/,conf.json}`; ELF x86-64, dynamic glibc, checked with `file`) |
| Download arm64 | None (ELF is x86-64 only; Factorio headless is x86_64 only) |
| Checksum | Upstream publishes none. Pin the computed `sha256` of the zip: `c0777636aa521d71700bb8fd69a496b8f4964c0d495ba87c292f293f1003bde7` |
| Factorio download | `https://www.factorio.com/get-download/<version|stable>/headless/linux64` returns HTTP 302 to `dl.factorio.com/releases/<ver>/factorio-headless_linux_<ver>.tar.xz`. No login. No published checksum found (UNVERIFIED) |
| Upstream Dockerfile reviewed | `docker/Dockerfile` and `docker/entrypoint.sh` (master). `FROM ubuntu`; ENV `FACTORIO_VERSION=stable`, `MANAGER_VERSION=0.10.1`, `RCON_PASS=""`; VOLUMEs `/opt/fsm-data /opt/factorio/saves /opt/factorio/mods /opt/factorio/config`; EXPOSE `80/tcp 34197/udp`; entrypoint builds `/opt/fsm-data/conf.json` from `/opt/fsm/conf.json` with jq, downloads Factorio on EVERY start into `/opt`, then `cd /opt/fsm && ./factorio-server-manager --conf /opt/fsm-data/conf.json --dir /opt/factorio --port 80` |
| Binary flags | `--port`, `--host`, `--conf`, `--dir` (from the binary's strings, the entrypoint and the wiki). The wiki flag list gives `--host` (IP the web server listens on, default `0.0.0.0`) and `--port` default `8080`; a newer config table lists `80`. There is no documented `--bind` flag. Also `--bin`, `--config`, `--max-upload`, `--autostart`, `--glibc-*`. |
| Default conf.json | `{"rcon_pass":"","sq_lite_database_file":"sqlite.db","cookie_encryption_key":"","settings_file":"server-settings.json","log_file":"factorio-server-manager.log"}` |
| Ports | 80/tcp web UI upstream (we use 8080), 34197/udp Factorio game. The draft's 27015 RCON is UNVERIFIED and is not listed |

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- No `defaults/`: `conf.json` is generated from the shipped `/app/fsm/conf.json` with jq.
- No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Glibc is required by Factorio and the FSM binary, which ubuntu provides (the upstream comment says the same). `curl`, `jq`, `tar`, `xz-utils` are already in the base. `unzip` and `xz-utils` are also in the base (`apps/ubuntu/Dockerfile` installs them), so no apt step is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu) and `apps/steamcmd` (game server download at runtime).

## 4. Dockerfile

1. `FROM` as in section 3; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Fail fast on arm64: `test "${TARGETARCH}" = "amd64" || { echo "FSM and Factorio are x86_64 only"; exit 1; }`.
3. No apt packages: `curl`, `jq`, `tar`, `xz-utils`, `unzip` come from the base.
4. Download the zip to `/tmp`, verify with `echo "c0777636aa521d71700bb8fd69a496b8f4964c0d495ba87c292f293f1003bde7  /tmp/fsm.zip" | sha256sum -c -` (keep the hash in an `ARG FSM_SHA256` and bump it with each VERSION), `unzip` to `/tmp/x`, `mv /tmp/x/factorio-server-manager /app/fsm`.
5. License: the zip has no license file, so fetch `https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/${VERSION}/LICENSE.md` (the repo ships `LICENSE.md`; the master `LICENSE` path returned 404) into `/usr/share/licenses/factorioservermanager/LICENSE`. If that path 404s, fetch it from the tag archive instead.
6. `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
7. `ENV HOME=/config` and `ARG FACTORIO_VERSION`-free: Factorio is downloaded at first start into `/config/factorio` (not at build time) because it is proprietary and its license forbids redistribution of the binaries in our image. UNVERIFIED legal reading, flagged in section 10.
8. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8080 34197/udp`; `VOLUME /config`; `WORKDIR /app/fsm`.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "factorioservermanager" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=OpenFactorioServerManager/factorio-server-manager versioning=semver
  default = "0.10.1"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/OpenFactorioServerManager/factorio-server-manager" }
```
Targets: `docker-metadata-action {}`, `image` (args `VERSION` and `FSM_SHA256`, OCI `source` and `licenses` labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` with `platforms = ["linux/amd64"]` ONLY (deviation from the usual amd64+arm64 pair, because the binaries do not exist for arm64), `group "default" { targets = ["image-local"] }`. Validate with `cd apps/factorioservermanager && docker buildx bake --print`.

## 6. settings.yaml

Schema header and `schema_version: 1`; `upstream_env_url: "https://github.com/OpenFactorioServerManager/factorio-server-manager"`.
- ports: `8080/tcp required: false` (web UI); `34197/udp required: false` (game, only open once a server is started from the UI).
- env (all read by our `start.sh`): `TZ` default `Etc/UTC`; `FACTORIO_VERSION` default `stable`; `RCON_PASS` default `""` (required false; applied into `conf.json` on every start); `PORT` default `8080`.
- volumes: `/config` required true (holds FSM db and log, `factorio/` install, saves, mods, config).
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
D=/config; F=$D/factorio; PORT="${PORT:-8080}"
mkdir -p "$D/fsm-data" "$F/saves" "$F/mods" "$F/config" /tmp
# Install Factorio once (empty /config), never on every start
if [[ ! -x "$F/bin/x64/factorio" ]]; then
  v="${FACTORIO_VERSION:-stable}"
  curl -fL "https://www.factorio.com/get-download/${v}/headless/linux64" -o /tmp/factorio.tar.xz
  tar -xJf /tmp/factorio.tar.xz -C "$D"      # archive root is factorio/
  rm -f /tmp/factorio.tar.xz
fi
# conf.json: seed when missing, always re-apply RCON password without logging it
if [[ ! -f $D/fsm-data/conf.json ]]; then
  jq '.sq_lite_database_file="/config/fsm-data/sqlite.db" | .log_file="/config/fsm-data/factorio-server-manager.log"' \
    /app/fsm/conf.json > "$D/fsm-data/conf.json"
fi
if [[ -n "${RCON_PASS:-}" ]]; then
  jq --arg p "$RCON_PASS" '.rcon_pass=$p' "$D/fsm-data/conf.json" > /tmp/conf.json && cat /tmp/conf.json > "$D/fsm-data/conf.json" && rm -f /tmp/conf.json
fi
cd /app/fsm
exec ./factorio-server-manager --conf "$D/fsm-data/conf.json" --dir "$F" --port "$PORT"
```
Notes: no write to `/app`; the wiki says `--host` defaults to `0.0.0.0` (all interfaces); confirm with a connection from outside the container during the run test (section 10). The upstream entrypoint echoes the RCON password; ours does not. The tar extraction into an already-created `factorio/` with `saves`, `mods`, `config` is safe because the headless tarball ships those dirs empty or absent (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/fsm/factorio-server-manager
- /app/fsm/app/index.html
```
Timeout is larger than the default because first start downloads Factorio (about 100+ MB, UNVERIFIED size); the web UI starts after the download because `start.sh` runs it first. If CI has no network, make the download non-fatal (`|| echo warn`) so the UI still starts; decide during the build step. Port 34197/udp has no probe: the container-test schema offers only `tcp` and `http` checks (see container-test.instructions.md), and the game port is only opened when a server is started from the UI. Add a YAML comment in the file stating this, and verify the port by hand in section 11. The test runs without env vars, so `RCON_PASS` handling is checked by hand (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/opt/fsm-data` (conf, sqlite, log) | `/config/fsm-data` |
| `/opt/factorio` (install, saves, mods, config) | `/config/factorio` |
| Factorio tarball download in `/tmp` | `/tmp` (tmpfs); size must fit |
| Port 80 | 8080 via `--port`, unprivileged |
| FSM may write `server-settings.json`, `.local` next to cwd (strings show `/app/.local`) | `HOME=/config`; verify nothing writes under `/app` (UNVERIFIED) |

Draft expectations: TrueCharts runs as root with `/opt/factorio/{config,mods,saves}` persistence. We run UID 568 with ONE `/config` volume instead of four, so users must migrate or re-mount those directories as subfolders of `/config/factorio`. `readOnlyRootFilesystem` works if no write hits `/app` or `/opt`. Not privileged.

## 10. Risks, caveats and open questions

- Draft says the download needs an account: not true for headless (verified 302 without login). Only the full game and the mod portal need credentials.
- amd64 only. The arm64 image-all platform is intentionally dropped; check whether CI accepts an amd64-only app.
- FSM is effectively unmaintained (last release 2021). Compatibility with Factorio 2.x (mod portal, `server-settings.json` format, `factorio_version` JSON) is UNVERIFIED and could break the UI. Test by starting a server from the UI before declaring success. Fall back to pinning `FACTORIO_VERSION` to 1.1.x if 2.x fails.
- Factorio EULA on redistribution is UNVERIFIED, hence the runtime download instead of baking into the image.
- `cookie_encryption_key` is empty in the default `conf.json`. The Hub page for `ofsm/ofsm` says a random key is generated and saved to `fsm-data/conf.json` when it is empty; whether the repo's own image behaves the same is UNVERIFIED.
- Default login: the Hub page for `ofsm/ofsm` says `ADMIN_USER` defaults to `admin` and `ADMIN_PASS` to `factorio`. The repo README and wiki document no default login. Treat as a known default to change.
- `--host` defaults to `0.0.0.0` per the wiki flag list (listen address; confirm during the run test).
- First start needs network access and enough `/tmp`.

## 11. Build and test steps

```sh
cd apps/factorioservermanager && docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name factorioservermanager-probe --read-only --tmpfs /tmp \
  -v factorioservermanager-probe-config:/config factorioservermanager:0.10.1
docker logs -f factorioservermanager-probe
forgetool containers test --image factorioservermanager:0.10.1 --config ./apps/factorioservermanager/container-test.yaml
docker rm -f factorioservermanager-probe; docker volume rm factorioservermanager-probe-config
```
Readiness signal: UNVERIFIED exact log line; expect the FSM Go server to log that it listens on the port (check after first run), plus `curl -fsS http://localhost:8080/` returns HTML. Also run a second round with `-e RCON_PASS=test` and confirm `/config/fsm-data/conf.json` contains it and logs do not.

## 12. PR checklist

- Branch `feat/add-factorioservermanager`; commit and PR title `feat(factorioservermanager): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Checklist: bake `--print` passes, VERSION aligned in Dockerfile and bake, renovate comment present, `USER apps`, `COPY --chmod=0755 . /`, empty `/config` start works, read-only rootfs works.
- Untested until built: arm64 (unsupported by design), FSM against Factorio 2.x, runtime download in CI, listening interface, RCON handling, UDP game port.
