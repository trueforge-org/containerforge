# zerotier — implementation plan
> Source: ./draft.md · Target: apps/zerotier/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.16.2` (GitHub release `1.16.2`, 2026-05-28; apt repo `resolute` carries `zerotier-one 1.16.2` for amd64 and arm64). Draft has no tag (`zerotier/zerotier` image). |
| Renovate | `datasource=github-releases depName=zerotier/ZeroTierOne versioning=semver` (tags have no `v` prefix) |
| License | Mixed (UNVERIFIED which applies to the apt binary). Repo `LICENSE.txt`: code in `node/`, `osdep/`, `service/` and elsewhere is `MPL-2.0` (`LICENSE-MPL.txt`); `nonfree/` (controller etc.) is the ZeroTier Source-Available License 1.0 for non-commercial use only. `one.cpp` prints either MPL-2.0 or the non-commercial notice depending on build flag `ZT_NONFREE_CONTROLLER`; which flag the packaged `.deb` uses is UNVERIFIED. `README.docker.md` still mentions BSL 1.1 (outdated). Proposed `LICENSE` value: `MPL-2.0 AND LicenseRef-ZeroTier-Source-Available-1.0`, to be confirmed by running `zerotier-one -v`/`zerotier-cli -h` and reading the printed notice. |
| Source | https://github.com/zerotier/ZeroTierOne (docs https://docs.zerotier.com/) |
| Download | APT repository, no tarball: `deb [signed-by=/usr/share/keyrings/zerotier.gpg] http://download.zerotier.com/debian/resolute resolute main` (repo `InRelease` returns HTTP 200 for `resolute`). Direct files: `https://download.zerotier.com/debian/resolute/pool/main/z/zerotier-one/zerotier-one_1.16.2_amd64.deb` and `..._arm64.deb`. |
| Key | `https://download.zerotier.com/contact%40zerotier.com.gpg` (HTTP 200). Fingerprint UNVERIFIED; compare against docs.zerotier.com at implementation. |
| Checksum | amd64 `.deb` sha256 `691ba3984c9918a08652fbba8a977cbb79fa724f9814d94dc3949089df50a4e5` (from repo `Packages`); arm64 sha256 `ba5a9854fde677b5bfdca205a6bcaff841a9542c13e265435469f2aecfe5da9f` (the first `SHA256` line of the arm64 `Packages` file, double-check). apt verifies the signed index, so these are only a cross-check. |
| Deb depends | `adduser, libstdc++6 (>= 5), openssl` |
| Upstream Dockerfile | Reviewed `Dockerfile.release` (debian:bookworm; imports key, adds repo, `apt-get install zerotier-one=${VERSION} curl iproute2 net-tools iputils-ping openssl libssl3`, `rm -rf /var/lib/zerotier-one`, `HEALTHCHECK` using `/healthcheck.sh`, `ENTRYPOINT /entrypoint.sh`) and `entrypoint.sh.release`. |
| Entrypoint env vars | `ZEROTIER_JOIN_NETWORKS` (space separated 16-digit ids), `ZEROTIER_API_SECRET` (-> `authtoken.secret` and `metricstoken.secret`), `ZEROTIER_IDENTITY_PUBLIC`, `ZEROTIER_IDENTITY_SECRET`, `ZEROTIER_LOCAL_CONF` (-> `local.conf`). Command-line args are network ids. It writes `zerotier-one.port` = `9993`. |
| Ports | `9993/udp` (peer traffic); `9993/tcp` is the local control API (`127.0.0.1` only). `zerotier-one -p<port>` / `zerotier-cli -p<port>` / `-D<path>` home option exist (`one.cpp` help). |
| Data | Default home `/var/lib/zerotier-one` (identity.public/secret, authtoken.secret, local.conf, networks.d, planet, moons.d). |
| Runtime needs | `CAP_NET_ADMIN` and `/dev/net/tun` (upstream README.docker.md). |

## 2. Target layout

```
apps/zerotier/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: network daemon from its apt repo (draft). Ubuntu 26.04 codename `resolute` has a ZeroTier repo suite. Closest sibling: `apps/valkey` (pinned apt package checked against `VERSION`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Add the repo (curl, gpg, ca-certificates already in base):
   ```
   curl -fsSL "https://download.zerotier.com/contact%40zerotier.com.gpg" | gpg --dearmor -o /usr/share/keyrings/zerotier.gpg && \
   echo "deb [signed-by=/usr/share/keyrings/zerotier.gpg] http://download.zerotier.com/debian/resolute resolute main" > /etc/apt/sources.list.d/zerotier.list
   ```
3. Install the pinned package, asserting the version matches the tag (as `apps/valkey` does):
   ```
   apt-get update && apt-get install -y --no-install-recommends "zerotier-one=${VERSION}" iproute2 iputils-ping && \
   test "$(dpkg-query -W -f='${Version}' zerotier-one)" = "${VERSION}"
   ```
   (`curl` and `openssl`/`libssl3` already in base; `iproute2` provides `ip`/`ss`, `iputils-ping` is optional diagnostics.)
4. Home dir remap and file capabilities for non-root:
   ```
   rm -rf /var/lib/zerotier-one && ln -s /config /var/lib/zerotier-one && \
   setcap cap_net_admin,cap_net_raw+eip /usr/sbin/zerotier-one
   ```
   `libcap2-bin` (`setcap`) is installed with step 3 if missing. The `setcap` approach only works when the runtime adds `NET_ADMIN`/`NET_RAW` to the container and does not set `no-new-privileges`; see section 10.
5. Licenses: `mkdir -p /usr/share/licenses/zerotier && cp /usr/share/doc/zerotier-one/copyright /usr/share/licenses/zerotier/ 2>/dev/null || true`, plus fetch `LICENSE.txt`, `LICENSE-MPL.txt`, `nonfree/LICENSE.md` from `https://raw.githubusercontent.com/zerotier/ZeroTierOne/${VERSION}/` (checked in the Dockerfile with `test -s`).
6. Cleanup: `apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*`.
7. `ENV HOME=/config`, `EXPOSE 9993/udp`, `VOLUME /config`, `CMD ["/start.sh"]`.
8. `USER apps`, then `COPY --chmod=0755 . /`. Image ends with `USER apps`.

## 5. docker-bake.hcl

- `APP` = `zerotier`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=zerotier/ZeroTierOne versioning=semver
  default = "1.16.2"
  ```
- `LICENSE` = `MPL-2.0 AND LicenseRef-ZeroTier-Source-Available-1.0` (pending the check in section 1), `SOURCE` = `https://github.com/zerotier/ZeroTierOne/`
- Targets `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 + arm64, both debs exist), group `default`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/zerotier/ZeroTierOne/"
ports:
  - port: 9993
    protocol: udp
    required: true
  - port: 9993
    protocol: tcp
    required: false     # local control API, 127.0.0.1 only
env:
  - name: ZEROTIER_JOIN_NETWORKS
    default: ""
    required: false
  - name: ZEROTIER_API_SECRET
    default: ""
    required: false
  - name: ZEROTIER_IDENTITY_PUBLIC
    default: ""
    required: false
  - name: ZEROTIER_IDENTITY_SECRET
    default: ""
    required: false
  - name: ZEROTIER_LOCAL_CONF
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No `dependencies`. The runtime also needs `--cap-add NET_ADMIN --cap-add NET_RAW --device /dev/net/tun`; settings.yaml has no field for these, so they go in the docs/PR notes.

## 7. start.sh

- `set -euo pipefail`; `umask 077`; `mkdir -p /config/networks.d`.
- Seeding (rewritten on every start only when the matching env var is non-empty, like upstream, so a changed secret also works on existing data; files are left untouched when the env var is empty, so empty `/config` start generates a fresh identity): `ZEROTIER_API_SECRET` -> `authtoken.secret` (0600) and `metricstoken.secret`; `ZEROTIER_IDENTITY_PUBLIC` -> `identity.public` (0644); `ZEROTIER_IDENTITY_SECRET` -> `identity.secret` (0600); `ZEROTIER_LOCAL_CONF` -> `local.conf`. Use `printf '%s'` writes to avoid trailing newline (upstream `echo -n`). Values are written only from the environment to files with restrictive modes, never echoed or placed on the command line.
- Networks: for each arg and each id in `ZEROTIER_JOIN_NETWORKS`, validate `^[0-9a-f]{16}$` and `touch /config/networks.d/<id>.conf`; write `/config/zerotier-one.port` = `9993`.
- Warn (do not exit) if `/dev/net/tun` is missing or not writable: `ZeroTier cannot create interfaces without /dev/net/tun and NET_ADMIN`.
- Final command: `exec /usr/sbin/zerotier-one -p9993 /config` (the home directory as trailing argument is UNVERIFIED in `one.cpp`; the symlink `/var/lib/zerotier-one -> /config` makes the argument optional, so drop it if the daemon rejects it). Upstream runs the daemon in the background under a sleeping shell; here it is the foreground main process so signals propagate (tini is PID 1 in the base).
- The control API binds `127.0.0.1` only by design; the peer port `9993/udp` binds all addresses.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '9993'
healthCommands:
- command: zerotier-cli info
  expectedContent: "200 info"
  matchContent: true
- command: ss -lun
  expectedContent: ":9993"
  matchContent: true
filePaths:
- /usr/sbin/zerotier-one
- /usr/bin/zerotier-cli
- /usr/share/licenses/zerotier
```

The TCP probe covers the local API port and the `ss -lun` command covers the UDP 9993 port from section 6 (the schema has no UDP probe type). The test runs with no env, no capabilities and no TUN device, so the daemon is expected to start and serve the API but not create network interfaces; if `zerotier-one` exits without NET_ADMIN, this must be fixed in `start.sh` (UNVERIFIED), not by weakening the test. `timeoutSeconds`: use the default used in `apps/valkey` or `apps/adguardhome-sync` (none set); add about 60 if first-run identity generation is slow (it can take several seconds). `expectedContent` format of `zerotier-cli info` (`200 info <id> <version> ONLINE`) is from upstream docs, wording UNVERIFIED.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/var/lib/zerotier-one/*` (identity, authtoken, networks.d, peers.d, moons.d, planet, local.conf, `zerotier-one.pid`, `zerotier-one.port`) | `/var/lib/zerotier-one` is a symlink to `/config`; identity and network membership persist there |
| `nohup.out` in the entrypoint | not used |
| `/healthcheck.sh` generated at start by upstream entrypoint | not generated; test uses `zerotier-cli info` |
| Deb postinst artifacts (service user `zerotier-one`, systemd units) | unused; process runs as `apps` (568) |

Draft expected root, rootfs writable, `NET_ADMIN`, hostPath `/dev/net/tun`, persistence `/var/lib/zerotier-one`. Target: UID 568 with file capabilities (`setcap`), read-only rootfs, `--cap-add NET_ADMIN NET_RAW`, `--device /dev/net/tun`, `/config` volume instead of `/var/lib/zerotier-one`. Not `privileged`.

## 10. Risks, caveats and open questions

- BLOCKER candidate: rootless operation. Whether `zerotier-one` as UID 568 with `setcap cap_net_admin,cap_net_raw+eip` can open `/dev/net/tun` and configure interfaces inside Docker/Kubernetes is UNVERIFIED (file caps are ignored when `no-new-privs` is set, as Kubernetes `allowPrivilegeEscalation: false` does; then the image would need to run as root, which conflicts with `USER apps`). Test with `docker run --cap-add NET_ADMIN --cap-add NET_RAW --device /dev/net/tun` and with `--security-opt no-new-privileges`.
- License: confirm what the `.deb` is built with (non-commercial source-available vs MPL-2.0); the non-commercial licence would restrict redistribution/use by businesses. Resolve before publishing.
- Host needs UDP 9993 reachable (port forward or `network_mode: host`) for direct peer connections.
- The draft says `iproute2 (inferred)`; the upstream image installs `curl iproute2 net-tools iputils-ping openssl libssl3`, of which only `iproute2` and optionally `iputils-ping` are missing in our base.
- Apt repo key fingerprint not verified; `resolute` suite may lag a new Ubuntu release (it currently exists).
- Identity is a secret; losing `/config` changes the node address.

## 11. Build and test steps

```sh
cd apps/zerotier
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create zerotier-probe-config
docker run --rm -d --name zerotier-probe --read-only --tmpfs /tmp \
  --cap-add NET_ADMIN --cap-add NET_RAW --device /dev/net/tun \
  -v zerotier-probe-config:/config zerotier:1.16.2
docker logs -f zerotier-probe
docker exec zerotier-probe zerotier-cli info
forgetool containers test --image zerotier:1.16.2 --config ./apps/zerotier/container-test.yaml
docker rm -f zerotier-probe; docker volume rm zerotier-probe-config
```

Also run once with no `--cap-add`/`--device` (what CI does) and once with `-e ZEROTIER_JOIN_NETWORKS=<id>`. Readiness signal: `zerotier-cli info` prints `200 info <address> 1.16.2 ONLINE|OFFLINE` and the process stays up (ONLINE needs internet).

## 12. PR checklist

- Branch `feat/add-zerotier`, commit `feat(zerotier): add new container`, PR title the same, target `main`.
- PR template filled in; Notes contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, arm64, non-root TUN/NET_ADMIN behaviour, file-capability approach, license of the packaged binary, apt key fingerprint, `zerotier-one` home argument.
