# ps3netsrv — implementation plan
> Source: ./draft.md · Target: apps/ps3netsrv/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `20261110` (GitHub release tag, published 2026-11-10). Draft tag `v2.0.1` is the shawly Docker wrapper tag, not an upstream version. |
| Renovate | `datasource=github-releases depName=aldostools/ps3netsrv versioning=loose` (tags are dates, older ones have letter suffixes such as `20240210a`) |
| License | `GPL-3.0-or-later`. GitHub reports NOASSERTION, but `LICENSE.TXT` states GPL v3 "or (at your option) any later version". |
| Source | https://github.com/aldostools/ps3netsrv (draft also lists the webMAN-MOD subtree, which is the older copy) |
| amd64 download | `https://github.com/aldostools/ps3netsrv/releases/download/20261110/ps3netsrv_20261110_linux.zip`. It holds `ps3netsrv_20261110/ps3netsrv_ubuntu-latest_amd64.deb`, whose `usr/local/bin/ps3netsrv` is a statically linked x86-64 ELF (checked with `file`/`readelf`: no NEEDED libs). The zip also holds distro `.deb/.rpm` files and a `makeiso` binary, which we do not ship. |
| arm64 | No prebuilt binary. Build from the tag tarball `https://github.com/aldostools/ps3netsrv/archive/refs/tags/20261110.tar.gz` with `make -f Makefile.linux` (bundled PolarSSL AES, `BUILD_TYPE = release_static`, needs only gcc/g++/make). |
| Checksum | No checksum file is published. GitHub shows an asset digest: `ps3netsrv_20261110_linux.zip` = `sha256:47b8cb4dfdd6aabad011cefaf4e27e36e4f2d3d4e796b76472fc0b86b296b081` (I downloaded it and the sha256 matches). Tag tarball sha256 (computed by me) `1fb045b529ecab451e07b49aac6e15f6558d71fc01ec3e328f0405fddafde90c`. |
| Upstream Dockerfile reviewed | https://github.com/shawly/docker-ps3netsrv (alpine.Dockerfile, master): builds on alpine/musl with s6-overlay; env `PS3NETSRV_PORT=38008`, `PS3NETSRV_WHITELIST`, `PS3NETSRV_BINARY`; volume `/games`; EXPOSE 38008. The draft's pinned commit `0585a23` was not fetched. Only the idea is reused, not the musl binary. |
| CLI | `ps3netsrv [rootdirectory] [port] [whitelist]`, default port 38008, whitelist like `192.168.1.*` (README). The code binds `INADDR_ANY` (`src/main.cpp` line 99). |
| Other | The source has a `NO_UPDATE` define, so the release binary may contain an update check. UNVERIFIED: what it does at runtime. I did not run the binary (execution was blocked in this session). |

## 2. Target layout

```
apps/ps3netsrv/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
- No `defaults/`, `etc/`, `health/`: the server has no config file and no state.
- Not used as a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
- Never create `root/`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Used for both the build stage and the final stage. The binary is static on amd64 and built static on arm64, and the app needs no interpreter. Closest sibling: `apps/adguardhome-sync` (prebuilt binary, one process). Compile-in-stage pattern follows the Go rule (build stage, `COPY --from=` into the final ubuntu stage).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends build-essential unzip` (build stage only; arm64 needs the compiler, amd64 needs `unzip`; `dpkg-deb` and `curl` already come with the base). Clean `/var/lib/apt/lists`.
3. One `RUN` that does, by `TARGETARCH`:
   - `amd64`: download `ps3netsrv_${VERSION}_linux.zip`, verify its sha256 against the `digest` field of the GitHub release asset (`https://api.github.com/repos/aldostools/ps3netsrv/releases/tags/${VERSION}`, parsed with grep/sed), `unzip -j ... '*/ps3netsrv_ubuntu-latest_amd64.deb'`, `dpkg-deb -x` it, `install -D usr/local/bin/ps3netsrv /out/ps3netsrv`. Fallback if the API is rate-limited: pass the digest as a build arg (see section 10).
   - `arm64`: download the tag tarball, extract, `make -f Makefile.linux BUILD_DATE="${VERSION}"`, `install -D ps3netsrv /out/ps3netsrv`.
   - both: `curl -fsSL https://raw.githubusercontent.com/aldostools/ps3netsrv/${VERSION}/LICENSE.TXT -o /out/LICENSE.TXT`. Anything else: `exit 1` (unsupported arch).
4. Final stage `FROM <ubuntu>`, `ARG VERSION`, `USER root`:
   - `COPY --from=build /out/ps3netsrv /app/ps3netsrv`
   - `COPY --from=build /out/LICENSE.TXT /usr/share/licenses/ps3netsrv/LICENSE.TXT`
   - `RUN chmod 0755 /app/ps3netsrv && mkdir -p /games && chown apps:apps /games` (an empty `/games` must exist so the server starts under test with nothing mounted).
5. `ENV HOME=/tmp` is not needed (no home writes), so no extra ENV. Do not add `VOLUME /config`: the app keeps no state (see section 9). Declare `VOLUME /games` only if wanted; leave it out to avoid anonymous volumes.
6. `USER apps`, then `COPY --chmod=0755 . /`, `EXPOSE 38008`.
7. Do not pin apt versions: nothing is installed in the final stage.

## 5. docker-bake.hcl

Copy the standard file from `apps/adguardhome-sync`, with:
```hcl
variable "APP" { default = "ps3netsrv" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=aldostools/ps3netsrv versioning=loose
  default = "20261110"
}
variable "LICENSE" { default = "GPL-3.0-or-later" }
variable "SOURCE"  { default = "https://github.com/aldostools/ps3netsrv" }
```
Plus `target "docker-metadata-action" {}`, `group "default"`, targets `image` (args.VERSION + OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/aldostools/ps3netsrv"
ports:
  - port: 38008
    protocol: tcp
    required: false
env:
  - name: PS3NETSRV_PORT
    default: "38008"
    required: false
  - name: PS3NETSRV_WHITELIST
    default: ""
    required: false
volumes:
  - path: /games
    required: true
dependencies: []
```
The two env names are read by `start.sh` (they follow the shawly image; upstream itself takes positional args). `/config` is not listed because nothing is persisted. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

port="${PS3NETSRV_PORT:-38008}"
args=(/games "$port")
if [[ -n "${PS3NETSRV_WHITELIST:-}" ]]; then
  args+=("$PS3NETSRV_WHITELIST")
fi

echo "Starting ps3netsrv on port ${port}, serving /games"
exec /app/ps3netsrv "${args[@]}"
```
Idempotent, writes nothing, no `/config` needed, binds all interfaces (the code uses `INADDR_ANY`). Stdout from a static binary under a pipe may be fully buffered, and `stdbuf` does not work on static binaries, so log lines can appear late. This is cosmetic. Readiness is judged by the open port.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '38008'
filePaths:
- /app/ps3netsrv
- /usr/share/licenses/ps3netsrv/LICENSE.TXT
```
No env vars needed. No `timeoutSeconds` (sibling `adguardhome-sync` sets none; the server starts instantly). The whitelist path is not covered by the test, so run it by hand (section 11).

## 9. Rootless and read-only-rootfs adaptations

- Upstream write paths: none by design. Remote mkdir/delete/create commands from the PS3 write into the games share (code in `process_mkdir_cmd` and friends). The draft mounts `/games` read-only, which makes those fail cleanly. A writable mount is the user's choice.
- The chart runs UID/GID 0 with `readOnlyRootFilesystem: false`. The plan runs as `apps` (568) with a read-only rootfs and needs no root: the port is above 1024 and `/tmp` is not used. Mounted game folders must be readable by UID 568 (or group 568), which is a deployment note.
- Privileged: no. Extra persistence: only `/games` (chart mount), not `/config`.

## 10. Risks, caveats and open questions

- Draft caveats kept: arm64 is a source build and untested; `/games` must be mounted from the host; 38008/tcp must reach the PS3 on the LAN (host or published port).
- The `ps3netsrv_ubuntu-latest_amd64.deb` inside the zip is a static ELF today. If upstream ever changes that, re-check with `file`.
- Checksum: there is no upstream checksum file. The GitHub API `digest` field is read at build time, so an API rate limit (60 requests per hour unauthenticated) can fail the build. Fallback: a `ZIP_SHA256` build arg pinned in the Dockerfile, bumped with each version. Renovate cannot update it.
- UNVERIFIED: runtime behaviour of the binary (update check, behaviour when `/games` is empty), arm64 compile result, and that the tag tarball has `Makefile.linux` at its root (it does, I extracted it).
- No blockers: no musl-only binary (we do not use the alpine one), no GPU, no privilege.

## 11. Build and test steps

```sh
cd apps/ps3netsrv
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ps3netsrv-probe --read-only --tmpfs /tmp ps3netsrv:20261110
docker logs ps3netsrv-probe        # expect the ps3netsrv banner / listening text, container still running
docker exec ps3netsrv-probe bash -c 'exec 3<>/dev/tcp/127.0.0.1/38008 && echo open'
docker rm -f ps3netsrv-probe
forgetool containers test --image ps3netsrv:20261110 --config ./apps/ps3netsrv/container-test.yaml
```
Also run once with `-e PS3NETSRV_WHITELIST='192.168.1.*' -v <dir>:/games:ro`. There is no `/config` volume to create. Also try `--platform linux/arm64` once, to check the compile path. Readiness signal: process alive and port 38008 open.

## 12. PR checklist

- Branch `feat/add-ps3netsrv`, commit and PR title `feat(ps3netsrv): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, tick only what applies. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows the status).
- State what is untested at PR time: the amd64 build, the arm64 compile, runtime behaviour and the forgetool run, unless run. Do not tick "Built container locally" if not built.
- Pre-completion: `bake --print` passes; versions align (`VERSION` 20261110 in bake and Dockerfile arg); no `root/`.
