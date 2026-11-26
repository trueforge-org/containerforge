# BLBurgess/adb-hass-androidtv (GitHub)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v1.1.0/README.md
- https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v1.1.0/files/androidtv-connect.sh
- https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/main/Dockerfile
- https://github.com/BLBurgess/adb-hass-androidtv/releases/tag/v1.1.0
- Fetched 2026-11-26

## What it is
A container that runs an ADB server (port 5037) and keeps connections open to Android TV, Fire TV and Google TV devices listed by the user, so Home Assistant's AndroidTV integration can use the ADB server. Core of the project is one bash script, `files/androidtv-connect.sh`. MIT licensed.

## Install/build steps and build deps
Upstream `main` Dockerfile (not pinned, not versioned):
- `FROM alpine:latest`.
- `ENV ANDROID_HOME=/opt/platform-tools`, `PATH` extended with it, `CONFIG_DIR=/opt/androidtv-connect`, `WORKDIR $ANDROID_HOME`.
- `ADD files/androidtv-connect.sh /usr/local/bin/androidtv-connect.sh`.
- One RUN: `apk add --no-cache bash unzip tini curl libc6-compat libgcc`; `mkdir -p "$CONFIG_DIR"`; downloads `https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64` to `/usr/local/bin/yq` (latest, unpinned); downloads `https://dl.google.com/android/repository/platform-tools-latest-linux.zip` (latest, unpinned, linux x86_64 only) and unzips it into `$ANDROID_HOME`, flattens `platform-tools/*`, removes the zip; `chmod +x` the script.
- Upstream also writes an insecure shared ADB key (`/root/.android/adbkey` and `.pub`) from BuildKit secrets `insecure_shared_adb_key` and `insecure_shared_adb_key_pub` into the image layer. Anyone with the image can read it. Do not copy this pattern.
- `EXPOSE 5037`; `ENTRYPOINT ["tini", "--", "/usr/local/bin/androidtv-connect.sh"]`.
- Upstream has no USER, VOLUME or CMD.
- v1.1.0 release notes: Dockerfile build-arg declarations fixed, fewer layers, BuildKit secrets used, script rewritten to support newer Android versions with up-to-date ADB.

## Runtime deps
- `adb` (upstream: platform-tools zip; the Ubuntu package `adb` is the apt equivalent, per plan.md).
- `bash`, `tini` (upstream), `yq` (mikefarah; upstream downloads the latest, and the ubuntu base already ships yq per plan.md).
- Shell tools used by the script: `grep`, `xargs`, `tee`, `seq`-like loops.

## Binaries/entrypoint/CLI flags
- Entrypoint: `/usr/local/bin/androidtv-connect.sh` (upstream, with tini). No CLI flags; configured by env and config file.
- ADB server launch: `ADB_LIBUSB=${enable_adb_usb} "$ADB_BIN" -a -P 5037 server nodaemon &`. `-a` binds all interfaces.
- Device checks: `"$ADB_BIN" devices | grep -w "${host}:${port}"`.
- Pairing: `"$ADB_BIN" pair "$host:$auth_port" "$auth_code"`, run when both auth values are set and the stored code is missing or differs.
- Connect: `"$ADB_BIN" connect "$host:$port" 2>&1` in background; success is detected by "connected to" in output.

## Env vars
| Name | Default | Required | Notes |
| --- | --- | --- | --- |
| devicelist | empty | yes | env form `host[:port][:auth_code:auth_port]`, comma-separated; YAML `devicelist` takes precedence, env used only if YAML is empty or `[]` |
| bootwait | 10 | no | integer >0 and <86400, else default |
| checkfreq | 300 | no | integer >0 and <86400, else default |
| enable_adb_usb | 0 | no | accepts 1/yes/YES/true/TRUE and 0/no/NO/false/FALSE; any other value becomes 0 |
| YQ_BIN | /usr/local/bin/yq | no | override |
| ADB_BIN | /opt/platform-tools/adb | no | override; the plan sets /usr/bin/adb |
| CONFIG_FILE | $CONFIG_DIR/config.yml | no | override |

Per-device keys (YAML): `name` (default "none"), `host`, `port` (default 5555), `auth_code`, `auth_port`.

## Ports
5037/tcp: ADB server, bound on all interfaces, unauthenticated.

## Volumes/paths and persistent data
- `CONFIG_DIR=/opt/androidtv-connect` (hard-coded). Mount here to supply `config.yml`; the README example mounts `/tmp` to it.
- `$CONFIG_DIR/config.yml`: user config.
- `$CONFIG_DIR/.paired_devices`: pairing records, lines `host:auth_port:auth_code`. Pruned for devices no longer listed.
- `$CONFIG_DIR/androidtv-connect.log` plus rotated `androidtv-connect.log.1` to `.5`. The script runs `mkdir -p` and `touch` on these.
- Log rotation: after each write, if size exceeds 5 MiB (5*1024*1024), files shift up and a fresh log is created; up to 5 rotated files kept.
- ADB key: default `~/.android/adbkey` (upstream does not persist a user key; the shared key is baked in).

## User/UID and permissions
Upstream runs as root (no USER). Nothing in the script needs root beyond writing to CONFIG_DIR.

## Config files and formats
YAML `config.yml` (values override env):
```yml
bootwait: 10
checkfreq: 300
enable_adb_usb: no
devicelist:
  - name: Bedroom TV
    host: 192.168.1.101
    port: 5555
    auth_code: 739264
    auth_port: 44556
```
Only `devicelist` is required in the file. The env form cannot carry names.

## Healthcheck/readiness endpoints
None documented. The script logs to stdout and the log file, and loops forever.

## Behaviour and timing
- Exit 1 with "No devices configured via YAML or devicelist environment variable. Exiting." when devicelist is empty or `[]`.
- List validation happens after that check. If every entry is invalid, the script still continues with an empty list.
- Per-entry validation: host must be a DNS name (dots and 2+ letter TLD) or dotted IPv4 with 1-3 digit octets (no range check); port integer 1-65535; auth_code exactly 6 digits; auth_port integer 1-65535; duplicate hosts skipped (first kept); invalid entries logged and skipped; whitespace trimmed via xargs.
- Start: start ADB server, sleep `bootwait`, then loop: connect each device in background (skips already connected), prune pairings, sleep `checkfreq`.
- SIGINT/SIGTERM: cleanup trap kills ADB server, waits, exits 0.
- Log line format: `MM-DD HH:MM:SS androidtv-connect : message`, written to stdout and log via `tee -a`.

## Version/release info and asset naming
- Releases are on GitHub: v1.1.0 (marked Latest, published 29 Jan 2026 by github-actions). Tag names use a `v` prefix (`v1.1.0`); asset names not shown (the page showed "Assets 2" without names); no checksums shown.
- Raw download pattern for a versioned script: `https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v<version>/files/androidtv-connect.sh` and `.../LICENSE`.
- Upstream's `package.json` still reads 1.0.0 (per plan.md).
- Docker Hub tag history: 1.1.0 (Alpine 3.23.3, ADB 36.0.2-14143358), 1.0.0 (2020-12-22, Alpine 3.22.0, ADB 29.0.6-6198805).

## Arch support
Upstream Dockerfile downloads only the linux x86_64 platform-tools and the amd64 yq, so upstream is amd64 only. (Plan.md states the `adb` apt package is available for amd64, arm64, armhf, ppc64el and riscv64 on resolute.)

## Gotchas
- Upstream bakes an insecure shared ADB key into the image.
- Upstream uses `latest` everywhere (alpine, yq, platform-tools); no pins.
- README says the env form port defaults to 5555 when omitted. Plan.md says the env form rejects a bare host (it parses it as the port). This was not reconciled by the fetch: the script summary validates the port as 1-65535 but does not state how a bare host in env form is parsed. Verify in a run before relying on either claim.
- `auth_port` requires `auth_code` (README). Pairing record file also depends on those values.
- Only one ADB client can talk to a device at a time (see Home Assistant docs).
- Upstream checks `ADB_BIN` default `/opt/platform-tools/adb`; plan sets `ADB_BIN=/usr/bin/adb`.
