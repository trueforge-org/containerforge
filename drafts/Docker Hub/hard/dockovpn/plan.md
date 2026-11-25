# dockovpn — implementation plan
> Source: ./draft.md · Target: apps/dockovpn/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v1.14.0 (matches draft `alekslitvinenk/openvpn:v1.14.0`); `releases/latest` redirects to tag v1.14.0. |
| Renovate | `datasource=github-releases depName=dockovpn/dockovpn versioning=semver` with `extractVersion=^v(?<version>.+)$` (tag has a `v` prefix). |
| License | GPL-2.0 (LICENSE at master is GNU GPL Version 2, June 1991). SPDX: `GPL-2.0-only`; UNVERIFIED whether "or later" is intended (the LICENSE file alone does not say). |
| Source URL | https://github.com/dockovpn/dockovpn |
| Downloads | The release has no binary assets (expanded assets list is empty). The app is shell scripts and config; fetch the tag archive https://github.com/dockovpn/dockovpn/archive/refs/tags/v1.14.0.tar.gz (same on both arches). Packages come from apt (`openvpn`, `easy-rsa`, `iptables`, `netcat-openbsd`, `zip`, `curl`), amd64 and arm64. |
| Checksum | None published for the tag archive. UNVERIFIED; pin by tag only. |
| Upstream Dockerfile reviewed | https://github.com/dockovpn/dockovpn/blob/v1.14.0/Dockerfile: `alpine:3.14.1`; apk `openvpn easy-rsa bash netcat-openbsd zip curl dumb-init`; `ENV APP_INSTALL_PATH=/opt/Dockovpn APP_PERSIST_DIR=/opt/Dockovpn_data NET_ADAPTER=eth0 HOST_ADDR= HOST_TUN_PORT=1194 HOST_CONF_PORT=80 CRL_DAYS=3650`; `EXPOSE 1194/udp 8080/tcp`; `VOLUME /opt/Dockovpn_data`; `ENTRYPOINT dumb-init ./start.sh`; build step runs `easyrsa init-pki` and `gen-dh` and copies `dh.pem` and `config/server.conf` to `/etc/openvpn`. |
| start.sh behavior (v1.14.0) | Creates `/dev/net/tun` (`mknod c 10 200`) if absent; adds iptables rules (INPUT/OUTPUT udp 1194, tun0 accept, FORWARD, MASQUERADE for `10.8.0.0/24` on `$NET_ADAPTER`); on first run (no `.gen`) builds PKI/CA/server cert/`ta.key`/CRL under `$APP_PERSIST_DIR`; copies `dh.pem ca.crt MyReq.crt MyReq.key crl.pem ta.key` to `/etc/openvpn`; starts openvpn in the background with `/etc/openvpn/server.conf`; generates a client config once; ends with `tail -f /dev/null`. Flags `-r -n -q -s`. |

## 2. Target layout

```
apps/dockovpn/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  scripts/        # only if upstream scripts are vendored instead of fetched at build
```
Preferred: fetch upstream `scripts/` and `config/` at the tag during build into `/app` (read-only), and keep our own `start.sh` as the entrypoint wrapper. No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Draft says apt-installed OpenVPN on ubuntu. Closest sibling: `apps/wireguard` (VPN, NET_ADMIN, config generation into `/config`).

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends openvpn easy-rsa iptables netcat-openbsd zip libcap2-bin iproute2` (iproute2 provides `ss` for the section 8 probe; pin openvpn/easy-rsa only if the image must state their versions; app `VERSION` is the dockovpn script tag, not the apt packages). Check none are in the base.
3. `curl -fsSL https://github.com/dockovpn/dockovpn/archive/refs/tags/v${VERSION}.tar.gz`, extract `scripts/`, `config/`, `VERSION` into `/app/` (no checksum available; pin by tag). `ln -s /usr/share/easy-rsa/easyrsa /usr/bin/easyrsa` if not provided by the Ubuntu package (UNVERIFIED).
4. License: copy `LICENSE` from the tag archive to `/usr/share/licenses/dockovpn/`, plus OpenVPN/easy-rsa copyright from `/usr/share/doc`.
5. Non-root capabilities: `setcap cap_net_admin,cap_net_raw+ep /usr/sbin/openvpn /usr/sbin/xtables-nft-multi` (UNVERIFIED that file caps work with the target runtime; they require the container bounding set to include NET_ADMIN and `allowPrivilegeEscalation` not blocking exec with file caps).
6. `ENV HOME=/config APP_INSTALL_PATH=/app APP_PERSIST_DIR=/config/data NET_ADAPTER=eth0 HOST_TUN_PORT=1194 HOST_CONF_PORT=8080 CRL_DAYS=3650`.
7. `COPY --chmod=0755 . /`, `EXPOSE 1194/udp`, `EXPOSE 8080/tcp`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

`APP=dockovpn`, `VERSION=1.14.0`, with
```hcl
// renovate: datasource=github-releases depName=dockovpn/dockovpn versioning=semver
```
(plus `extractVersion` handling of the `v` prefix; the Dockerfile adds `v` itself), `LICENSE=GPL-2.0-only`, `SOURCE=https://github.com/dockovpn/dockovpn`. Standard four targets and `default` group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/dockovpn/dockovpn"
ports:
  - port: 1194
    protocol: udp
    required: true
  - port: 8080
    protocol: tcp
    required: false
env:
  - {name: NET_ADAPTER, default: "eth0", required: false}
  - {name: HOST_ADDR, default: "", required: false}
  - {name: HOST_TUN_PORT, default: "1194", required: false}
  - {name: HOST_CONF_PORT, default: "8080", required: false}
  - {name: CRL_DAYS, default: "3650", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
dependencies: []
```
Env names verified from upstream Dockerfile ENV. The default for `HOST_CONF_PORT` is 80 upstream (non-root cannot bind it), we override to 8080 (matches upstream EXPOSE). UNVERIFIED: whether the config-download nc server on `HOST_CONF_PORT` is kept alive after first run.

## 7. start.sh

- `mkdir -p /config/data`; export `APP_PERSIST_DIR=/config/data`.
- `/etc/openvpn` is not writable: either run openvpn with `--config /config/server.conf` after copying the server cert files into `/config/openvpn/` (seed `server.conf` from `/app/config/server.conf` only when missing, rewriting `dh.pem`, `ca.crt`, key and cert paths), or set a tmpfs on `/etc/openvpn`. Prefer `/config/openvpn`.
- Generate `dh.pem`, CA, server cert, `ta.key`, CRL only when missing (idempotent via `/config/data/.gen`, same logic as upstream). Generate DH at first start (upstream does it at build; dh with 2048 bits takes time, so keep generation in start.sh with caching in `/config`).
- Skip `mknod` (not allowed non-root); require `/dev/net/tun` to be passed in, fail with a clear message if missing.
- iptables/NAT rules: attempt, and log a warning instead of failing if not permitted.
- Bind to all interfaces (OpenVPN default listens on all). Env mapped to openvpn via `--port "${HOST_TUN_PORT}"`.
- `exec openvpn --config /config/openvpn/server.conf` in the foreground (instead of upstream background plus `tail -f /dev/null`); run the client config generation/nc server before it, in the background.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
  - port: '8080'
healthCommands:
  - command: "ss -lun"
    expectedContent: "1194"
    matchContent: true
filePaths:
  - /usr/sbin/openvpn
  - /app/scripts/start.sh
```
The schema has no UDP probe (checked), so UDP 1194 is checked via a `healthCommands` entry; `ss` availability in the image is UNVERIFIED (add `iproute2` if missing). The test runs without NET_ADMIN or `/dev/net/tun` unless the harness provides them: UNVERIFIED, so the openvpn process may not start in CI (see 10). `timeoutSeconds` is a guess, no sibling VPN value was compared except the wireguard app.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/Dockovpn_data` (PKI, client configs) | `/config/data` via `APP_PERSIST_DIR` |
| `/etc/openvpn/*` (server.conf, certs, dh.pem) | `/config/openvpn/` |
| `/opt/Dockovpn` (scripts) | `/app` (read-only) |
| `/dev/net/tun` (mknod) | must be passed by the runtime |
| iptables rules | need NET_ADMIN, applied if permitted |
| `/tmp` | scratch (easyrsa temp) |

Draft expects UID 0, caps `NET_ADMIN NET_RAW MKNOD`, writable rootfs, `/opt/Dockovpn_data` persistence, `/dev/net/tun`. Reconciliation: run as `apps` with file capabilities, NET_ADMIN and NET_RAW granted by the runtime, `/dev/net/tun` provided by the runtime, rootfs read-only, persistence on `/config` only. `MKNOD` is no longer needed.

## 10. Risks, caveats and open questions

- BLOCKER candidate: OpenVPN needs NET_ADMIN and a tun device. Running non-root relies on file capabilities, which many runtimes (no_new_privs, restricted PSA) block. UNVERIFIED; if it fails the image can only run as root, which contradicts `USER apps`.
- Draft caveats hold: tun device from the host, loss of `/opt/Dockovpn_data` regenerates all client configs, UDP 1194 must be forwarded.
- Upstream's `HOST_CONF_PORT=80` conflicts with non-root; our default 8080 is a deviation.
- Upstream is Alpine/musl; moving to Ubuntu openvpn 2.6 may differ in `server.conf` directives (e.g. deprecated `comp-lzo`, cipher settings): review `config/server.conf` at the tag. UNVERIFIED.
- The upstream config serves the client .ovpn via netcat on the conf port; this is unauthenticated by design.
- License GPL-2.0-only vs or-later unconfirmed.

## 11. Build and test steps

```sh
cd apps/dockovpn
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dockovpn-probe --read-only --tmpfs /tmp \
  --cap-add NET_ADMIN --cap-add NET_RAW --device /dev/net/tun \
  -v dockovpn-probe-config:/config dockovpn:1.14.0
docker logs -f dockovpn-probe
docker rm -f dockovpn-probe; docker volume rm dockovpn-probe-config
forgetool containers test --image dockovpn:1.14.0 --config ./apps/dockovpn/container-test.yaml
```
Expected readiness signal: OpenVPN's `Initialization Sequence Completed` (standard OpenVPN message, UNVERIFIED in this wrapper) and TCP 8080 open. Also run once without caps to see the failure message.

## 12. PR checklist

- Branch `feat/add-dockovpn`, commit `feat(dockovpn): add new container`, PR template filled, only applicable boxes checked.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: image build, tun and iptables handling, file capabilities, client config generation, arm64, UDP probe.
