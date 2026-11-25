# airsonic — implementation plan
> Source: ./draft.md · Target: apps/airsonic/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v10.6.2 (release tag). Published 2020-05-03. GitHub's latest release is still this one (https://api.github.com/repos/airsonic/airsonic/releases/latest). |
| Renovate | `datasource=github-releases depName=airsonic/airsonic versioning=semver` (the tag has a `v` prefix, which semver handles). |
| Upstream status | Repo is archived (`archived: true`), last pushed 2021-08-11 (https://api.github.com/repos/airsonic/airsonic). Expect no further releases. A fork, airsonic-advanced, exists; it is not checked here and is an open question (section 10). |
| License | GPL-3.0 (GitHub API, `license.spdx_id`). |
| Source URL | https://github.com/airsonic/airsonic |
| Download | WAR, arch-independent: https://github.com/airsonic/airsonic/releases/download/v10.6.2/airsonic.war |
| Checksum source | SHA-256 `94b17d6a7859a9c029dcbcdc672f4d49bd605bf46bdf74ac51ea0d593db67860 *airsonic.war`, from `artifacts-checksums.sha.asc` in the same release (https://github.com/airsonic/airsonic/releases/download/v10.6.2/artifacts-checksums.sha.asc). The file is PGP-signed; the signing key was not verified (UNVERIFIED). Use the hash and check it in the Dockerfile. |
| Per-arch | amd64 and arm64 both use the same WAR. The runtime is Java, so the arch comes from the base (`java17`). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-airsonic/f234e90a76a58bc74953236f891055c99c432e4a/Dockerfile: `FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic`; apt installs `ca-certificates ffmpeg flac fontconfig lame openjdk-8-jre ttf-dejavu` (`--no-install-recommends`); deletes `accessibility.properties`; `curl` of `airsonic.war` into `/app/airsonic`; `COPY root/ /`; `EXPOSE 4040`; `VOLUME /config /media /music /playlists /podcasts`. |
| Env vars (real) | `AIRSONIC_HOME=/app/airsonic`, `AIRSONIC_SETTINGS=/config`, `LANG=C.UTF-8` (same Dockerfile). |
| Ports | 4040 (upstream `EXPOSE`). |
| Data / config paths | `/config` (settings, database, state). Media: `/media`, `/music`, `/playlists`, `/podcasts` (upstream VOLUME). |
| Linuxserver image | `ghcr.io/linuxserver/airsonic:version-v10.6.2`; Hub amd64 digest `sha256:611c05dda8c8c7c86f5116e2343cf38f38fbb8595e90ba964e240f05f2746ef6` (https://hub.docker.com/v2/repositories/linuxserver/airsonic/tags/version-v10.6.2). |
| Java | Upstream uses `openjdk-8-jre`. UNVERIFIED that 10.6.2 runs on Java 17 (the draft assumes it). Test it on the build. |
| Dependencies | None (embedded database in `/config`, per draft). |

## 2. Target layout

- `apps/airsonic/Dockerfile`
- `apps/airsonic/docker-bake.hcl`
- `apps/airsonic/settings.yaml`
- `apps/airsonic/container-test.yaml`
- `apps/airsonic/start.sh`
- `etc/` only if a fontconfig file is needed (not expected). `defaults/` not needed.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`

The java17 image is itself on `ghcr.io/trueforge-org/ubuntu:26.4` (see `apps/java17/Dockerfile`), so the ubuntu base is inherited. Closest sibling: `apps/nzbhydra2` or `apps/airsonic-advanced` (Java WAR/JAR on java images; not re-read in this run). Only one stage is needed, because the WAR is downloaded and checked, not compiled.

## 4. Dockerfile

1. `ARG VERSION=v10.6.2`, `ARG WAR_SHA256=94b17d6a7859a9c029dcbcdc672f4d49bd605bf46bdf74ac51ea0d593db67860`.
2. `USER root`.
3. Install the media tools the upstream image shipped, with no recommends: `ffmpeg flac lame fontconfig fonts-dejavu-core`. Versions are not pinned to `VERSION` (they are not airsonic versions). Record the resolute archive versions in the PR (UNVERIFIED that all five exist on 26.04; check on the build).
4. Download and verify the WAR:
   ```sh
   curl -fL -o /tmp/airsonic.war \
     "https://github.com/airsonic/airsonic/releases/download/${VERSION}/airsonic.war"
   echo "${WAR_SHA256}  /tmp/airsonic.war" | sha256sum -c -
   install -d -o apps -g apps /app/airsonic
   mv /tmp/airsonic.war /app/airsonic/airsonic.war
   ```
5. License: ship the GPL-3.0 text at `/usr/share/licenses/airsonic/LICENSE`, taken from the upstream source at the `v10.6.2` tag. UNVERIFIED: the file path in the repo. The `master` raw URL returned 404, so check it against the tag before building.
6. Clean: `apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*`.
7. Environment that keeps state off `/app` and `/tmp` only for scratch:
   `ENV AIRSONIC_HOME=/app/airsonic AIRSONIC_SETTINGS=/config LANG=C.UTF-8 JAVA_TOOL_OPTIONS=-Djava.io.tmpdir=/tmp`.
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 4040
   VOLUME /config /media /music /playlists /podcasts
   ```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "airsonic" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=airsonic/airsonic versioning=semver
  default = "v10.6.2"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/airsonic/airsonic" }
```

Standard targets and default group copied from `apps/adguardhome-sync` (or the java17 sibling for the `image` args, `MAJOR` is not needed here). `VERSION` must match the Dockerfile `ARG`. `LICENSE` is GPL-3.0 per the GitHub API; the exact SPDX id ("-only" or "-or-later") is UNVERIFIED and must be confirmed from the repo's `LICENSE` file before use. Check with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/airsonic/airsonic"
ports:
  - port: 4040
    protocol: tcp
    required: true
env:
  - name: AIRSONIC_SETTINGS
    default: "/config"
    required: false
volumes:
  - path: /config
    required: true
  - path: /media
    required: false
  - path: /music
    required: false
  - path: /playlists
    required: false
  - path: /podcasts
    required: false
dependencies: []
```

`AIRSONIC_HOME` is set in the image (`ENV`), not a user setting, so it is not listed. Do not list `LANG`.

## 7. start.sh

Intended flow:
- `mkdir -p /config/airsonic /tmp/airsonic-tmp`. Seed nothing: airsonic creates its database and state under `/config` on first start (UNVERIFIED that it does not need a seed file).
- Set `AIRSONIC_SETTINGS=${AIRSONIC_SETTINGS:-/config}`.
- Launch the WAR's embedded server, listening on all interfaces (UNVERIFIED launch command; the linuxserver s6 run script was not read. Confirm `java -jar` and any `--host`/port option by running it):
  `exec java -Djava.io.tmpdir=/tmp -jar /app/airsonic/airsonic.war --host=0.0.0.0 --port=4040` (flags UNVERIFIED).
- Idempotent with empty `/config`. No writes to `/app`. Caches and temp files to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
  - port: '4040'
http:
  - port: '4040'
    path: /
filePaths:
  - /app/airsonic/airsonic.war
  - /usr/share/licenses/airsonic/LICENSE
```

Timeout is set higher than a simple web app because a WAR starts slowly; compare with the java17 sibling and the nzbhydra2 test before finalising (UNVERIFIED value). The http probe's expected status is UNVERIFIED until a local run; if `/` redirects, use the path that returns 200.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Settings, database, playlists (`AIRSONIC_SETTINGS`) | `/config` |
| Temp directory (java `java.io.tmpdir`) | `/tmp` via `JAVA_TOOL_OPTIONS` |
| Transcoding and cover-art caches (UNVERIFIED location) | Confirm during the build; point to `/tmp` (scratch) |
| Upstream `/app/airsonic` | Kept as read-only WAR location, no writes |
| linuxserver s6 wrapper | Replaced by `start.sh` with `exec` |

Target user: `apps`. TrueCharts runs as UID 0 (draft expectation); the plan targets non-root and read-only rootfs. No privileged mode, no extra capabilities.

## 10. Risks, caveats and open questions

- **Java version:** upstream used Java 8. The draft assumes Java 17 works for airsonic 10.6.2. UNVERIFIED. If it fails, stop and record the error; do not patch the WAR.
- **Upstream status:** the project is archived and the newest release is from 2020. Whether to ship this or the airsonic-advanced fork is an open question for the user. This plan follows the draft (airsonic 10.6.2).
- **Checksum:** the SHA-256 is from a PGP-signed file whose key was not verified. Record that in the PR.
- **Media and transcoding:** ffmpeg and lame are needed for transcoding. Confirm the resolute archive versions and that the transcoder works without `/tmp` persistence.
- **Mounted library:** the music library must be mounted; the database and state are written to `/config` on first start (draft gotcha, consistent with the upstream `VOLUME` list).
- Draft security expectations are the chart's values, not the image's. They are not to be copied. The plan's target is non-root and read-only.
- Ports: 4040 is confirmed upstream (`EXPOSE`).

## 11. Build and test steps

1. `cd apps/airsonic && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name airsonic-probe --read-only --tmpfs /tmp -v airsonic-probe-config:/config airsonic:v10.6.2`, then `docker logs -f airsonic-probe`.
   Expected readiness signal: UNVERIFIED for airsonic 10.6.2. Check the first run log for the server's "started" line and that the process still runs. Fail on any stack trace or `ClassNotFound`/`UnsupportedClassVersionError` (Java mismatch).
4. `forgetool containers test --image airsonic:v10.6.2 --config ./apps/airsonic/container-test.yaml`
5. Cleanup: `docker rm -f airsonic-probe; docker volume rm airsonic-probe-config`.
6. Arm64 only if an amd64 failure is arm64-specific.

## 12. PR checklist

- Branch: `feat/add-airsonic`. Commit and PR title: `feat(airsonic): add new container`.
- PR description: `🤖 This PR is AI generated.` in Notes. Use `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only they can sign). The `license/cla` check shows the status.
- Not tested: nothing built, nothing run. Java 17 compatibility and the launch command are unverified. Say so in the PR. Do not check "Built container locally".
