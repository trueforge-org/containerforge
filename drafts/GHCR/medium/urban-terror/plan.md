# urban-terror — implementation plan
> Source: ./draft.md · Target: apps/urban-terror/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
|---|---|---|
| Latest stable version | UNVERIFIED: the chart and image use the floating tag `latest`. The game version is 4.3 (path `urt/43`), taken from the download URL in the draft. | draft.md, upstream Dockerfile |
| Renovate | UNVERIFIED: no versioned release source exists. Use the `docker` datasource on `ich777/urbanterror` only if a versioned tag appears. Otherwise leave the version pinned to the game build date and document the choice. | https://raw.githubusercontent.com/ich777/docker-urbanterror/master/Dockerfile |
| License (SPDX) | UNVERIFIED: the README states no license ("free" only). Use `LICENSE = "UNVERIFIED"` and do not ship a license file until one is found. | https://raw.githubusercontent.com/ich777/docker-urbanterror/master/README.md |
| Game source | https://github.com/FrozenSand/ioq3-for-UrbanTerror-4 (ioq3 fork, used for arm64 compile) | draft.md |
| Per-arch binary | amd64: `http://www.urbanterror.info/downloads/software/urt/43/UrbanTerror43_ded.tar.gz` (upstream DL_URL; draft gives https). arm64: none, compile from source. | upstream Dockerfile, draft.md |
| Checksum | None published (not in the upstream Dockerfile or README). We must compute and pin the sha256 of the downloaded tarball ourselves and record it in the bake file. | https://raw.githubusercontent.com/ich777/docker-urbanterror/master/Dockerfile |
| Upstream Dockerfile (ich777/docker-urbanterror) | `FROM ich777/debian-baseimage`. apt: `curl libxml2-utils libsdl2-2.0-0`. `ENTRYPOINT ["/opt/scripts/start.sh"]`, no CMD, no USER (runs as root), no EXPOSE, no VOLUME. Scripts copied to `/opt/scripts/`. | same |
| Env vars (upstream) | DATA_DIR=/urbanterror, CONFIG_NAME=server.cfg, DL_URL, GAME_V=1, DL_LOCATION=1, ENGINE=1, CHECK_FOR_UPDATES=true, GAME_PORT=27960, START_PARAMS="", UMASK=0000, DATA_PERM=770, UID=99, GID=100, USER=urbanterror | same |
| Start script | `/opt/scripts/start.sh` is not in the fetched pages. Its download and launch logic is UNVERIFIED. | not fetched |
| Ports | 27960/udp (README run example `-p 27960:27960/udp`) | https://raw.githubusercontent.com/ich777/docker-urbanterror/master/README.md |
| Data paths | `/urbanterror` (DATA_DIR, README volume mount). `server.cfg` lives there. | README |
| First start | Downloads game files; can take up to 30 minutes (README). | README |
| Dependencies | None | draft.md |

## 2. Target layout

Files in `apps/urban-terror/`:
- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: download on first start, then `exec` the server)

`defaults/` is needed to ship a default `server.cfg` (seeded into `/config` only when missing). Include it only after the server config contents are confirmed (UNVERIFIED). Never use `root/`. `DOWNSTREAM_CHANGES.md` is not needed (not a base).

## 3. Base image

Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

Why: the upstream base is `ich777/debian-baseimage`, which is not a ContainerForge base. Ubuntu with the apt packages below covers the need. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball, `USER apps`). For a game server that downloads data at first start, check a sibling that downloads at start (search `apps/*/start.sh` for `curl` or `steamcmd`); `apps/steamcmd` is the closest pattern for runtime downloads.

## 4. Dockerfile

Single stage on the ubuntu base (the amd64 path is a download, no compile).

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG SHA256` (values come from bake).
2. `USER root`.
3. apt: install `libsdl2-2.0-0` only if it is not already in the base (check first). `curl` and `libxml2-utils` are not needed if the base has `curl`; check. Use `--no-install-recommends`, then clean `/var/lib/apt/lists/*`.
4. Download the tarball over HTTPS if the host supports it (UNVERIFIED), else over the upstream HTTP URL. Verify with `echo "${SHA256}  UrbanTerror43_ded.tar.gz" | sha256sum -c -`. Extract into `/app` with `tar xzf ... -C /app --strip-components 1` (the tarball layout is UNVERIFIED; list it first).
5. Ship the upstream license notice if any is found (none stated; see section 10).
6. `chmod -R 0755 /app` after extraction so the binary is executable, owner root (read-only at runtime).
7. `ENV` remaps (no upstream USER/UID/GID env):
   - `GAME_PORT=27960`
   - `DATA_DIR=/config` (was `/urbanterror`; remapped to the persistent volume)
   - `CONFIG_NAME=server.cfg`
   - `HOME=/config`
   - Drop `UID`, `GID`, `USER`, `UMASK`, `DATA_PERM`: they belong to the upstream user model (`apps` user is set by the base).
8. `USER apps`
9. `COPY --chmod=0755 . /`
10. `EXPOSE 27960/udp`, `VOLUME /config`, `CMD ["/start.sh"]`.

Do not compile the ioq3 fork in the final stage. arm64 compile is an open question (section 10).

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "urban-terror" }`
- `variable "VERSION" { // renovate: datasource=... depName=... versioning=loose  default = "<UNVERIFIED: a version string from the download URL, e.g. 4.3 or the tarball date>" }`. The renovate rule cannot be set until a versioned source exists (UNVERIFIED). Note the choice in the PR.
- `variable "SHA256" { default = "<sha256 of the tarball, computed by downloading it once and recording it>" }`
- `variable "LICENSE" { default = "UNVERIFIED" }`. Do not invent an SPDX value.
- `variable "SOURCE" { default = "https://www.urbanterror.info/home/" }` (project page; the ioq3 fork URL is the source for the arm64 compile).
- Standard targets `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64). Until arm64 is validated, `image-all` lists `linux/amd64` only and the PR says so.
- `group "default" { targets = ["image-local"] }`
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.urbanterror.info/home/"
ports:
  - port: 27960
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: GAME_PORT
    default: "27960"
    required: false
  - name: CONFIG_NAME
    default: "server.cfg"
    required: false
  - name: CHECK_FOR_UPDATES
    default: "true"
    required: false
  - name: START_PARAMS
    default: ""
    required: false
volumes:
  - path: /config
    required: true
```

- Only env vars the start script actually reads may be listed. The list above is the upstream set minus the user-model vars (UID, GID, USER, UMASK, DATA_PERM) and minus DL_URL/GAME_V/DL_LOCATION/ENGINE, which stay out until start.sh is confirmed to need them (UNVERIFIED). Keep the list to what start.sh reads once written.
- `upstream_env_url` must equal the value of `SOURCE`.
- `dependencies`: none.
- Ports: 27960 is UDP.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Seed `/config/server.cfg` only when missing from `/defaults` (if defaults/ is used).
- If the game files are not in `/config` yet, download the tarball (or use a pre-extracted copy in `/app`). Downloads go to `/tmp`, extraction target is `/config` (never `/app`). Caches go to `/tmp`.
- Re-run the update check only when `CHECK_FOR_UPDATES=true`. Its network behaviour is UNVERIFIED.
- Bind to all interfaces (the game server binds with `+set net_ip 0.0.0.0`, flag UNVERIFIED).
- `exec /app/<server binary> +set dedicated ... +set net_port "${GAME_PORT}" +set fs_homepath /config ${START_PARAMS}` (exact flag names UNVERIFIED; read them from the ioq3 source and the upstream start script).
- Never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
filePaths:
- /app/<server binary, UNVERIFIED name>
timeoutSeconds: 600
```

- The test runs with no env and an empty `/config`, so the first-start download runs inside the test. The README says the first start can take up to 30 minutes, so use `timeoutSeconds: 600` as a starting point and check the real time during the build. Sibling apps with downloads use 300 to 600 (apps with 600 exist).
- Coverage minimum: the port is UDP, and the `tcp` probe cannot check it. Use a UDP-aware check if forgetool supports one (UNVERIFIED), otherwise add a process check plus a filePaths check and say why in a comment.
- Do not add a tcp probe that passes against a closed port.

## 9. Rootless and read-only-rootfs adaptations

Upstream runs as root. The target runs as `apps`.

- `/urbanterror` (upstream DATA_DIR) → `/config`. The game data and `server.cfg` move to the persistent volume.
- `/opt/scripts/start.sh` → `/start.sh` (root of the image, as in other apps).
- The `urbanterror` user and `UID=99`/`GID=100` are dropped; the base's `apps` user runs the server.
- `/app` holds the binary and is read-only at runtime.
- Downloads and temp files go to `/tmp`.

Security expectations reconciliation (draft: non-root no, read-only no, privileged no):
- Target: non-root (`USER apps`), read-only rootfs compatible, not privileged. These are intentional departures from the TrueCharts chart.
- Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- The download is http in upstream (`http://www.urbanterror.info/...`). Check whether https works; if it does not, keep http and document it.
- No checksum is published. The pinned sha256 is computed by us; it proves only that the file did not change after pinning, not that it is authentic.
- No license is stated. The LICENSE bake value is UNVERIFIED, and the PR must state that the license is unknown.
- The `latest` tag in the chart means server version can change. Our VERSION pin is a choice; the renovate rule is UNVERIFIED.
- arm64: an ioq3 fork compile (https://github.com/FrozenSand/ioq3-for-UrbanTerror-4) is needed. It is a separate, slower build and is not validated. Plan: ship amd64 first, and keep `image-all` to amd64 until arm64 is built and tested.
- The start script (`/opt/scripts/start.sh`) was not fetched. Its behaviour, flags and paths are UNVERIFIED and must be read before the start script is written.
- The apt package names on Ubuntu 26.04 (`libsdl2-2.0-0`) are UNVERIFIED: check with `apt-cache policy` in the build.
- Blocker check: the game is a native x86_64 binary (amd64 path works), no GPU, no privileged need. The UDP port is the main test gap.

## 11. Build and test steps

From `apps/urban-terror`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Clean run with an empty volume:
   ```sh
   docker volume create urban-terror-probe-config
   docker run --rm -d --name urban-terror-probe --read-only --tmpfs /tmp \
     -p 27960:27960/udp -v urban-terror-probe-config:/config ${APP}:${VERSION}
   docker logs -f urban-terror-probe
   ```
   Pass: the container stays up through the download, the logs show the server start, and there are no fatal errors. Expected readiness line: UNVERIFIED (read the server's own startup log in the real run).
4. Cleanup: `docker rm -f urban-terror-probe; docker volume rm urban-terror-probe-config`.
5. `forgetool containers test --image urban-terror:<version> --config ./apps/urban-terror/container-test.yaml`. If forgetool is not available, check the UDP port with a UDP probe from the host and the process by hand.
6. Repeat step 3 with the volume already populated to confirm the restart path (no re-download unless CHECK_FOR_UPDATES says so).
7. arm64: not in this PR unless the compile is done.

No docker build was run during planning.

## 12. PR checklist

- Branch: `feat/add-urban-terror`
- Commit: `feat(urban-terror): add new container`
- PR title: `feat(urban-terror): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Say what was not tested: arm64, the UDP probe, the start script behaviour, the license, the checksum authenticity, and the first-start duration unless they were run.
- Not applicable: DOWNSTREAM_CHANGES.md (not a base image).
