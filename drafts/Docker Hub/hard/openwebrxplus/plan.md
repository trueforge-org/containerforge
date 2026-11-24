# openwebrxplus — implementation plan
> Source: ./draft.md · Target: apps/openwebrxplus/ · Difficulty: hard, with a hard blocker on Python ABI (see section 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 1.2.131 (`owrx/version.py` on `luarvique/openwebrx` master, `openwebrx` 1.2.131 in the PPA, Docker Hub `slechev/openwebrxplus-softmbe:1.2.131` pushed 2026-11-20). Draft tag is the same. GitHub "Releases" lag (latest release is 1.2.117), so do not use github-releases. |
| Renovate | `datasource=docker depName=slechev/openwebrxplus-softmbe versioning=loose` (tag `1.2.131` verified). The tag follows the app version. |
| License | GitHub detects `AGPL-3.0` for `luarvique/openwebrx`. Exact header (or-later or only) UNVERIFIED: read `/usr/share/doc/openwebrx/copyright` from the .deb at implementation time. Plan value `AGPL-3.0-or-later` only if that file says so. |
| Source URL | https://github.com/luarvique/openwebrx (app), https://github.com/0xAF/openwebrxplus-docker-builder (image recipe, `buildfiles/Dockerfile-softmbe`, reviewed at 3ead881 and main). |
| How upstream builds the image | Debian bookworm-slim, s6-overlay as PID 1 (`/init`), `apt install openwebrx=<version>` from the OpenWebRX+ PPA plus many hand-built SDR packages (rtl-sdr-blog, airspyhf, plutosdr, runds, radae, freedv, m17, msk144, libmirisdr, hydrasdr, perseus, ...) and SoftMBE (mbelib-neo) debs built from source. Services: `openwebrx`, `codecserver`, `sdrplay`, optional socat port forwards. |
| Per-arch download URLs | PPA: `https://luarvique.github.io/ppa/noble/Packages` and `./amd64/openwebrx_1.2.131_all.deb`, `./arm64/...` (arch `all`, SHA256 `16f0d07f09009e50fb856787283e6f908e546ca52f683dfcfc59aba85cc0e635` for amd64). Repo suites listed: Ubuntu 22.04, 24.04 (noble), Debian 11, 12 (bookworm), 13 (trixie). **No Ubuntu 26.04 suite.** |
| Checksum source | apt verifies the signed repo (`https://luarvique.github.io/ppa/openwebrx-plus.gpg`); `Packages` carries SHA256 per .deb. |
| Key dependency facts | `openwebrx` depends on `owrx-connector (>= 0.6.5)` and `python3-csdr (>= 0.18.44)`. `python3-csdr` 0.18.44 and `python3-digiham` 0.6.11 in the noble suite declare `python3 (>= 3.12~), python3 (<< 3.13)`. Ubuntu 26.04 ships Python 3.14 (python3.14 3.14.4 in resolute). |
| Ports | 8073 http + websocket (`[web] port = 8073` default in `owrx/config/core.py`; image `EXPOSE 8073`). |
| Config/data paths | Search order `./openwebrx.conf`, `/etc/openwebrx/openwebrx.conf` (+ `.d/*.conf`); `[core] data_directory` default `/var/lib/openwebrx`, `temporary_directory` default `/tmp`. Upstream volumes: `/etc/openwebrx`, `/var/lib/openwebrx`. Chart also mounts `/usr/lib/python3/dist-packages/htdocs/plugins`. |
| Env read by upstream scripts | `OPENWEBRX_ADMIN_USER`, `OPENWEBRX_ADMIN_PASSWORD` (creates admin when both set), `TZ`, `FORWARD_LOCALPORT_<n>=<public>` (socat forwards), `HEALTHCHECK_SDR_DEVICES`, `HEALTHCHECK_USB_<vendor>_<product>=<count>`. |
| Health | `wget http://localhost:8073/metrics` (upstream `healthcheck.sh`); `status.json` lists SDRs. |

## 2. Target layout

```
apps/openwebrxplus/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/openwebrx.conf   # [core] data_directory=/config/data, temporary_directory=/tmp/openwebrx, [web] port=8073
  defaults/codecserver.conf # only if SoftMBE/codecserver is kept (see section 4)
```
No `root/` (s6 `root/` is not used; processes are started by `start.sh`). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (generic userland; no sibling for SDR). Closest sibling for process-model: `apps/tvheadend` / `apps/oscam` (hardware-adjacent), but none exercises USB SDRs. Because of the Python ABI blocker the base must provide Python 3.12 next to the system Python (route A) or the Python extensions must be rebuilt (route B).

## 4. Dockerfile

Do a spike first (section 10). Planned shape, route A (preferred, smallest delta from upstream):

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Add Python 3.12 (`ppa:deadsnakes/ppa` publishes `python3.12` 3.12.16 for resolute, verified) and the OpenWebRX+ `noble` suite: `curl -fsSL https://luarvique.github.io/ppa/openwebrx-plus.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/openwebrx-plus.gpg` and `deb [signed-by=...] https://luarvique.github.io/ppa/noble ./`.
3. Install with a pinned version check: `apt-get install -y --no-install-recommends openwebrx=${VERSION}` (the build must fail if the candidate differs: `test "$(apt-cache policy openwebrx | awk '/Candidate/{print $2}')" = "${VERSION}"`). Runtime packages, only those not in the base: `owrx-connector`, `python3-csdr`, `codecserver` (+ `libcodecserver`), `rtl-sdr`, `soapysdr-module-all` family and `libusb-1.0-0`, `sox`, `imagemagick`, `lame`, `multimon-ng`, `direwolf`, `wsjtx`, `js8call`, `nrsc5`, `dablin`, `redsea`, `dream-headless`, `acarsdec`, `dumphfdl`, `dumpvdl2`, `dump1090-fa-minimal`, `dump978-fa-minimal`, `rtl-433`, `csdr-skimmer` (all names taken from the `Recommends:` line of the `openwebrx` package; each must be checked for noble availability on arm64 at build time). Start with the minimum set (`openwebrx`, `owrx-connector`, `python3-csdr`, `rtl-sdr`, `soapysdr-tools`, `codecserver`) and add decoders one at a time.
4. Because `python3-csdr`/`python3-digiham` require `python3 (<< 3.13)`, route A needs `dpkg --force-depends` or `dpkg -x` of those debs into a prefix and `PYTHONPATH` pointing at `/usr/lib/python3/dist-packages` for the 3.12 interpreter, and launching with `python3.12 openwebrx.py`. UNVERIFIED: whether that works; this is what the spike must prove.
5. Route B (fallback): build `csdr`, `pycsdr`, `owrx_connector`, `codecserver`, `digiham` from source in a builder stage against Python 3.14 (upstream repos by jketterl; versions and tags UNVERIFIED), then `pip install` `luarvique/openwebrx` into `/app/venv`. Large, and `owrx` uses `distutils.version.LooseVersion` (`owrx/version.py`), which does not exist on Python 3.12+ unless `setuptools` is installed; add `setuptools` into the venv.
6. SoftMBE (mbelib) is patent-encumbered and is why upstream publishes a separate `-softmbe` image; ship it only if the maintainers accept that (open question in section 10). If kept, build `mbelib-neo` from `buildfiles/files/mbelib-neo-debian` of the docker-builder repo in a builder stage.
7. License files: copy `/usr/share/doc/openwebrx/copyright` to `/usr/share/licenses/openwebrx/` and the same for each shipped third-party decoder.
8. `ENV HOME=/tmp XDG_CACHE_HOME=/tmp/.cache TMPDIR=/tmp OPENWEBRX_DATA=/config`; write `/etc/openwebrx` writes away (section 9).
9. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8073`, `VOLUME /config`, `WORKDIR /config`, `CMD ["/start.sh"]` (the ubuntu entrypoint execs `/start.sh`). Final `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "openwebrxplus" }
variable "VERSION" {
  // renovate: datasource=docker depName=slechev/openwebrxplus-softmbe versioning=loose
  default = "1.2.131"
}
variable "LICENSE" { default = "AGPL-3.0-or-later" }  // UNVERIFIED, confirm from the package copyright file
variable "SOURCE"  { default = "https://github.com/luarvique/openwebrx" }
```
Standard targets as in `apps/it-tools/docker-bake.hcl`: `docker-metadata-action`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default"` = `image-local`. Run `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/luarvique/openwebrx"`.
- ports: `8073` tcp, `required: false`.
- env: `TZ` (`Etc/UTC`, false); `OPENWEBRX_ADMIN_USER` (default `""`, false); `OPENWEBRX_ADMIN_PASSWORD` (default `""`, false); `HEALTHCHECK_SDR_DEVICES` is an upstream healthcheck variable that this image does not read, so do not list it.
- volumes: `/config` `required: true` (settings.json, users.json, bookmarks, `openwebrx.conf.d`, data dir, plugins).
- dependencies: none. (USB access: `--device /dev/bus/usb`, documented in a comment, not a ContainerForge dependency.)

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`, idempotent:
1. `mkdir -p /config/etc/openwebrx.conf.d /config/data /config/plugins /tmp/openwebrx`.
2. Seed only when missing: `cp -n /defaults/openwebrx.conf /config/etc/openwebrx.conf`; if `/config/etc/openwebrx.conf.d` is empty copy defaults; copy the packaged `/etc/openwebrx.dist/*` (image build copies the pristine `/etc/openwebrx` here) with `cp -rn`.
3. Make `/etc/openwebrx` resolve to `/config/etc` (symlink created at build time to a real `/config/etc` path; `/config` is empty at start, so `start.sh` creates the target, which is why step 1 runs first).
4. If both `OPENWEBRX_ADMIN_USER` and `OPENWEBRX_ADMIN_PASSWORD` are set and `openwebrx admin --silent hasuser "$OPENWEBRX_ADMIN_USER"` fails, run `OWRX_PASSWORD="$OPENWEBRX_ADMIN_PASSWORD" openwebrx admin --noninteractive adduser "$OPENWEBRX_ADMIN_USER"` (password via env, not argv; upstream does exactly this).
5. If `codecserver` is shipped, start it in the background with a config in `/config/etc/codecserver/` (UNVERIFIED: codecserver ports and config path); trap TERM to stop it.
6. Bind: `[web]` has no `bind_address` by default, so it listens on all interfaces; confirm with a connect from outside the container.
7. `exec openwebrx` (or `exec python3.12 /usr/lib/python3/dist-packages/openwebrx.py` for route A).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8073'
http:
- port: '8073'
  path: /metrics
filePaths:
- /usr/share/licenses/openwebrx/copyright
- /defaults/openwebrx.conf
```
8073 is the only port in settings.yaml and has tcp and http probes. `/metrics` is what upstream's `healthcheck.sh` polls. The test passes no env vars, so the admin-user path cannot be tested; run it by hand per the protocol. No SDR hardware is needed to start (OpenWebRX+ starts without a device).

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID 0 (s6-overlay, dpkg-reconfigure tzdata, writes to `/etc/openwebrx`, `/var/lib/openwebrx`, `/etc/localtime`, `/run/service`, `/etc/s6-overlay`): replace by UID 568, no s6, no `dpkg-reconfigure`; `TZ` env only.
- Write paths and remaps: `/etc/openwebrx` -> `/config/etc` (symlink), `/var/lib/openwebrx` -> `/config/data` (via `data_directory`), `[core] temporary_directory` -> `/tmp/openwebrx`, plugin dir `/usr/lib/python3/dist-packages/htdocs/plugins` (chart persists it) -> symlink to `/config/plugins`, `custom.css` symlink target `/etc/openwebrx/custom.css` -> `/config/etc/custom.css`, Python bytecode off (`PYTHONDONTWRITEBYTECODE=1`).
- `readOnlyRootFilesystem: false` and `privileged: false` in the draft: image targets read-only rootfs and no privileges. SDR USB access needs `/dev/bus/usb` passed as a device with the `apps` supplementary groups; the ubuntu base entrypoint already prints device permission warnings. Extra persistence (`/var/lib/openwebrx`, `/etc/openwebrx`, plugins) collapses into the single `/config` volume.

## 10. Risks, caveats and open questions

- **Blocker (verified):** the OpenWebRX+ PPA has no Ubuntu 26.04 suite and `python3-csdr`/`python3-digiham` require `python3 (<< 3.13)`, while the ContainerForge base has Python 3.14. Needs the spike in section 4 (route A or B) and a maintainer decision. Until it works, this app should not be opened as a PR.
- Debian trixie suite exists but trixie also has Python 3.13, so it does not help; only bookworm (Python 3.11) matches, which is not a ContainerForge base.
- SoftMBE/mbelib legal status; upstream splits it into a separate image. Decide whether to include.
- Upstream base image is amd64 plus arm64/armv7 via the docker-builder; some SDR drivers (airspyhf, SDRplay) are x86/arm specific. SDRplay API is proprietary and not redistributable: leave out.
- Large attack surface and image size (decoders). Start minimal.
- Draft caveat "must be built from source for both architectures": partly wrong, openwebrx itself is `Architecture: all`; only the native libs differ.
- Open question: OpenWebRX+ may need `--cap-add`/root for `sdrplay` service only; not needed for RTL-SDR.
- UNVERIFIED: `settings.json` path may be hard-coded to `/etc/openwebrx/settings.json`; the `/config/etc` symlink approach covers it either way.

## 11. Build and test steps

```sh
cd apps/openwebrxplus
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name openwebrxplus-probe --read-only --tmpfs /tmp -v openwebrxplus-probe-config:/config openwebrxplus:1.2.131
docker logs -f openwebrxplus-probe     # expect OpenWebRX web server listening on 8073, no traceback (import error for csdr/pycsdr means the Python ABI spike failed)
curl -fsS http://<container-ip>:8073/metrics
docker rm -f openwebrxplus-probe; docker volume rm openwebrxplus-probe-config
forgetool containers test --image openwebrxplus:1.2.131 --config ./apps/openwebrxplus/container-test.yaml
```
Also run once with `-e OPENWEBRX_ADMIN_USER=admin -e OPENWEBRX_ADMIN_PASSWORD=...` and restart, to check the admin step is idempotent. arm64: attempt only if amd64 is green.

## 12. PR checklist

- [ ] Branch `feat/add-openwebrxplus`, commit and title `feat(openwebrxplus): add new container`, target `main`.
- [ ] PR body follows `.github/PULL_REQUEST_TEMPLATE.md`, only applicable boxes checked.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] Bake and Dockerfile `VERSION` aligned, `docker buildx bake --print` run.
- [ ] Say what is untested: arm64, real SDR hardware, SoftMBE decoders, the Python 3.12/3.14 workaround, codecserver, and any decoder removed from the upstream set.
