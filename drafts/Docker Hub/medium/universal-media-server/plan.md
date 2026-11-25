# universal-media-server — implementation plan
> Source: ./draft.md · Target: apps/universal-media-server/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 15.9.0 (GitHub latest, published 2026-10-05T20:07:03Z). Docker Hub also has 15.10.0 (last_updated 2026-11-15); its GitHub release was not checked. UNVERIFIED: 15.10.0 asset names. |
| Renovate | `datasource=github-releases depName=UniversalMediaServer/UniversalMediaServer` (tags have no `v` prefix; semver-compatible) |
| License | GPL-2.0 (GitHub license API). The SPDX form for `LICENSE` in `docker-bake.hcl` needs checking against the repo LICENSE file: UNVERIFIED whether it is `GPL-2.0-only` or `GPL-2.0-or-later`. |
| Source URL | https://github.com/UniversalMediaServer/UniversalMediaServer |
| Download amd64 | `UMS-Linux-15.9.0-x86_64.tgz` https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/15.9.0/UMS-Linux-15.9.0-x86_64.tgz (preferred: an AppImage needs FUSE). Also `UMS-Linux-15.9.0-x86_64.AppImage` (same release). |
| Download arm64 | `UMS-Linux-15.9.0-arm64.tgz` https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/15.9.0/UMS-Linux-15.9.0-arm64.tgz |
| Checksum source | None. The 15.9.0 release has no SHA256SUMS asset. Mitigation in section 4 (pin by tag URL, record the observed sha256 in the PR). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/UniversalMediaServer/UniversalMediaServer/main/src/main/external-resources/docker/Dockerfile (main branch, not the 15.9.0 tag: UNVERIFIED that it matches the tag). Single stage `FROM ubuntu:22.04`; `apt-get install coreutils ffmpeg mediainfo openjdk-17-jre-headless iputils-ping mplayer fonts-dejavu`; `ENV UMS_PROFILE=/profile`; `ENV JDK_JAVA_OPTIONS=...`; `VOLUME /media`, `VOLUME /profile`; `EXPOSE 1900/udp 5001/tcp 5353/udp 9001/tcp 9002/tcp`; no USER (root); `ENTRYPOINT ["java","-jar","ums.jar"]`. |
| Published image | Docker Hub `universalmediaserver/ums` has linux amd64 and arm64 for latest, 15.10.0, 15.9.0 (https://hub.docker.com/v2/repositories/universalmediaserver/ums/tags/). So `copy-from arm64` is available. The draft's `copy-from arm64: no` is WRONG. This plan does not use `COPY --from` (the release tgz is used instead). |
| Ports | Upstream EXPOSE: 1900/udp (SSDP), 5001/tcp, 5353/udp (mDNS), 9001/tcp (web UI), 9002/tcp. The draft missed 5353/udp and 9002/tcp. Purpose of 5001 and 9002: UNVERIFIED. |
| Data path | Upstream: `UMS_PROFILE=/profile` (profile dir with UMS.conf and state). Chart mounts `/root/.config/UMS/` (draft). |

## 2. Target layout

- `apps/universal-media-server/Dockerfile`
- `apps/universal-media-server/docker-bake.hcl`
- `apps/universal-media-server/settings.yaml`
- `apps/universal-media-server/container-test.yaml`
- `apps/universal-media-server/start.sh`
- `apps/universal-media-server/defaults/UMS.conf`: only if the release tgz or upstream repo provides a default profile config; seeds `/config/profile/UMS.conf` when missing. UNVERIFIED whether such a file exists. If not, skip `defaults/` entirely.

No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`

Fits because UMS is a Java 17 jar and the base already provides the JRE, so the upstream `openjdk-17-jre-headless` package is not installed. Closest sibling: `apps/nzbhydra2` (Java jar from a GitHub release zip, `USER apps`, `/config` as WORKDIR and VOLUME). UNVERIFIED: whether the java17 base already includes ffmpeg or mediainfo (assumed no; checked at build time with `command -v`).

## 4. Dockerfile

1. `FROM` line from section 3. `ARG VERSION`, `ARG TARGETARCH`.
2. `ENV JDK_JAVA_OPTIONS="--add-modules=jdk.incubator.vector --add-opens java.base/sun.nio.ch=ALL-UNNAMED -Dfile.encoding=UTF-8 ..."`, copied verbatim from the upstream Dockerfile. UNVERIFIED: the rest of the flag list (truncated in the fetched summary); fetch the raw file again and copy it exactly.
3. `ENV UMS_PROFILE=/config/profile` (replaces upstream `/profile`, which is not writable and not persistent in this layout).
4. `USER root`.
5. `RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg mediainfo fonts-dejavu unzip && rm -rf /var/lib/apt/lists/*`. Drop `openjdk-17-jre-headless` (base has Java 17), `iputils-ping` (UNVERIFIED need; SSDP discovery does not need it), `mplayer` (UNVERIFIED need; leave out and test formats). Package versions are not pinned: ffmpeg is not tied to `VERSION`, so the pin rule does not apply here; note in the PR.
6. Download and extract, keyed on `TARGETARCH`:
   ```dockerfile
   RUN case "${TARGETARCH}" in amd64) arch=x86_64 ;; arm64) arch=arm64 ;; *) echo "unsupported ${TARGETARCH}" >&2; exit 1 ;; esac \
    && mkdir -p /app/ums /tmp/ums-src \
    && curl -fsSL -o /tmp/ums.tgz "https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/${VERSION}/UMS-Linux-${VERSION}-${arch}.tgz" \
    && tar -xzf /tmp/ums.tgz -C /tmp/ums-src \
    && cp -a /tmp/ums-src/. /app/ums/ \
    && rm -rf /tmp/ums.tgz /tmp/ums-src
   ```
   UNVERIFIED: the tgz internal layout (top-level folder, jar name). The plan assumes `ums.jar` at the top of the extracted tree; check with `tar -tzf` and adjust `start.sh` and `container-test.yaml` `filePaths` to match.
7. License: copy `LICENSE` from the extracted tree to `/usr/share/licenses/universal-media-server/LICENSE` if present (UNVERIFIED that the tgz ships it; otherwise fetch it from the repo tag and state that in the PR).
8. `RUN chown -R root:root /app && chmod -R 755 /app`. `/app` must stay read-only at runtime.
9. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`, `EXPOSE 9001/tcp 9002/tcp 5001/tcp 5353/udp 1900/udp`, `VOLUME /config`.

Media (`/media` in upstream) is not a ContainerForge volume. Users bind-mount their media paths; not listed in settings (see section 6).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "universal-media-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=UniversalMediaServer/UniversalMediaServer
  default = "15.9.0"
}

variable "LICENSE" {
  default = "GPL-2.0-only"   // UNVERIFIED: confirm against LICENSE file, see section 1
}

variable "SOURCE" {
  default = "https://github.com/UniversalMediaServer/UniversalMediaServer"
}
```
Then the standard `group "default"`, `target "image"`, `target "image-local"`, `target "image-all"` copied from `apps/nzbhydra2/docker-bake.hcl`. Validate with `docker buildx bake --print`. `ARG VERSION` in the Dockerfile must equal this default.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/UniversalMediaServer/UniversalMediaServer"
ports:
  - port: 9001
    protocol: tcp
    required: false
  - port: 9002
    protocol: tcp
    required: false
  - port: 5001
    protocol: tcp
    required: false
  - port: 5353
    protocol: udp
    required: false
  - port: 1900
    protocol: udp
    required: false
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
dependencies: []
```
Notes: no app-specific env vars are added, because none were confirmed as read by the app (`UMS_PROFILE` is set in the Dockerfile, not a user setting). Dependencies: none (`apps/java17` is the base, not a runtime dependency). Ports 5001 and 9002 stay until the build proves they listen; remove them only if they are not opened.

## 7. start.sh

```bash
#!/usr/bin/env bash

profile=/config/profile
mkdir -p "${profile}"

if [[ ! -f "${profile}/UMS.conf" && -f /defaults/UMS.conf ]]; then
    cp /defaults/UMS.conf "${profile}/UMS.conf"
fi

cd /config
exec java -jar /app/ums/ums.jar \
    --profile "${profile}" \
    "$@"
```
Points to check: UMS may not accept `--profile` (UNVERIFIED; `UMS_PROFILE` is the documented route, so drop the flag if the env var is enough). Idempotent: the profile is seeded only when missing. Nothing writes to `/app`. `cd /config` keeps UMS's relative writes (logs, caches; UNVERIFIED which ones) off `/app`. The web server must bind all interfaces (UNVERIFIED default; check with a probe from outside the container, per the start-script rule).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '9001'
- port: '9002'
- port: '5001'
http:
- port: '9001'
  path: /
filePaths:
- /app/ums/ums.jar
- /usr/share/licenses/universal-media-server/LICENSE
```
`timeoutSeconds: 180` matches the sibling `apps/changedetection` (Java/Python web start, not a fast sibling). The UDP ports (1900, 5353) cannot be checked by a `tcp` probe. UNVERIFIED whether forgetool supports a `udp` probe; if not, they stay in `settings.yaml` and the gap is recorded in the PR. The HTTP path `/` returning 200 is UNVERIFIED; confirm during the run. The `filePaths` entries depend on the tgz layout (section 4 step 6).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/profile` (upstream `UMS_PROFILE`, WORKDIR, UMS.conf) | `/config/profile` via `ENV UMS_PROFILE` |
| `/root/.config/UMS/` (chart PVC) | `/config/profile` (chart path is a root home directory; not reachable as apps user) |
| Relative writes from `/ums` (upstream WORKDIR) | `WORKDIR /config` |
| JVM temp, tmp files | `/tmp` (`--tmpfs /tmp` in the protocol run) |
| `/media` (upstream VOLUME, media library) | not remapped; user bind mount, read-only is fine |

Draft expectations reconciled:
- Chart: UID 0 (`runAsUser 0`). Image: `USER apps` (568), so UID 0 is not required. Chart overrides need the user to change the mount ownership of an existing `/root/.config/UMS` PVC.
- Chart: `readOnlyRootFilesystem: false`. Image target: compatible with `--read-only --tmpfs /tmp`, to be proven by the run in section 11.
- Chart: not privileged. Image: not privileged.
- Migration for existing users: data from the chart's `/root/.config/UMS` must be copied into `/config/profile`. Document this in the PR.

## 10. Risks, caveats and open questions

- SSDP (1900/udp) and mDNS (5353/udp) discovery need multicast. In a bridged container DLNA clients often do not find the server (draft caveat, confirmed as the usual limitation; not tested). Host networking is the usual workaround; it is out of the default setup.
- No checksum is published for the release tgz. The PR must say so.
- arm64 is a tgz, amd64 is also a tgz (the AppImage is not used). The arm64 path is built from the same version and is UNTESTED here.
- ffmpeg is installed from apt and not pinned. Transcoding is CPU heavy (draft caveat). Hardware transcoding is not set up.
- The upstream image runs as root with mplayer and iputils-ping. Dropping them may break some format or discovery paths: UNVERIFIED. Re-add only if a test or a log shows the need.
- The draft's claim that amd64 is an AppImage only is wrong: the tgz is the simpler path.
- Blockers: none known (not musl-only, no GPU requirement, no privileged need, arm64 release exists). The open points are the tgz layout, the `--profile` flag, and whether UMS binds 0.0.0.0.

## 11. Build and test steps

```sh
cd apps/universal-media-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ums-probe --read-only --tmpfs /tmp \
  -v ums-probe-config:/config universal-media-server:15.9.0
docker logs -f ums-probe
forgetool containers test --image universal-media-server:15.9.0 \
  --config ./apps/universal-media-server/container-test.yaml
docker rm -f ums-probe; docker volume rm ums-probe-config
```
Expected readiness signal: UNVERIFIED exact log line. Look for the web server start on port 9001 and for the process staying alive. Also: after start, `/config/profile/UMS.conf` must exist, and a restart must keep it. Probe 9001 from the host with `-p 9001:9001` to prove it is not bound to localhost only.

## 12. PR checklist

- Branch `feat/add-universal-media-server`; commit and PR title `feat(universal-media-server): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested: arm64 build and run, UDP discovery, the tgz layout until built, the HTTP probe status, checksum (none published).
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no test assertion was weakened.
- Downstream: not used as a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
