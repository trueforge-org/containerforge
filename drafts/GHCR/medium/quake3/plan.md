# quake3 — implementation plan
> Source: ./draft.md · Target: apps/quake3/ · Difficulty: medium · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Engine: ioquake3 (source repo has no release check done in this run). Draft says `apt:ioquake3`. Latest ioquake3 version and the Ubuntu 26.04 package version are UNVERIFIED (not fetched). Draft image tag is `ghcr.io/ich777/quake3:latest` (rolling, not a version). |
| Renovate | UNVERIFIED. If the apt package is pinned (preferred, see section 4), use a renovate `datasource=repology` or `docker`-style annotation once the version is confirmed. Do not invent a datasource. |
| License | GPL-2.0 (GitHub API `license` for https://github.com/ioquake/ioq3 is GPL-2.0, default branch `main`, last push 2026-11-04, not archived; https://api.github.com/repos/ioquake/ioq3). Use `LICENSE = "GPL-2.0"`. Game data is not under this license and is not shipped (see section 10). |
| Source URL | https://github.com/ioquake/ioq3 |
| Per-arch download | Draft: `apt:ioquake3` for amd64 and arm64 (apt package availability on Ubuntu 26.04 for both arches: UNVERIFIED). |
| Checksum source | apt repository signature (Ubuntu archive signing). Game data zips: no checksum fetched (UNVERIFIED). |
| Upstream image Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-quake3/master/Dockerfile . FROM `ich777/debian-baseimage` (Debian), apt `screen unzip lib32z1` (i386 enabled), env `DATA_DIR=/quake3`, `GAME_PARAMS="+set sv_punkbuster 0 +set fs_game osp +set com_hunkMegs 32"`, `Q3_PORT=27960`, `Q3_MAP=q3dm0`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=quake3`. No EXPOSE, no VOLUME, no USER instruction (root). ENTRYPOINT `/opt/scripts/start.sh`. |
| Game data URLs (upstream) | `https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/linux/linuxq3apoint-1.32b-3.x86.run` and `https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/quake3-1.32c.zip` (downloaded by upstream scripts, not fetched here). Not used by this plan (see section 4). |
| Ports | 27960 game server (`Q3_PORT`, env default). Protocol UDP per draft; the upstream Dockerfile has no EXPOSE, so UDP is not confirmed on a fetched page (UNVERIFIED). |
| Data path | Upstream `DATA_DIR=/quake3`. Remapped to `/config` (section 9). |
| Upstream start script | `/opt/scripts/start.sh` (not fetched, UNVERIFIED contents). |

## 2. Target layout

- `apps/quake3/Dockerfile`
- `apps/quake3/docker-bake.hcl`
- `apps/quake3/settings.yaml`
- `apps/quake3/container-test.yaml`
- `apps/quake3/start.sh`

Not needed: `defaults/` (no config seed beyond what the server writes at first start; add only if the server config must be seeded), `etc/`, `health/`, `root/` (never used). `DOWNSTREAM_CHANGES.md` not needed (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, both build and final stage (the draft says "ubuntu alone is enough"). The upstream base is Debian; ubuntu is the ContainerForge rule for generic userland. Closest sibling: `apps/steamcmd` (game server, data under `/config`) and `apps/adguardhome-sync` (simple ubuntu runtime). No dependency container.

## 4. Dockerfile

Single ubuntu stage is enough: the engine comes from apt, no build step.

1. `ARG VERSION` (apt version of `ioquake3`, pinned; see section 10) and `ARG TARGETARCH`.
2. `USER root`.
3. `RUN apt-get update && apt-get install -y --no-install-recommends ioquake3=${VERSION} unzip && rm -rf /var/lib/apt/lists/*` (pin the package and check the pinned version against `docker-bake.hcl`; `apps/valkey` passes the apt version as a separate `PACKAGE_VERSION` build arg next to `VERSION`). If the exact-version pin is not available on 26.04, record the chosen version and why.
4. Do NOT install `lib32z1` or enable i386: the ubuntu base does not need i386 for the native engine (UNVERIFIED: confirm the engine runs without i386 libs on amd64).
5. Do NOT download the id Software zips in the image. Game pak files are supplied by the user (see section 10). Remove the upstream download logic entirely.
6. License: `COPY` or `install` the engine's `COPYING` file to `/usr/share/licenses/quake3/COPYING` (source of the GPL text: ioq3 repo, UNVERIFIED path).
7. Tail:

```dockerfile
ENV HOME=/config \
    Q3_PORT=27960 \
    Q3_MAP=q3dm0

USER apps
COPY --chmod=0755 . /

EXPOSE 27960/udp
VOLUME /config
```

`EXPOSE 27960/udp` is only added if UDP is confirmed in section 1 (it is not yet); otherwise document the port in `settings.yaml` only.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "quake3"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=ioquake3 (pin the Ubuntu package version here once confirmed)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/ioquake/ioq3"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

`VERSION` must be a real pinned apt version before the file is final; the placeholder above is not valid for `docker buildx bake --print` tags and must be replaced in the build step. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ioquake/ioq3"
ports:
  - port: 27960
    protocol: udp
    required: true
env:
  - name: Q3_PORT
    default: "27960"
    required: false
  - name: Q3_MAP
    default: "q3dm0"
    required: false
  - name: GAME_PARAMS
    default: "+set sv_punkbuster 0 +set fs_game osp +set com_hunkMegs 32"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only variables the new `start.sh` reads are listed. `GAME_PARAMS` is kept only if the new start script uses it; `fs_game osp` is the upstream default for the OSP mod and is an upstream choice to confirm (UNVERIFIED use). `UMASK`, `UID`, `GID`, `DATA_PERM`, `USER` are ich777 wrapper options and are NOT added (ContainerForge runs as `apps`; these would be silently ignored).

## 7. start.sh

- `#!/usr/bin/env bash`, idempotent.
- `mkdir -p /config/serverfiles` (or chosen layout); seed nothing by default.
- Server files and pak files live under `/config` (`fs_homepath` or `+set fs_homepath /config`, UNVERIFIED flag name for ioquake3 on Linux; confirm in the build).
- Caches and scratch under `/tmp`.
- Bind: the server listens on all interfaces by default; confirm with `+set net_ip 0.0.0.0` only if the server binds elsewhere (UNVERIFIED).
- Start the dedicated server in the foreground and `exec` it, e.g. `exec ioq3ded +set dedicated 2 +set net_port "${Q3_PORT}" +map "${Q3_MAP}" ${GAME_PARAMS}` (binary name `ioq3ded` UNVERIFIED for the apt package; confirm with `dpkg -L ioquake3`).
- If no pak files are present, the server may still start (test runs with no pak files): the log must show readiness without them. Do not add a fake pak.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /usr/games/ioq3ded
- /usr/share/licenses/quake3/COPYING
```

- No UDP probe: the container-test schema (checked 2026-11-26) has only `http`, `tcp`, `healthCommands`, `filePaths`, `mainRunner`, `runners`, `readOnlyRootfs`, `mounts`, `timeoutSeconds`, with no `udp` key. The server opens no TCP port, so port 27960/udp has no probe by design. State this gap in the PR; optionally add a `healthCommands` check once the syntax is read from the schema. Do not invent a schema key.
- `filePaths` binary path is UNVERIFIED until `dpkg -L ioquake3` is run.
- `timeoutSeconds` 60 is an estimate; align with sibling game server apps (`apps/steamcmd`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/quake3` (`DATA_DIR`, server files, configs, logs) | `/config` (VOLUME); `fs_homepath` or equivalent pointed at `/config` |
| `/tmp` scratch | keep `/tmp` |
| Upstream `USER quake3` (created but not used, container runs as root) | `USER apps` (UID 568 in ContainerForge base). Upstream `runAsUser 0` override in the TrueCharts chart is not needed. |
| `UMASK`/`DATA_PERM`/`UID`/`GID` (wrapper ownership logic) | dropped |

Target: non-root yes, read-only-rootfs yes (test with `--read-only --tmpfs /tmp`), privileged no. Reconciling the draft: draft expects non-root no and read-only-rootfs no; this plan changes both targets and must be verified in step 11.

## 10. Risks, caveats and open questions

- Game data: the original Quake III pak files (`pak0.pk3` etc.) are NOT shipped and must be supplied by the user from a legitimately owned copy. The upstream image downloads id Software zips (`quake3-1.32c.zip`) at runtime from `ftp.gwdg.de`. This plan does NOT redistribute or fetch game data; a user-supplied pak path is the only source. Do not add pak files to the image.
- The apt `ioquake3` package version on Ubuntu 26.04 (both arches) is UNVERIFIED. Until it is confirmed, `VERSION` in bake is a placeholder and the build cannot be pinned.
- ioquake3 apt package on arm64: UNVERIFIED. Draft says yes; treat as unconfirmed.
- Draft claimed UDP 27960 only; the upstream Dockerfile does not declare EXPOSE, so the protocol is taken from the game (UDP, standard Quake III), not from a fetched page: UNVERIFIED on the page.
- Draft image is `latest` and rolling; this plan does not use it.
- `GAME_PARAMS` fs_game `osp` is an upstream choice; it requires OSP mod data that is not in the image (UNVERIFIED whether the server refuses to start without it; if it does, the test must use the default game).
- `ich777/debian-baseimage` upstream base is Debian; ubuntu base may change apt package naming (UNVERIFIED).
- No blockers identified beyond the unverified package availability. Not musl, no GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/quake3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name quake3-probe --read-only --tmpfs /tmp \
  -v quake3-probe-config:/config quake3:<VERSION>
docker logs -f quake3-probe

forgetool containers test --image quake3:<VERSION> --config ./apps/quake3/container-test.yaml

docker rm -f quake3-probe; docker volume rm quake3-probe-config
```

Expected readiness: ioq3ded prints its startup banner and the server is running (exact text UNVERIFIED until the binary is run). Confirm UDP 27960 is open from outside the container (`-p 27960:27960/udp`), and that a restart with the same `/config` volume starts cleanly.

## 12. PR checklist

- Branch `feat/add-quake3`, commit and PR title `feat(quake3): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Downstream: none.
- Not tested to state honestly: the apt version pin, arm64, the UDP probe (schema support), the game with user-supplied pak files, and the `fs_homepath` remap.
- `docker buildx bake --print` passes and `VERSION` is a real pinned version matching the Dockerfile input.
