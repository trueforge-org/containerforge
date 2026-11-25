# teamspeak3 — implementation plan
> Source: ./draft.md · Target: apps/teamspeak3/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **3.13.9**, the latest TeamSpeak 3 server for Linux (the vendor download page lists "Server 64-bit 3.13.9"). It matches the draft. |
| Renovate | `datasource=docker depName=docker.io/library/teamspeak versioning=semver`. The vendor has no GitHub releases, and the Docker official image tags (`3.13.9`, `3.13`, `latest`) follow the vendor version. UNVERIFIED: that the docker datasource filters out non-version tags cleanly. Check the first renovate run. |
| License | Proprietary vendor licence (`LICENSE` in the tarball: TeamSpeak Systems "General Business Terms" and EULA). No SPDX id exists, so use `LicenseRef-TeamSpeak-EULA`. The licence must be accepted on first start (`TS3SERVER_LICENSE=accept`). |
| Source URL | https://www.teamspeak.com/en/downloads/ (docs: https://hub.docker.com/_/teamspeak) |
| Download (amd64 only) | `https://files.teamspeak-services.com/releases/server/3.13.9/teamspeak3-server_linux_amd64-3.13.9.tar.bz2` (HTTP 200, 9.98 MB). No arm64 build is known: the `..._linux_arm64-3.13.9.tar.bz2` URL returns 404. |
| Checksum source | The vendor download page (https://www.teamspeak.com/en/downloads/) publishes a SHA256 for each file. For "Linux Server 64-bit 3.13.9" it is `35049b080d23b001d32079eff0be1404f2d9784fbc7457887422ec134c095d5a` (checked 2026-11-25). There is no `.sha256` sidecar file, and the checksum in the Docker official image is for the different **alpine** tarball. |
| Tarball layout | A top-level `teamspeak3-server_linux_amd64/` containing `ts3server` (ELF x86-64, dynamic, glibc), `libts3db_{sqlite3,mariadb,postgresql}.so`, `libts3_ssh.so` (a NEEDED library of `ts3server`), `redist/libmariadb.so.2`, `sql/`, `serverquerydocs/`, `doc/`, `tsdns/`, `LICENSE`, `3RD_PARTY_LICENSES`, `CHANGELOG`. |
| Binary strings | The binary reads `TS3SERVER_LICENSE`, and a `.ts3server_license_accepted` file or the `license_accepted=1` parameter in the working directory, plus `inifile`, `createinifile` and `licensepath`. The allow-list file is `query_ip_allowlist.txt`. The older `query_ip_whitelist.txt` is also recognised. |
| Upstream Dockerfile reviewed | `TeamSpeak-Systems/teamspeak-linux-docker-images/alpine/Dockerfile` and `entrypoint.sh`. It moves the `.so` files to `/usr/local/lib` and runs `ldconfig`, writes `/var/run/ts3server/ts3server.ini` and `ts3db.ini` from `TS3SERVER_*` env vars, and runs `ts3server inifile=...`. Data is under `/var/ts3server`. |
| Ports | 9987/udp (voice), 10011/tcp (raw ServerQuery), 30033/tcp (file transfer). 10022/tcp (SSH ServerQuery) is only used when `ssh` is in `TS3SERVER_QUERY_PROTOCOLS`. |

## 2. Target layout

```
apps/teamspeak3/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

`start.sh` is required to build the ini files in `/tmp` and to start in `/config`. No `defaults/`, `etc/`, `scripts/` or `health/` is needed. Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

The vendor binary is glibc (`ld-linux-x86-64.so.2`, `libstdc++.so.6`), which fits ubuntu. Closest siblings: `apps/adguardhome-sync` (prebuilt binary, `/app`, `/config`) and `apps/steamcmd` (game-server style). The ubuntu base lacks `bzip2` (it has `xz-utils`, `unzip` and `tar`), so add it.

## 4. Dockerfile

1. `FROM` ubuntu (above); `ARG VERSION`; `ARG TS3_SHA256=35049b080d23b001d32079eff0be1404f2d9784fbc7457887422ec134c095d5a` (vendor-published, see section 1); `ARG TARGETARCH`.
2. `USER root`.
3. `RUN apt-get update && apt-get install -y --no-install-recommends bzip2 libstdc++6 && rm -rf /var/lib/apt/lists/*`. `libstdc++6` is probably already present: check with `dpkg -l libstdc++6` and drop it if so. The only package that is not in the base for sure is `bzip2`. Do not pin: they are tools and not the app, so the version-alignment rule does not apply.
4. Download and extract (amd64 only):
   ```sh
   [ "${TARGETARCH}" = "amd64" ] || { echo "teamspeak3 supports linux/amd64 only"; exit 1; }
   curl -fsSL -o /tmp/ts3.tar.bz2 "https://files.teamspeak-services.com/releases/server/${VERSION}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2"
   echo "${TS3_SHA256}  /tmp/ts3.tar.bz2" | sha256sum -c -
   tar -xjf /tmp/ts3.tar.bz2 -C /app --strip-components=1
   mkdir -p /usr/share/licenses/teamspeak3
   cp /app/LICENSE /app/3RD_PARTY_LICENSES /usr/share/licenses/teamspeak3/
   mv /app/*.so /app/redist/* /usr/local/lib/ && rmdir /app/redist && ldconfig
   chown -R apps:apps /app && chmod -R 755 /app
   rm -f /tmp/ts3.tar.bz2
   ```
   `ts3server` NEEDS `libts3_ssh.so`, and the database plugins are loaded by name, so moving all `.so` files to `/usr/local/lib` follows what the official image does.
5. `ENV HOME=/config`. Do **not** set `TS3SERVER_LICENSE` in the image: the user must opt in explicitly.
6. `USER apps`, `COPY --chmod=0755 . /`.
7. `EXPOSE 9987/udp 10011 30033`, `VOLUME /config`, `WORKDIR /config`.
8. Restrict the build to amd64: set `platforms = ["linux/amd64"]` in `image-all` (see section 5).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "teamspeak3" }
variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/teamspeak versioning=semver
  default = "3.13.9"
}
variable "LICENSE" { default = "LicenseRef-TeamSpeak-EULA" }
variable "SOURCE"  { default = "https://www.teamspeak.com/en/downloads/" }
```

Standard `group "default"`, `image` (args.VERSION, OCI labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`) and `image-all`. In `image-all` use only `platforms = ["linux/amd64"]`, because there is no arm64 build. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.teamspeak.com/en/downloads/"
ports:
  - { port: 9987,  protocol: udp, required: false }
  - { port: 10011, protocol: tcp, required: false }
  - { port: 30033, protocol: tcp, required: false }
env:
  - { name: TZ,                      default: "Etc/UTC",  required: false }
  - { name: TS3SERVER_LICENSE,       default: "",         required: true }   # must be "accept"
  - { name: TS3SERVER_QUERY_PROTOCOLS, default: "raw",    required: false }
  - { name: TS3SERVER_QUERY_TIMEOUT, default: "300",      required: false }
  - { name: TS3SERVER_DEFAULT_VOICE_PORT, default: "9987", required: false }
  - { name: TS3SERVER_QUERY_PORT,    default: "10011",    required: false }
  - { name: TS3SERVER_FILETRANSFER_PORT, default: "30033", required: false }
  - { name: TS3SERVER_LOG_QUERY_COMMANDS, default: "0",   required: false }
  - { name: TS3SERVER_DB_CLIENTKEEPDAYS, default: "30",   required: false }
volumes:
  - path: /config
    required: true
```

Write it in the block style of the sibling files (one key per line), not the inline style above. Only variables that `start.sh` writes into the ini are listed (see section 7). The binary itself reads `TS3SERVER_LICENSE`. `required: true` with an empty default is handled in `start.sh`: unless the user sets `accept`, it logs what to set, and the server does not run (see sections 7 and 10). Optional extras (`TS3SERVER_SERVERADMIN_PASSWORD`, MariaDB/PostgreSQL via `TS3SERVER_DB_*`) are an open question, see section 10. No hard dependencies: SQLite is the default.

## 7. start.sh

Behaviour, in the style of `apps/adguardhome-sync/start.sh` (`#!/usr/bin/env bash`):

1. `umask 077`; `mkdir -p /config/logs`; `cd /config`. The server writes `ts3server.sqlitedb`, `files/`, the SSH host key, `query_ip_allowlist.txt`, `query_ip_blocklist.txt` and `licensekey.dat` relative to its working directory, and `/config` is the only persistent writable path. Do not overwrite existing files.
2. Write `/tmp/ts3server.ini` on **every** start (ephemeral, rebuilt from env), based on the official entrypoint:
   ```
   licensepath=/config
   query_protocols=${TS3SERVER_QUERY_PROTOCOLS:-raw}
   query_timeout=${TS3SERVER_QUERY_TIMEOUT:-300}
   query_ssh_rsa_host_key=/config/ssh_host_rsa_key
   query_ip_allowlist=/config/query_ip_allowlist.txt
   query_ip_blocklist=/config/query_ip_blocklist.txt
   dbplugin=ts3db_sqlite3
   dbpluginparameter=
   dbsqlpath=/app/sql/
   dbsqlcreatepath=create_sqlite
   dbconnections=10
   dbclientkeepdays=${TS3SERVER_DB_CLIENTKEEPDAYS:-30}
   logpath=/config/logs
   logquerycommands=${TS3SERVER_LOG_QUERY_COMMANDS:-0}
   logappend=0
   serverquerydocs_path=/app/serverquerydocs/
   query_port=${TS3SERVER_QUERY_PORT:-10011}
   filetransfer_port=${TS3SERVER_FILETRANSFER_PORT:-30033}
   default_voice_port=${TS3SERVER_DEFAULT_VOICE_PORT:-9987}
   query_ssh_port=10022
   ```
   No `voice_ip`, `query_ip` or `filetransfer_ip` are written, so the server binds all interfaces by default (UNVERIFIED: confirm with `ss -lun`/`ss -ltn` inside the container and from a second container).
3. If `TS3SERVER_LICENSE` is not `accept`, the binary prints the licence and exits. `start.sh` should log a clear line before exec ("set TS3SERVER_LICENSE=accept to accept the TeamSpeak licence") and still `exec` the server, so the binary's own licence text appears in the logs.
4. `exec /app/ts3server inifile=/tmp/ts3server.ini`. `exec` makes signals reach the server.
5. The first-start serveradmin password and privilege key are printed in the logs by the server (draft caveat), which is the only place they appear.

No secrets are written to files by default (the DB password path from the official image is out of scope for the first version).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# The server only starts after the TeamSpeak licence is accepted, so the test opts in
# (same approach as apps/drydock). The image itself never accepts it for the user.
mainRunner:
  env:
    TS3SERVER_LICENSE: "accept"

tcp:
- port: '10011'
- port: '30033'

filePaths:
- /app/ts3server
- /usr/local/lib/libts3_ssh.so
- /usr/share/licenses/teamspeak3/LICENSE

timeoutSeconds: 180
```

Implementation notes: the libraries are moved to `/usr/local/lib` in the Dockerfile, hence the path above. The schema has no UDP probe, so `9987/udp` is not directly tested: the TCP probes cover the same process, and the readiness log line is checked by hand. `timeoutSeconds: 180` is the schema default and the floor, which matches slower siblings. `mainRunner.env` is part of the forgetool test schema and `apps/drydock` uses it. It conflicts with the wording of the container-test rules, see the maintainer decision in section 10.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `/var/ts3server` (database, logs, files, licence) | `/config` (working directory and `logpath`) |
| `/var/run/ts3server/ts3server.ini` and `ts3db.ini` | `/tmp/ts3server.ini` (`/tmp` is the ephemeral scratch area) |
| `/opt/ts3server` binaries and `.so` | `/app` and `/usr/local/lib`, read-only at runtime |
| `chown` and `su-exec` to uid 9987 | Not needed: the image runs as `apps` (568) from the start. |

TrueCharts expectations reconciled: UID 568 matches the chart's default, read-only rootfs is achievable because every write goes to `/config` or `/tmp`, and the chart's PVCs `/var/ts3server` and `/var/run/ts3server` must be remapped to a single `/config` volume (the draft already expects `/config`). The ephemeral ini goes in `/tmp`, so no second volume is required. Not privileged.

## 10. Risks, caveats and open questions

- **amd64 only**: the vendor ships no arm64 server. `image-all` must be amd64-only, and the Dockerfile fails fast on other arches. If CI requires multi-arch for every app, this is a blocker to discuss.
- **Closed source and EULA**: redistributing the vendor binary in an image on ghcr.io may need legal review. The Docker official image is published by TeamSpeak Systems itself. UNVERIFIED: whether a third-party redistribution is allowed.
- **Checksum**: the Dockerfile rules require verification, because the vendor publishes a SHA256 on its download page. Renovate bumps only `VERSION`, so a version PR fails on the checksum until someone copies the new value from that page into `TS3_SHA256`. That failure is intended.
- **Test and default startup (maintainer decision)**: `container-test.instructions.md` says the test cannot set env vars and that an image MUST still start without them. This server does not stay up without licence acceptance. The forgetool schema does have `mainRunner.env` (used by `apps/drydock`), but using it accepts the vendor licence in CI and does not satisfy the start-without-env rule. A maintainer must choose: allow this exception, or have `start.sh` idle until the licence is accepted and narrow the test to `filePaths` (no TCP probes).
- **UDP 9987** cannot be probed by forgetool. Verify manually (`ss -lun` in the container).
- First start prints the serveradmin password and privilege key in the logs, which the user must copy (draft caveat). The query port 10011 must not be exposed publicly.
- Optional features deferred: MariaDB/PostgreSQL via `ts3db.ini` (the libraries are already in the tarball), `TS3SERVER_SERVERADMIN_PASSWORD`, `TS3SERVER_MACHINE_ID`, SSH query.
- The Docker Hub readme names `TS3SERVER_IP_WHITELIST`/`BLACKLIST`, while the official entrypoint uses `ALLOWLIST`/`BLOCKLIST`, and the binary knows `query_ip_allowlist`. This plan uses the allow/block list names.
- Testing note: on an arm64 host the image runs only under amd64 emulation (`--platform linux/amd64`), so emulation may be slow.

## 11. Build and test steps

```sh
cd apps/teamspeak3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name teamspeak3-probe --read-only --tmpfs /tmp \
  -e TS3SERVER_LICENSE=accept -v teamspeak3-probe-config:/config teamspeak3:3.13.9
docker logs -f teamspeak3-probe
docker rm -f teamspeak3-probe; docker volume rm teamspeak3-probe-config
forgetool containers test --image teamspeak3:3.13.9 --config ./apps/teamspeak3/container-test.yaml
```

Also run once **without** `TS3SERVER_LICENSE` to confirm the licence message appears and the exit is clean, and restart the container on the same volume to prove idempotency. Readiness signals: log lines such as `listening on 0.0.0.0:9987`, `query listening ... :10011` and `file transfer listening ... :30033` (the exact wording is UNVERIFIED), plus the one-time `serveradmin` token on first start. The container must stay up, and `ss -ltn` must show 10011 and 30033.

## 12. PR checklist

- Branch `feat/add-teamspeak3`, commit and PR title `feat(teamspeak3): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State in the PR: amd64 only, the manual checksum update on version bumps, the licence acceptance in the test, proprietary licence label, and the UDP port not covered by the test.
- Untested at planning time: the build, the read-only run, `forgetool containers test`, and the library lookup (`ldd` on the ubuntu base). Do not check "Built container locally" unless it was done.
