# dockovpn/dockovpn (repo README, v1.14.0 Dockerfile, scripts/start.sh, release)

Source URL(s) + fetch date:
- https://github.com/dockovpn/dockovpn (README and repo page)
- https://raw.githubusercontent.com/dockovpn/dockovpn/v1.14.0/Dockerfile (draft: github.com/.../blob/v1.14.0/Dockerfile)
- https://raw.githubusercontent.com/dockovpn/dockovpn/v1.14.0/scripts/start.sh (root-level start.sh URL returned 404; scripts/start.sh is the file COPYed into the image)
- https://github.com/dockovpn/dockovpn/releases/tag/v1.14.0
- Fetched 2026-11-26

## What it is
- "Out of the box stateless VPN server docker image" (OpenVPN server with easy-rsa, shell scripts). Boots in seconds, no persistent storage required, but optional volume for PKI and client configs.
- License: GPL-2.0 (README).

## Install/build steps and build deps (v1.14.0 Dockerfile)
- `FROM alpine:3.14.1` (maintainer label present).
- One RUN chain: `apk add --no-cache openvpn easy-rsa bash netcat-openbsd zip curl dumb-init`; `ln -s /usr/share/easy-rsa/easyrsa /usr/bin/easyrsa`; `mkdir -p ${APP_PERSIST_DIR}`; `cd ${APP_PERSIST_DIR}`; `easyrsa init-pki`; `easyrsa gen-dh` (2048 bits per the inline comment); `cp pki/dh.pem /etc/openvpn`; `cd ${APP_INSTALL_PATH}`; `cp config/server.conf /etc/openvpn/server.conf`.
- COPY: `scripts` -> `.` (WORKDIR `${APP_INSTALL_PATH}`), `config` -> `./config`, `VERSION` -> `./config`.
- No ARG. No USER (runs as root).

## Runtime deps
- openvpn, easy-rsa, bash, netcat-openbsd, zip, curl, dumb-init (Alpine packages).

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["dumb-init", "./start.sh"]`, `CMD [""]`.
- start.sh flags (getopt, SHORT `rnqs`, LONG `regenerate,noop,quit,skip`): `-r/--regenerate` (regenerate PKI and DH), `-n/--noop` (init, do not start VPN), `-q/--quit` (quit after init), `-s/--skip` (skip client generation on first start). Unknown option exits 1.
- Helper scripts (via `docker exec`): `./genclient.sh` (options z, o, `n <name>`), `./rmclient.sh <id>`, `./listconfigs.sh`, `./getconfig.sh <id>`, `./version.sh`.

## Env vars
| Name | Dockerfile default | Notes |
| --- | --- | --- |
| APP_NAME | Dockovpn | build-time ENV |
| APP_INSTALL_PATH | /opt/${APP_NAME} (= /opt/Dockovpn) | |
| APP_PERSIST_DIR | /opt/${APP_NAME}_data (= /opt/Dockovpn_data) | |
| NET_ADAPTER | eth0 | start.sh: `ADAPTER="${NET_ADAPTER:=eth0}"` |
| HOST_ADDR | "" (empty) | README says default `localhost` and advises against changing it unless necessary; client config address override. |
| HOST_TUN_PORT | 1194 | Port advertised in client config. |
| HOST_TUN_PROTOCOL | udp (README default; not in Dockerfile ENV) | README: `udp` or `tcp`. TrueCharts comment: only UDP supported. |
| HOST_CONF_PORT | 80 | HTTP port for client config download. Upstream EXPOSE is 8080. |
| CRL_DAYS | 3650 | Days until CRL expires (start.sh: `easyrsa --days=$CRL_DAYS gen-crl`). v1.14.0 notes: now configurable via env. |

- Draft/plan note: README example maps host port 80 to container 8080 for config download.

## Ports
- 1194/udp (VPN tunnel). 8080/tcp (client config download, HTTP server; shuts down after the download per README).

## Volumes/paths and persistent data
- `VOLUME ["/opt/Dockovpn_data"]` (PKI, server certs, client configs). Optional per README: `-v openvpn_conf:/opt/Dockovpn_data`.
- `/etc/openvpn` receives `dh.pem`, `server.conf`, `ca.crt`, `MyReq.crt`, `MyReq.key`, `crl.pem`, `ta.key` (start.sh copies on every start).
- Client config written to `/opt/Dockovpn/client.ovpn` (README via wget example).

## User/UID & permissions
- Runs as root (no USER). Needs NET_ADMIN (README). Compose/TrueCharts add NET_RAW and MKNOD.
- start.sh creates `/dev/net/tun` with `mkdir -p /dev/net` and `mknod /dev/net/tun c 10 200` if not a char device.

## Config files and formats
- `config/server.conf` (copied to /etc/openvpn/server.conf at build; OpenVPN config).
- easy-rsa PKI under `$APP_PERSIST_DIR/pki` (`dh.pem`, `ca.crt`, `issued/MyReq.crt`, `private/MyReq.key`, `crl.pem`). `ta.key` via `openvpn --genkey --secret ta.key`.
- Marker file `.gen` in the persist dir: PKI generation skipped when present.
- Client `.ovpn` file served on 8080 and written as `client.ovpn`.

## Launch sequence (scripts/start.sh, v1.14.0)
- `source ./functions.sh` (not fetched; contains `generateClientConfig`).
- If `.gen` absent: init-pki and gen-dh only if `pki` missing or `-r`; `easyrsa build-ca nopass`; `easyrsa gen-req MyReq nopass`; `easyrsa sign-req server MyReq`; `openvpn --genkey --secret ta.key`; `easyrsa --days=$CRL_DAYS gen-crl`; `touch .gen`.
- Every start: `cp pki/dh.pem pki/ca.crt pki/issued/MyReq.crt pki/private/MyReq.key pki/crl.pem ta.key /etc/openvpn`.
- Unless `-n`: `openvpn --config /etc/openvpn/server.conf &` (background).
- Initial run without `-s`: `generateClientConfig $@ &` in the background.
- Unless `-q`: final `tail -f /dev/null`.
- iptables rules (exact, ADAPTER = NET_ADAPTER):
  - `iptables -A INPUT -i $ADAPTER -p udp -m state --state NEW,ESTABLISHED --dport 1194 -j ACCEPT`
  - `iptables -A OUTPUT -o $ADAPTER -p udp -m state --state ESTABLISHED --sport 1194 -j ACCEPT`
  - `iptables -A INPUT -i tun0 -j ACCEPT`
  - `iptables -A FORWARD -i tun0 -j ACCEPT`
  - `iptables -A OUTPUT -o tun0 -j ACCEPT`
  - `iptables -A FORWARD -i tun0 -o $ADAPTER -s 10.8.0.0/24 -j ACCEPT`
  - `iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT`
  - `iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $ADAPTER -j MASQUERADE`
- Note: start.sh has no nc server and no `HOST_CONF_PORT` handling; client delivery lives in functions.sh (not fetched).

## Healthcheck/readiness endpoints
- None in the Dockerfile. Readiness: HTTP on 8080 (client download) per README; tunnel UDP 1194.

## Version/release info and asset naming
- Latest tag v1.14.0 (marked Latest), date 31 March (year not shown), commit af57c3b (signed).
- Release notes: new `./listconfigs.sh` and `./getconfig.sh`; CRL lifespan configurable via env; fix for attaching a new empty volume; README updates.
- Release page says "2 assets" but names did not render. Repo builds from source; no binary asset names known.
- Source tarball `https://github.com/dockovpn/dockovpn/archive/refs/tags/v1.14.0.tar.gz` (direct archive, not downloaded).
- Docker Hub tags: `latest`, `v#.#.#`, `v#.#.#-regen-dh` (hourly regenerated DH), `dev`.

## Arch support
- Not stated by the README or Dockerfile. Hub page lists no architectures.

## Gotchas
- README: `-r` strongly recommended for regeneration; startup slower.
- Revoked custom-named clients cannot be recreated with the same name.
- Running attached: closing the terminal stops the container (use Ctrl+P Ctrl+Q).
- Requires a Linux host with Docker and a public IP.
- The upstream Dockerfile makes `HOST_CONF_PORT` default to 80, while EXPOSE is 8080 (mismatch in upstream).
