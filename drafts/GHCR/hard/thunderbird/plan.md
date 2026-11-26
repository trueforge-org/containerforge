# thunderbird — implementation plan
> Source: ./draft.md · Target: apps/thunderbird/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Thunderbird 161.0 (Mozilla redirect: https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/161.0/linux-x86_64/en-US/thunderbird-161.0.tar.xz, reached from https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=en-US). 161.0 is the latest release per https://product-details.mozilla.org/1.0/thunderbird_versions.json (re-checked 2026-11-26); release date UNVERIFIED. The chart uses a rolling `ghcr.io/ich777/thunderbird:latest` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/thunderbird/values.yaml). Pin 161.0 and do not use the rolling link. |
| Renovate | UNVERIFIED: no version feed checked. Mozilla publishes release directories under `releases/<version>/`; a custom regex or `datasource=custom` is needed. |
| License | UNVERIFIED on a fetched page. Thunderbird is MPL-2.0 by common knowledge; confirm from the Mozilla source or the tarball's license file. |
| Source URL | https://www.thunderbird.net/ (draft); source code at Mozilla hg. |
| Download (amd64) | `https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/161.0/linux-x86_64/en-US/thunderbird-161.0.tar.xz` (Mozilla redirect, fetched). |
| Download (arm64) | None: Mozilla ships only `linux-x86_64` tarballs (redirect above). arm64 means a source build. |
| Checksum source | UNVERIFIED: Mozilla's `SHA512SUMS` in the same release directory (not fetched). Verify before use. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-thunderbird/master/Dockerfile: `FROM ich777/novnc-baseimage`; `LABEL org.opencontainers.image.source=https://github.com/ich777/docker-thunderbird`; ENV `DATA_DIR=/thunderbird`, `CUSTOM_RES_W=1024`, `CUSTOM_RES_H=768`, `CUSTOM_DEPTH=16`, `NOVNC_PORT=8080`, `RFB_PORT=5900`, `THUNDERBIRD_V=latest`, `THUNDERBIRD_LANG=en-US`, `TURBOVNC_PARAMS="-securitytypes none"`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=thunderbird`; apt `bzip2 libgtk-3-0 libdbus-glib-1-2 ttf-wqy-zenhei fonts-wqy-microhei fonts-takao fonts-arphic-uming fonts-noto-cjk libasound2 xz-utils`; `EXPOSE 8080`; `ENTRYPOINT ["/opt/scripts/start.sh"]`. No download URL and no checksum in this file; the tarball fetch is in the start scripts, which were not fetched (UNVERIFIED). |
| Ports | noVNC web on 8080 (upstream `EXPOSE 8080`, `NOVNC_PORT=8080`). Chart: `main` port 10291 mapped to container 8080. `RFB_PORT=5900` is an upstream env, not exposed in the Dockerfile. The draft's 6080 is wrong against the upstream file. |
| Data and config paths | `/thunderbird` (upstream `DATA_DIR`; chart `data` mount). |
| arm64 | No Mozilla tarball; see download row. |
| Dependencies | None. Desktop stack from the noVNC base (upstream `ich777/novnc-baseimage`). ContainerForge siblings `apps/kasmvnc` and `apps/xvfb` exist (checked by listing `apps/`) and are candidates for the display stack. |

## 2. Target layout

Files under `apps/thunderbird/`:

- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh`
- `root/` is NOT used (rule: never touch `root/`). If a display helper is needed, put it in `scripts/` or `etc/` instead.

`defaults/` only if a default Thunderbird profile is needed on first start (reason: none expected; Thunderbird creates its profile itself). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Reason: draft and upstream both need a desktop stack (GTK3, fonts, X display). Sibling choice: `apps/kasmvnc` (desktop over VNC in a ContainerForge image) or `apps/xvfb`. Both exist in `apps/`. `apps/kasmvnc` exposes 3000 and 3001 (not 8080) and `apps/xvfb` has no noVNC, so the 8080 port in this plan only holds if a noVNC layer is added; align `settings.yaml`, `EXPOSE` and the probes with whichever display stack is chosen. Check both before writing; reuse the sibling's display and VNC/noVNC setup rather than copying the ich777 base.

## 4. Dockerfile

1. `ARG VERSION=161.0`, `ARG TARGETARCH`. Fail the build for `arm64` unless a source build is added later (out of scope for now).
2. `FROM <ubuntu> AS base`, `USER root`.
3. `apt-get install -y --no-install-recommends bzip2 libgtk-3-0 libdbus-glib-1-2 fonts-dejavu-core xz-utils` plus the display packages from the chosen sibling (`xvfb`, noVNC or KasmVNC). Remove packages the base already provides. Pin where apt is used and check against `VERSION` where relevant (UNVERIFIED pins).
4. Download the amd64 tarball, verify its SHA-512 against Mozilla's `SHA512SUMS` (UNVERIFIED source, see section 1), extract to `/app/thunderbird/`.
5. Ship license notices to `/usr/share/licenses/thunderbird/`.
6. `ENV HOME=/config DATA_DIR=/config/thunderbird UMASK=002 TZ=Etc/UTC`. Profile goes to `/config/thunderbird`.
7. `chown -R apps:apps /config`; `/app` stays root-owned.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/thunderbird
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "thunderbird" }
variable "VERSION" {
  // renovate: UNVERIFIED datasource (Mozilla release directory, no feed confirmed); pin 161.0
  default = "161.0"
}
variable "LICENSE" { default = "MPL-2.0" } // UNVERIFIED on a fetched page, confirm before merge
variable "SOURCE" { default = "https://www.thunderbird.net/" }
```

Four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.thunderbird.net/"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: CUSTOM_RES_W
    default: "1024"
    required: false
  - name: CUSTOM_RES_H
    default: "768"
    required: false
  - name: CUSTOM_DEPTH
    default: "16"
    required: false
  - name: THUNDERBIRD_LANG
    default: "en-US"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Env names are the upstream ones (UNVERIFIED that the ContainerForge start script reads them; the sibling display base may use its own names). Drop any that the start script does not read.

## 7. start.sh

- Create `/config/thunderbird` on first start only; never overwrite an existing profile.
- Start the display (Xvfb or the sibling's VNC) and noVNC on 8080, bound to `0.0.0.0`.
- `exec` Thunderbird as the final process under `/app/thunderbird/thunderbird` with `HOME=/config`.
- Caches to `/tmp`. Never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180   # UNVERIFIED startup time; use the sibling's value
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /start.sh
- /app/thunderbird/thunderbird
- /usr/share/licenses/thunderbird/LICENSE
```

The tcp and http probes cover the noVNC port. Probe paths must return 200 for noVNC (UNVERIFIED for the chosen sibling). Do not add probes for 5900: it is not exposed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/thunderbird` (profile, DATA_DIR) | `/config/thunderbird` (`DATA_DIR` set at build time). |
| `/home/thunderbird` (HOME) | `HOME=/config`. |
| `/tmp` | Xvfb, Thunderbird cache. |
| `/app/thunderbird` | Read-only at runtime; the tarball is extracted at build time. |
| Root user | Chart runs `runAsUser 0`, `readOnlyRootFilesystem false` (chart values, confirmed). Rework: `USER apps`, read-only rootfs. |
| `UID=99 GID=100` | Ignored; ContainerForge runs as `apps`. |

## 10. Risks, caveats and open questions

- A desktop app over VNC or noVNC has no headless service; the probe is the web UI only.
- Mail accounts are added by the user in the GUI (draft, inferred). Manual setup.
- The chart uses rolling `latest`. This plan pins 161.0 and expects a version bump to change the URL. Check the Mozilla release directory for newer versions.
- arm64 needs a Thunderbird source build, which is out of scope for this plan.
- Checksums, license and Thunderbird release date are UNVERIFIED.
- Blockers: desktop/VNC stack, the Mozilla tarball is a `linux-x86_64` build only, and the profile must be writable (chart runs as root today).

## 11. Build and test steps

From `apps/thunderbird/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name thunderbird-probe --read-only --tmpfs /tmp -v thunderbird-probe-config:/config ghcr.io/trueforge-org/thunderbird:161.0`, then `docker logs -f thunderbird-probe`. Expected readiness signal: UNVERIFIED (noVNC "listening" line; confirm on first run).
4. `forgetool containers test --image <image>:161.0 --config ./apps/thunderbird/container-test.yaml`
5. Clean up: `docker rm -f thunderbird-probe; docker volume rm thunderbird-probe-config`.

## 12. PR checklist

- Branch: `feat/add-thunderbird`
- Commit: `feat(thunderbird): add new container`
- PR title: same as commit
- Use `.github/PULL_REQUEST_TEMPLATE.md`; only tick boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what was not tested: the Mozilla checksum check, the arm64 path (not built), the GUI session, and the profile persistence.
