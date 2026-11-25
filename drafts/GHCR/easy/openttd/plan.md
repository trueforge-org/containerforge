# openttd — implementation plan
> Source: ./draft.md · Target: apps/openttd/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 15.3 (latest stable, released 2026-04-04 19:57 UTC). Source: https://www.openttd.org/downloads/openttd-releases/latest and https://api.github.com/repos/OpenTTD/OpenTTD/releases/latest (tag `15.3`). Draft has no version. |
| Renovate | `datasource=github-releases depName=OpenTTD/OpenTTD versioning=loose` (tags are plain numbers like `15.3`; exact versioning UNVERIFIED against upstream tag history) |
| License | GitHub reports `NOASSERTION`, so no SPDX from the API. UNVERIFIED: upstream COPYING not fetched; OpenTTD is believed to be GPL-2.0-or-later, confirm before setting `LICENSE`. |
| Source URL | https://github.com/OpenTTD/OpenTTD |
| Download amd64 | https://cdn.openttd.org/openttd-releases/15.3/openttd-15.3-linux-generic-amd64.tar.xz (confirmed on release page) |
| Checksum source | Release page: sha256 `f49eb25d61b00f8f4d332fee02b530ad75552d1efb8f2bb01e7ca5e6540fe059`, sha1 `a394a91150efc0f48d01be6d279d1a985565dd5e`, md5 `11695ebecf769385791a1e5e64f08381` |
| Download arm64 | UNVERIFIED: no Linux arm64 tarball on the release page. Draft says arm64 uses apt `openttd` (15.1 per draft); not verified here. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-openttd-server/master/Dockerfile: `FROM ich777/debian-baseimage`, apt `unzip xz-utils curl screen libgomp1 libglib2.0-0`, gotty v1.0.1 (`yudai/gotty` linux_amd64), `ENTRYPOINT ["/opt/scripts/start.sh"]`, no USER (runs root), no VOLUME, no EXPOSE. Its `start.sh` was NOT fetched (UNVERIFIED for server download flow and graphics). |
| Ports | Game port 3979 (`GAME_PORT` default 3979), TCP and UDP per draft (UNVERIFIED beyond the default). Admin port 3977 is UNVERIFIED, not listed. |
| Env vars (upstream, real) | `DATA_DIR=/serverdata`, `SERVER_DIR=/serverdata/serverfiles`, `GAME_PARAMS=template`, `GAME_PORT=3979`, `GAME_VERSION=latest`, `ENABLE_WEBCONSOLE=true`, `GOTTY_PARAMS=-w --title-format OpenTTD`, `COMPILE_CORES`, `GFX_PK_V=latest`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=openTTD`. Note: `GAME_PARAMS=template`, `GAME_VERSION`, `GFX_PK_V` and `ENABLE_WEBCONSOLE` are upstream wrapper names; ContainerForge should only keep the ones its own `start.sh` reads. |
| Data path | Upstream: `/serverdata` (DATA_DIR). ContainerForge: `/config` (per draft). |
| Dependencies | None (no DB, no sidecar). |

## 2. Target layout

- `apps/openttd/Dockerfile`
- `apps/openttd/docker-bake.hcl`
- `apps/openttd/settings.yaml`
- `apps/openttd/container-test.yaml`
- `apps/openttd/start.sh`

No `defaults/` or `etc/` unless the graphics or a default config must be seeded (decide after the UNVERIFIED `start.sh` check). Never `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Ubuntu fits: the arm64 path uses the Ubuntu `openttd` package and the amd64 tarball is glibc-linked. Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu) and `apps/steamcmd` for the game-server layout.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. apt: install only what the base lacks. Tarball path needs `xz-utils` (check whether the base already has it, then skip). arm64 path needs `openttd` from apt, pinned to the exact version it installs; record that version and compare it with `VERSION` (mismatch is a known caveat, see section 10).
3. amd64: `curl -fL -o /tmp/openttd.tar.xz https://cdn.openttd.org/openttd-releases/${VERSION}/openttd-${VERSION}-linux-generic-amd64.tar.xz`, then `echo "f49eb25d61b00f8f4d332fee02b530ad75552d1efb8f2bb01e7ca5e6540fe059  /tmp/openttd.tar.xz" | sha256sum -c -`. The sha256 is for 15.3 only; if `VERSION` changes, the checksum must come from the new release page (use an `ARG OPENTTD_SHA256` next to `VERSION` or a per-version map, and keep it in step with bake).
4. Extract to `/app/openttd` (`tar -xJf /tmp/openttd.tar.xz -C /app/openttd --strip-components=1`), `rm /tmp/openttd.tar.xz`.
5. License: copy the upstream COPYING file to `/usr/share/licenses/openttd/` (UNVERIFIED that the tarball ships it; if absent, fetch it from the repo tag `15.3`).
6. `ENV HOME=/config XDG_DATA_HOME=/config XDG_CACHE_HOME=/tmp` (no writes to `/app`).
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3979/tcp
EXPOSE 3979/udp
VOLUME /config
```

`USER apps` is the final line before `COPY`. Base graphics: UNVERIFIED whether the tarball ships them; if not, `start.sh` downloads them into `/config` on first start only.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "openttd" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=OpenTTD/OpenTTD versioning=loose
  default = "15.3"
}

variable "LICENSE" { default = "GPL-2.0-or-later" } // UNVERIFIED, confirm against COPYING
variable "SOURCE" { default = "https://github.com/OpenTTD/OpenTTD" }
```

Then the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`. The `Dockerfile` `ARG VERSION` must equal `15.3`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/OpenTTD/OpenTTD"
ports:
  - port: 3979
    protocol: tcp
    required: true
  - port: 3979
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only add env vars that `start.sh` actually reads (for example a game-parameters or port override) with defaults matching `start.sh`. The admin port 3977 is not listed (UNVERIFIED). Dependencies: none.

## 7. start.sh

Plan, to be confirmed against the upstream `start.sh` (not fetched):

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/saves /config/content_download
port="${OPENTTD_PORT:-3979}"   # name to be confirmed, only if the app reads it
cd /app/openttd
exec ./openttd -D "0.0.0.0:${port}" -c /config/openttd.cfg -X    # flags UNVERIFIED against 15.3 --help
```

Rules: idempotent; seed `/config/openttd.cfg` only when missing (`openttd -c` writes it on first run; if the binary needs a template, copy it from `/app` only when `/config` lacks it). Bind to all interfaces (`0.0.0.0`), not localhost. Caches under `/tmp`. Never write to `/app`. Final `exec` for signal handoff. The exact flag names must be checked with `./openttd --help` in the built image before the script is finalised.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '3979'
filePaths:
- /app/openttd/openttd
- /start.sh
- /usr/share/licenses/openttd/COPYING
```

Every port in `settings.yaml` needs a probe. The UDP 3979 probe is UNVERIFIED because `tcp` cannot test UDP; check whether forgetool offers a udp check, and if not, record the gap in the PR. `timeoutSeconds` 120 is a starting point, compare with a sibling game server (for example `apps/steamcmd`-based ones) before finalising.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/serverdata` (DATA_DIR, server files, saves, graphics) | `/config` (`saves`, `openttd.cfg`, downloaded graphics) |
| `/serverdata/serverfiles` (SERVER_DIR) | `/app/openttd` is read-only; nothing written there |
| gotty web console (`ENABLE_WEBCONSOLE`, port UNVERIFIED) | Not carried over; out of scope for the first version |
| Process runs as root with `UID=99` / `GID=100` (upstream) | `USER apps` (per repo rule) |

Draft security expectations, reconciled: the TrueCharts chart sets `runAsUser 0`, but the image runs as `apps`, so the chart values need `runAsUser` removed or set to the apps UID (UNVERIFIED value). `readOnlyRootFilesystem` is compatible with `--read-only --tmpfs /tmp` once all writes go to `/config` and `/tmp`. Not privileged. Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- Version mismatch: amd64 is 15.3 (tarball), arm64 is apt 15.1 (draft). Players on different hosts see different versions and may fail to join. Resolve by pinning apt to 15.3 if Ubuntu provides it, or by building arm64 from source (not planned here; UNVERIFIED that apt has 15.3).
- arm64 availability: no tarball is listed; the apt package is the only path (UNVERIFIED).
- Base graphics: the draft says they are downloaded at first start into `/config`. UNVERIFIED (upstream `start.sh` not read); if they are needed and fetched at runtime, the download URL and checksum must be recorded before shipping.
- Game port 3979 needs TCP and UDP forwarding (draft, UNVERIFIED that UDP is required by the protocol).
- Admin port 3977: draft inferred; unlisted until verified; if real, it should be password protected or restricted.
- Blockers: none that prevent a build. Verify the arm64 apt route and the graphics download before the PR.

## 11. Build and test steps

```sh
cd apps/openttd
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name openttd-probe --read-only --tmpfs /tmp \
  -v openttd-probe-config:/config openttd:15.3
docker logs -f openttd-probe
forgetool containers test --image openttd:15.3 --config ./apps/openttd/container-test.yaml
docker rm -f openttd-probe; docker volume rm openttd-probe-config
```

Readiness signal (expected, to confirm in the first run): a line containing the bound port or `Network: server started`-style text (UNVERIFIED exact wording). The process must still be running after the startup window. Also run once with an existing `/config` to confirm idempotence. arm64 is not built locally unless the failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-openttd`, commit and PR title `feat(openttd): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- State honestly what is untested: arm64 build and run, UDP probe coverage, graphics download, the admin port.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; checksum matches the release page.
