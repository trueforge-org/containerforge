# kerio-connect — implementation plan
> Source: ./draft.md · Target: apps/kerio-connect/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `10.0.9` patch 2 (build 10320). `https://download.kerio.com/dwn/kerio-connect-linux-64bit.deb` answers HTTP 302 to `https://cdn.kerio.com/dwn/connect/connect-10.0.9-10320/kerio-connect-10.0.9-10320-p2-linux-amd64.deb`. GFI lists 10.0.9p2 as released 2026-06-29 (security fixes). The draft's `latest` image tag and `chvb` Dockerfile are unversioned. A comment on GFI's page says plain 10.0.9 may have been withdrawn; use p2. |
| Renovate | None available (vendor download, no GitHub/registry datasource). Bump by hand; say so in a plain comment above `VERSION`. UNVERIFIED: a custom regex manager on the redirect URL is possible but not planned. |
| License | Proprietary commercial (trial/licence key). SPDX `LicenseRef-Proprietary`. Redistribution of the .deb in a public image: UNVERIFIED and doubtful; vendor licence must be checked before any public push (see risks). |
| Source URL | https://www.gfi.com/products-and-solutions/network-security-solutions/kerio/kerio-connect (draft says https://www.kerio.com/; both vendor pages, not source code). Use the one that resolves when implementing (UNVERIFIED). |
| Download | amd64 only: the versioned CDN URL above. No arm64 build. Checksum: none found (UNVERIFIED); record a sha256 at implementation time. |
| Upstream Dockerfile reviewed | `chvb/docker-kerio-connect` at `eb6b9083`: `FROM ubuntu:14.04`; apt `wget cryptsetup dnsutils resolvconf sysstat lsof openssh-server supervisor krb5-kdc krb5-admin-server`; `dpkg -i` the .deb then `apt-get install -f`; creates user `docker` with a hardcoded password; `supervisord` entrypoint; moves `/opt/kerio` to `/opt-start` to restore on first start. |
| Ports (upstream EXPOSE) | 4040 (admin), 22, 25, 465, 587, 110, 995, 143, 993, 119, 563, 389, 636, 80, 443, 5222, 5223. Draft lists 25, 465, 587, 110, 995, 143, 993, 80, 443, 4040. |
| Volumes (upstream) | `/backup`, `/mailserver/data`, `/opt/kerio`. |
| Env vars | None in the upstream Dockerfile. App-internal config is done in the admin web UI on 4040. |
| Supported OS | Latest list found (for 10.0.6, third-party mirror): Debian 7-10, Ubuntu 14.04-20.04. Support for Ubuntu 26.04 base: UNVERIFIED (likely unsupported); .deb package dependencies and postinst behaviour: UNVERIFIED. |

## 2. Target layout

```
apps/kerio-connect/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/     # only if the seeding of /config needs template files, see section 7
```
No `DOWNSTREAM_CHANGES.md`, no `root/`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (draft). This is a poor match: the vendor supports Ubuntu up to 20.04 in the lists found. If installation on 26.04 fails (libraries, postinst), the fallback is a different base, which breaks the repo convention; if no workable base exists, abandon the port (section 10). Closest sibling: `apps/kasm` (large vendor stack with its own installer), `apps/hytale` (vendor binary).

## 4. Dockerfile

1. `ARG VERSION=10.0.9`, `ARG PATCH=p2`, `ARG BUILD=10320`, `ARG TARGETARCH`, `USER root`. Fail early on arm64: `test "$TARGETARCH" = "amd64"`.
2. `apt-get install -y --no-install-recommends ca-certificates curl dnsutils lsof sysstat krb5-user` etc: the upstream list (cryptsetup, resolvconf, openssh-server, supervisor, krb5-kdc) is for a VM-like container; keep only what the .deb declares as dependencies (UNVERIFIED: run `dpkg-deb -I` on the .deb at implementation time and install exactly its `Depends`).
3. Download `https://cdn.kerio.com/dwn/connect/connect-${VERSION}-${BUILD}/kerio-connect-${VERSION}-${BUILD}-${PATCH}-linux-amd64.deb` to `/tmp`, verify sha256 (recorded then), `dpkg -i` with `policy-rc.d` returning 101 and `DEBIAN_FRONTEND=noninteractive` so postinst does not start services; `apt-get install -f` if needed; delete the .deb. UNVERIFIED: postinst may try debconf questions or systemd/sysv scripts.
4. Move the installed tree to a template location (`mv /opt/kerio /usr/share/kerio-connect-dist` as upstream does with `/opt-start`) so first run can seed `/config`; make `/opt/kerio` a symlink to `/config/kerio`, UNVERIFIED whether the product accepts a symlinked data root.
5. Licences: copy the EULA/licence files shipped in the package (path UNVERIFIED) to `/usr/share/licenses/kerio-connect/`.
6. `ENV HOME=/config`; `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 4040 25 465 587 110 995 143 993 80 443` (only ports the container really opens); `VOLUME /config`.

## 5. docker-bake.hcl

`APP = "kerio-connect"`, `VERSION = "10.0.9"` with a plain "bump by hand: no renovate datasource" comment (no `renovate:` annotation can be accurate), extra variables `PATCH = "p2"` and `BUILD = "10320"` passed as args, `LICENSE = "LicenseRef-Proprietary"`, `SOURCE = "https://www.kerio.com/"`. Standard targets with `image-all` limited to `linux/amd64` only (no arm64 package); keep `docker-metadata-action`, `image`, `image-local`, `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.kerio.com/"
ports:
  - {port: 4040, protocol: tcp, required: true}
  - {port: 80, protocol: tcp, required: false}
  - {port: 443, protocol: tcp, required: false}
  - {port: 25, protocol: tcp, required: false}
  - {port: 465, protocol: tcp, required: false}
  - {port: 587, protocol: tcp, required: false}
  - {port: 110, protocol: tcp, required: false}
  - {port: 995, protocol: tcp, required: false}
  - {port: 143, protocol: tcp, required: false}
  - {port: 993, protocol: tcp, required: false}
env:
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: true}
  - {path: /backup, required: false}
dependencies: []
```
No env vars are read by the app (none found). Ports below 1024 are listed because the app configures them itself, see section 9 for how rootless binding is handled. `/backup` is the chart's extra persistence (draft).

## 7. start.sh

- `set -euo pipefail`; `mkdir -p /config/kerio /backup /tmp/run`.
- Seed `/config/kerio` from `/usr/share/kerio-connect-dist` only if empty (`[ -z "$(ls -A /config/kerio)" ] && cp -a ...`); never overwrite the existing store.
- Start the main daemon in the foreground: the vendor ships `/opt/kerio/mailserver/mailserver /opt/kerio/mailserver` (path and options UNVERIFIED, check the .deb contents and `/etc/init.d/kerio-connect`). Final `exec` of that binary; no supervisord/sshd, no second process. If the product needs helper daemons (antivirus, webmail), a small supervising loop may be unavoidable (UNVERIFIED).
- Bind all interfaces: default behaviour of a mail server; confirm with a connect from outside.
- No env passwords. Admin account creation happens in the web wizard on port 4040 on first run (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '4040'
- port: '80'
- port: '443'
- port: '25'
- port: '465'
- port: '587'
- port: '110'
- port: '995'
- port: '143'
- port: '993'
filePaths:
- /start.sh
- /usr/share/licenses/kerio-connect/
```
Every port in settings.yaml has a tcp probe. Whether all ports listen on a fresh, unlicensed, unconfigured instance (many are enabled only after setup) is UNVERIFIED; if only 4040 (and 80/443) are up before setup, the settings.yaml list must shrink to what truly opens; do not weaken the probe. The DB-narrowing exception does not apply (no database dependency).

## 9. Rootless and read-only-rootfs adaptations

- Upstream/chart: root, `readOnlyRootFilesystem false`, no capabilities, yet mail ports 25/110/143/465/587/993/995 and 80/443 are below 1024; chart adds neither root bypass nor `NET_BIND_SERVICE` (draft). Our `USER apps` cannot bind <1024 unless the pod sets `net.ipv4.ip_unprivileged_port_start=0` (sysctl) or `NET_BIND_SERVICE`, or the product's listeners are remapped to high ports in the admin UI (UNVERIFIED that Kerio allows it). The PR must document the sysctl/capability needed.
- Upstream writes: `/opt/kerio` (config, store), `/mailserver/data` (mail store, upstream volume), `/backup`, `/var/log`, krb5 config symlink, `/etc` files by postinst. Remap `/opt/kerio` (and data) into `/config/kerio`, backups to `/backup`, logs/pid/tmp to `/tmp`. Which paths the daemon hardcodes: UNVERIFIED.
- Hardcoded `docker` user/password, sshd, supervisord: dropped on purpose.
- `readOnlyRootFilesystem: true` is the target but may be unachievable if the daemon writes below `/etc`; record the finding if so.

## 10. Risks, caveats and open questions

- Likely blocker: closed-source, amd64-only, Ubuntu 14.04-era packaging, vendor supports Ubuntu <= 20.04 only; may not install or run on 26.04.
- Likely blocker: privileged ports plus rootless user; the product also needs DNS (MX/SPF), TLS certs, and a licence/trial key (draft caveats).
- Likely blocker for public images: redistributing the vendor .deb (licence terms UNVERIFIED); consider a build that downloads at run time, which conflicts with read-only `/app` and the repo's checksum rule.
- Plain 10.0.9 reportedly withdrawn; pin p2. The unversioned `kerio-connect-linux-64bit.deb` always points at the newest build, so never use it in the Dockerfile.
- No arm64 (draft caveat).
- Recommendation: do a time-boxed spike (build + start with an empty `/config`); if the daemon does not start unprivileged on 26.04 in the 10-round limit, record as `unfixable`.

## 11. Build and test steps

```sh
cd apps/kerio-connect
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name kerio-connect-probe --read-only --tmpfs /tmp \
  -v kerio-connect-probe-config:/config kerio-connect:10.0.9
docker logs -f kerio-connect-probe
forgetool containers test --image kerio-connect:10.0.9 --config ./apps/kerio-connect/container-test.yaml
docker rm -f kerio-connect-probe; docker volume rm kerio-connect-probe-config
```
Expected readiness: Kerio's own log shows the admin/HTTP service started and TCP 4040 opens (exact line UNVERIFIED). Low ports need `--sysctl net.ipv4.ip_unprivileged_port_start=0` on the `docker run`, which the protocol command does not include; add it only for the probe and note it in the PR.

## 12. PR checklist

- Branch `feat/add-kerio-connect`; commit/PR title `feat(kerio-connect): add new container`; target `main`.
- PR template filled, only applicable boxes checked; Notes contain `🤖 This PR is AI generated.`
- CLA reminder: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Flag in the PR: proprietary licence, amd64 only, sysctl for ports <1024.
- Untested unless run: everything (build, postinst on 26.04, daemon path, rootless start, ports, read-only rootfs, forgetool). State plainly which steps were not run.
