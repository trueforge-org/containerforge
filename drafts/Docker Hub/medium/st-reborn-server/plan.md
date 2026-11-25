# st-reborn-server — implementation plan
> Source: ./draft.md · Target: apps/st-reborn-server/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.8.4` (tag `v1.8.4`, published 2026-10-22). Latest release; matches the draft's `docker.io/tiltedphoques/st-reborn-server:1.8.4`. Source: `gh api repos/tiltedphoques/TiltedEvolution/releases/latest` |
| Docker Hub tag | `tiltedphoques/st-reborn-server:1.8.4`, last updated 2026-10-22; amd64 and arm64 images published. Source: https://hub.docker.com/v2/repositories/tiltedphoques/st-reborn-server/tags/1.8.4 |
| Renovate | `datasource=github-releases depName=tiltedphoques/TiltedEvolution versioning=semver` (tags carry a `v` prefix; the Dockerfile strips it when building the URL). |
| License | UNVERIFIED: GitHub reports `NOASSERTION` (no SPDX detected). Read the repository `LICENSE` file before setting `LICENSE` in `docker-bake.hcl`. |
| Source URL | https://github.com/tiltedphoques/TiltedEvolution |
| Download (amd64) | https://github.com/tiltedphoques/TiltedEvolution/releases/download/v1.8.4/SkyrimTogetherServer-1.8.4-linux-amd64.tar.gz |
| Download (arm64) | https://github.com/tiltedphoques/TiltedEvolution/releases/download/v1.8.4/SkyrimTogetherServer-1.8.4-linux-arm64.tar.gz |
| Checksum source | UNVERIFIED: no `.sha256` or `SHA256SUMS` asset in the release listing. Checksum verification cannot be done against an upstream file; record the sha256 of each tarball in the Dockerfile after downloading it once, and say so in the PR. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/tiltedphoques/TiltedEvolution/v1.8.4/Dockerfile: builder `debian:12` (xmake build), runtime `debian:12-slim`, `WORKDIR /st-server`, copies `libSTServer.so` and `SkyrimTogetherServer` from `/src/package`, `ENTRYPOINT ["./SkyrimTogetherServer"]`, `EXPOSE 10578/udp`. No `USER`, no `VOLUME`, no runtime `ENV`, no `CMD`. |
| Ports | UDP `10578` (only port in the upstream Dockerfile). |
| Env vars | UNVERIFIED: none documented in the fetched material. The config format and any env overrides were not fetched. |
| Data and config paths | UNVERIFIED: upstream write paths were not documented in the fetched material. The draft's `/home/server/Data`, `/home/server/logs` and `/home/server/config` are chart paths, not upstream paths. |
| Dependencies | None in the Dockerfile. The game client needs a legally owned Skyrim copy; that is client-side and not part of this container (draft caveat, not verified on a fetched page). |
| arm64 | Yes: linux-arm64 tarball and arm64 Docker Hub image are published. |
| Copy-from images | amd64 `tiltedphoques/st-reborn-server:1.8.4` exists, but it is built by upstream on `debian:12-slim` (glibc). The draft marks copy-from arm64 as `no`, and the Hub metadata agrees. Use the release tarballs, not `COPY --from`. |

## 2. Target layout

- `apps/st-reborn-server/Dockerfile`
- `apps/st-reborn-server/docker-bake.hcl`
- `apps/st-reborn-server/settings.yaml`
- `apps/st-reborn-server/container-test.yaml`
- `apps/st-reborn-server/start.sh`

No `defaults/`, `etc/` or `health/` (no seeded config is confirmed; add `defaults/` only once the config file format is verified). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (the same `FROM` line as the 92 existing ubuntu-based apps; the `26.04` tag form is used by the `adguardhome-sync` sibling).

Why it fits: the upstream runtime is a glibc `debian:12-slim` image, and the release is a prebuilt tarball. Ubuntu 26.04 provides glibc and `libssl3`, so no runtime stack is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball unpacked into `/app` on ubuntu, `TARGETARCH` in the URL).

## 4. Dockerfile

Single stage, no compile:

1. `ARG VERSION` (must equal the bake default `1.8.4`) and `ARG TARGETARCH`. Upstream asset names use `amd64` and `arm64`, which match `TARGETARCH` directly.
2. `USER root` for the install step.
3. Download and unpack, based on the `adguardhome-sync` pattern:
   ```dockerfile
   RUN echo "*** Installing SkyrimTogetherServer ***" && \
     mkdir -p /app/st-server && \
     curl -fsSL -o /tmp/st-server.tar.gz \
       "https://github.com/tiltedphoques/TiltedEvolution/releases/download/v${VERSION}/SkyrimTogetherServer-${VERSION}-linux-${TARGETARCH}.tar.gz" && \
     tar -xzf /tmp/st-server.tar.gz -C /app/st-server && \
     rm /tmp/st-server.tar.gz && \
     chown -R apps:apps /app && chmod -R 755 /app
   ```
   UNVERIFIED: the internal layout of the tarball (whether `SkyrimTogetherServer` and `libSTServer.so` sit at the top level or in a subdirectory). List the archive once and adjust the destination path before building.
4. Checksum: after the first download, record the sha256 of each arch tarball in the Dockerfile (`echo "<sha>  file" | sha256sum -c -`), since upstream publishes no checksum. Keep the values per `TARGETARCH` in a `case` block.
5. Licence: once the `LICENSE` file is read, extract it to `/usr/share/licenses/st-reborn-server/` (the tarball may or may not include one; UNVERIFIED).
6. `ENV HOME=/config` (siblings set this so tools that write to `$HOME` land on `/config`).
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 10578/udp
   VOLUME /config
   ```
   `EXPOSE` uses the `udp` protocol suffix as upstream does. Sibling UDP apps (`apps/emby`, `apps/jellyfin`, `apps/gluetun`) also declare UDP ports in `settings.yaml`.

No `apt-get` step is planned. Add `libssl3`-style packages only if `ldd` on the extracted binary reports a missing library (see section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "st-reborn-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tiltedphoques/TiltedEvolution versioning=semver
  default = "1.8.4"
}

variable "LICENSE" {
  default = "UNVERIFIED"  // set to the SPDX id from the upstream LICENSE file before committing
}

variable "SOURCE" {
  default = "https://github.com/tiltedphoques/TiltedEvolution"
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
Validate with `docker buildx bake --print` in `apps/st-reborn-server/`. The `LICENSE` placeholder must be replaced before the commit; do not leave it as `UNVERIFIED`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/tiltedphoques/TiltedEvolution"
ports:
  - port: 10578
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
volumes:
  - path: /config
    required: true
```
- No upstream env vars are listed: none were documented in the fetched material, and the rules forbid inventing them. Add any that the upstream config file or README turns out to read.
- `dependencies:` is omitted, since the server has no DB or other container dependency.
- `required: true` on the UDP port because the server is useless without it. Siblings mostly use `false`; keep `true` only if this matches the forgetool meaning (UNVERIFIED against the schema).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/logs

cd /config || exit 1
exec /app/st-server/SkyrimTogetherServer
```
- Idempotent: it only creates `/config/logs`, and seeds nothing.
- Nothing is written under `/app`.
- `exec` so the process gets signals (PID 1 with tini via the ubuntu base entrypoint).
- UNVERIFIED: whether the server needs its working directory to be the folder that holds `libSTServer.so`, and where it writes its config and data. Check on a real run (step 11). If it needs the folder, symlink the binary and library into `/config` at start rather than writing into `/app`.
- Binding: the server must listen on all interfaces, not only loopback. UNVERIFIED: the listen address is not in the fetched material. Confirm from the running process (`ss -ulpn`) and from outside the container.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /app/st-server/SkyrimTogetherServer
- /app/st-server/libSTServer.so
```
- UDP cannot be checked with the `tcp` or `http` primitives. The `tcp` probe in forgetool tests TCP ports only, so `10578/udp` has no probe. Add a probe only if forgetool supports UDP (UNVERIFIED). Do not invent a TCP check for a UDP port; the coverage rule is for ports the container opens, and that check would fail for the wrong reason.
- The file paths are an assumption based on the upstream `WORKDIR /st-server` layout and must match the tarball contents (section 4, step 3).
- No `runners` or `mainRunner` needed unless the server exits without a config; if it does, use the readiness log line from the first run and record the check in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Item | Adaptation |
| --- | --- |
| Upstream user | No `USER` in upstream, so it runs as root. Here: `USER apps` (UID 568) in the final stage. |
| `/app` | Read-only at runtime. The binary and library are extracted during the build and never written to at runtime. |
| `/config` | Persistent: logs and any config or data the server writes (paths UNVERIFIED; see section 7). |
| `/tmp` | Ephemeral: the build-time download goes to `/tmp` and is removed. No runtime cache is expected. |
| Chart `readOnlyRootFilesystem: true` | Compatible if the server writes only to `/config` and `/tmp`. Verify in step 11 with `--read-only --tmpfs /tmp`. |
| Chart paths `/home/server/Data`, `/home/server/logs`, `/home/server/config` | Remapped to `/config` (chart paths are not upstream paths). Existing chart users must move their data to `/config` once the upstream write paths are confirmed. |
| Privileged | No (draft: chart `privileged: false`, not overridden). Nothing in the upstream Dockerfile needs it. |
| UID | 568, from the draft's `runAsUser 568`, matching `apps` in the ubuntu base. |

## 10. Risks, caveats and open questions

- **Library check (draft caveat, still open):** run `ldd /app/st-server/SkyrimTogetherServer` and `ldd /app/st-server/libSTServer.so` in the built image. Any `not found` line is a blocker for this base. The upstream runtime is Debian 12 glibc, and the ubuntu base should be compatible, but this is not verified.
- **Read-only rootfs (draft caveat, still open):** the first run decides whether the server writes outside `/config` and `/tmp`.
- **Tarball layout:** the archive contents were not listed. Check before writing `filePaths`.
- **Checksum:** upstream publishes none; record the sha256 values in the Dockerfile (section 4, step 4) and note in the PR that they were computed locally, not taken from upstream.
- **Licence:** GitHub reports `NOASSERTION`; read the `LICENSE` file before setting `LICENSE` in bake.
- **Game data:** the draft says the server needs a legally owned Skyrim copy and data files. UNVERIFIED for the server side: the client needs them; whether the server container needs any game data file is not confirmed. Do not mount game data in the test.
- **Network reachability:** UDP 10578 must be reachable from players; NAT or firewall rules are the usual cause of "cannot connect" reports (draft, inferred).
- **Blockers:** none confirmed. No musl-only build (glibc), no GPU, no privileged need, arm64 published.

## 11. Build and test steps

```sh
cd apps/st-reborn-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name st-reborn-server-probe --read-only --tmpfs /tmp \
  -v st-reborn-server-probe-config:/config st-reborn-server:1.8.4
docker logs -f st-reborn-server-probe
docker exec st-reborn-server-probe ss -ulpn | grep 10578   # confirm the UDP listener (iproute2 may need to be present; if not, check /proc/net/udp)
docker rm -f st-reborn-server-probe; docker volume rm st-reborn-server-probe-config

forgetool containers test --image st-reborn-server:1.8.4 --config ./apps/st-reborn-server/container-test.yaml
```

Expected readiness signal: UNVERIFIED (the server's startup log text is not in the fetched material). Use the first real log line that names the listening port or "started", record it in the PR, and add it to the notes here. The process must stay running and the UDP listener on `10578` must be present.

Also run the empty-`/config` start twice (second start reuses the volume) and check the second start is clean.

Also run `ldd` (section 10) on the extracted binaries before the first run.

## 12. PR checklist

- Branch `feat/add-st-reborn-server`, commit `feat(st-reborn-server): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes; check only the boxes that apply.
- The Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed Contributor License Agreement (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only they can sign it, and the `license/cla` check shows status.
- Say in the PR what was not tested: UDP reachability from outside the container (no UDP probe), the arm64 build and runtime, the read-only rootfs run if not done, and the checksum values were computed locally.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; `LICENSE` set from the upstream file.
- Downstream: no `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
