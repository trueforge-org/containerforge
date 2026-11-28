# firefox — implementation plan
> Source: ./draft.md · Target: apps/firefox/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable is **161.0** (released 2026-11-24). Draft pins 160.0.1 (chart tag 1160.0.1). Plan: pin **161.0** unless the build must match the chart. Source: https://product-details.mozilla.org/1.0/firefox_versions.json |
| Difference from draft | Draft pins 160.0.1; latest is 161.0. Draft's download URL (`download.mozilla.org/?product=firefox-160.0.1-SSL`) is a 302 to `download-installer.cdn.mozilla.net`; the plan uses the stable `archive.mozilla.org` path instead. |
| Renovate | UNVERIFIED: no renovate datasource is confirmed for Mozilla builds. Proposed: `// renovate: datasource=custom.firefox depName=firefox versioning=loose` (open question, see section 10). |
| License | UNVERIFIED: Firefox is MPL-2.0 by upstream convention, but not confirmed from a fetched page in this run. Confirm at https://www.mozilla.org/en-US/MPL/2.0/ before setting `LICENSE`. |
| Source URL | https://github.com/mozilla-firefox/firefox |
| Download amd64 | https://archive.mozilla.org/pub/firefox/releases/161.0/linux-x86_64/en-US/firefox-161.0.tar.xz (HEAD 200 confirmed) |
| Download arm64 | https://archive.mozilla.org/pub/firefox/releases/161.0/linux-aarch64/en-US/firefox-161.0.tar.xz (the 160.0.1 aarch64 tarball is HEAD 200; the 161.0 aarch64 URL follows the same pattern, check it at build time) |
| Checksum source | https://archive.mozilla.org/pub/firefox/releases/161.0/SHA512SUMS. Confirmed SHA512 lines for `linux-x86_64/en-US/firefox-161.0.tar.xz` (`4b83d5313082dbf9b9c16a961487ff3299d7da85a5b47a728cd88198aecb6341bd60eed4a7779c366fa2ff6e6017e0b10cad85d61701a8b6176bc616cd56dd6c`) and `linux-aarch64/en-US/firefox-161.0.tar.xz` (`a4689c3cdd88e240db36c6cca06a1c3411568a4a0c1c6ce9944d939e8c7ad78cb42eaea049bffecfc4b49fa6f55467f64529775c471a6736d0fad30fa733da63`). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-firefox/1be26bbc8f8aa6fea0e94f46a68bbc660a030d47/Dockerfile. Base `ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`; installs `firefox` from the xtradeb PPA; writes `/usr/lib/firefox/browser/defaults/preferences/firefox.js` (telemetry and first-run off); `ENV TITLE=Firefox PIXELFLUX_WAYLAND=true`; `COPY /root /`; `EXPOSE 3001`; `VOLUME /config`. No USER or ENTRYPOINT in the file. |
| Ports | 3001 (EXPOSE in upstream). Draft's 3000 is UNVERIFIED. The Selkies base's own web port is UNVERIFIED (base not fetched). |
| Env vars (real) | Only the image ENV values above are confirmed (`TITLE`, `PIXELFLUX_WAYLAND`). Firefox's own env vars: UNVERIFIED. |
| Data path | `/config` (VOLUME in upstream). Profile location under `/config`: UNVERIFIED, plan sets it explicitly with `--profile` (section 4). |
| Runtime libraries of the bare tarball | UNVERIFIED: not fetched. Must be determined at build time with `ldd` (section 11). |
| arm64 | Mozilla aarch64 tarball exists for 160.0.1 (HEAD 200). Upstream linuxserver image builds arm64 for this tag, UNVERIFIED for 161.0. |

## 2. Target layout

- `apps/firefox/Dockerfile`
- `apps/firefox/docker-bake.hcl`
- `apps/firefox/settings.yaml`
- `apps/firefox/container-test.yaml`
- `apps/firefox/start.sh`
- `apps/firefox/defaults/` only if a Firefox policy or prefs file is shipped (reason: upstream sets prefs in `firefox.js`; if we keep that, put the file in `defaults/` and copy it in the Dockerfile).

Never `root/` (reserved). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the build and the final stage (single stage is enough; no compile step). Fits because the app is a prebuilt tarball and Ubuntu provides the glibc userland. Closest sibling for a desktop-style app: `apps/kasmvnc` and `apps/xvfb` (both exist; not inspected in this run). Do not use `apps/xvfb` or `apps/kasmvnc` as the base; use them only as a display layer if section 10 decides so.

## 4. Dockerfile

1. `# syntax=docker/dockerfile:1`, `FROM <ubuntu digest>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the arch and pin the checksum in one `case`, so an unexpected arch fails:
   ```dockerfile
   RUN set -eux; \
     case "$TARGETARCH" in \
       amd64) MOZ_ARCH=linux-x86_64;  MOZ_SHA512=<sha512 for linux-x86_64 from SHA512SUMS> ;; \
       arm64) MOZ_ARCH=linux-aarch64; MOZ_SHA512=<sha512 for linux-aarch64 from SHA512SUMS> ;; \
       *) echo "unsupported arch $TARGETARCH" >&2; exit 1 ;; \
     esac; \
     curl -fsSL -o /tmp/firefox.tar.xz \
       "https://archive.mozilla.org/pub/firefox/releases/${VERSION}/${MOZ_ARCH}/en-US/firefox-${VERSION}.tar.xz"; \
     echo "${MOZ_SHA512}  /tmp/firefox.tar.xz" | sha512sum -c -; \
     tar -xJf /tmp/firefox.tar.xz -C /app; \
     rm -f /tmp/firefox.tar.xz
   ```
   The SHA512 literal for each arch comes from the SHA512SUMS file in section 1 (the amd64 and arm64 values for 161.0 are confirmed there).
3. Apt packages (runtime libraries, install only what `ldd` reports as missing on the base): candidates are `libgtk-3-0t64`, `libdbus-glib-1-2`, `libasound2t64`, `libxt6t64`, `libx11-xcb1`. Names are UNVERIFIED for Ubuntu 26.04 and must be confirmed with `apt-cache policy` at build time. Do not add them blind.
4. Keep the tarball layout: `/app/firefox/` (binary `firefox`, `firefox-bin`, libs). `ln -s /app/firefox/firefox /usr/local/bin/firefox`.
5. License and notices: the tarball has no separate license file in the path used; copy `/app/firefox/LICENSE` if present, else `UNVERIFIED` and note it, into `/usr/share/licenses/firefox/`.
6. Clean apt lists and `/tmp/*` in the same layer.
7. Final tail:
   ```dockerfile
   ENV TITLE=Firefox \
       HOME=/config \
       XDG_CACHE_HOME=/tmp/.cache \
       MOZ_CRASHREPORTER_DISABLE=1 \
       MOZ_DISABLE_AUTO_SAFE_MODE=1
   RUN chown -R apps:apps /app/firefox && chmod -R 755 /app/firefox
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 3001
   VOLUME /config
   ```
   `COPY --chmod=0755 . /` is mandatory. `ENV` values above are the plan; `MOZ_*` flags are UNVERIFIED for this build and must be checked against the running log.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "firefox"
}

variable "VERSION" {
  // renovate: datasource=custom.firefox depName=firefox versioning=loose
  default = "161.0"
}

variable "LICENSE" {
  default = "MPL-2.0" // UNVERIFIED, confirm before merge
}

variable "SOURCE" {
  default = "https://github.com/mozilla-firefox/firefox"
}
```

Then the four standard targets and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print` and check it exits 0.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mozilla-firefox/firefox"
ports:
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: TITLE
    default: "Firefox"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Port 3001 is the upstream EXPOSE. It is only useful if a display/web layer serves it (section 10). Draft's 3000 is not added.
- Env: only `TITLE` (read by the display layer, UNVERIFIED) and `TZ`. Do not invent Firefox env vars.
- Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/profile /tmp/.cache

cd /config
exec /app/firefox/firefox \
  --profile /config/profile \
  --no-remote
```

- Idempotent: profile dir created only when missing; nothing is written to `/app`.
- Caches go to `/tmp` (`XDG_CACHE_HOME`), never `/config`.
- Firefox must not auto-run the first-run wizard; the prefs file from upstream (`firefox.js` values) must be applied through `defaults/` or a policy file (section 2). UNVERIFIED that the prefs are loaded for a tarball install (they are read from the `defaults/pref` dir of the install path).
- Display: the binary needs `DISPLAY` or `WAYLAND_DISPLAY`. The display layer decision (section 10) sets it; start.sh must fail with a clear message if neither is set, instead of a silent exit.
- `exec` for PID 1 handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3001'
```

- Every `settings.yaml` port has a probe: 3001 only.
- `filePaths`: `/app/firefox/firefox` (exists), `/config/profile` is not checked because it is created at start.
- `timeoutSeconds`: UNVERIFIED value; take from a Selkies-based sibling if one is added. Default to a generous value (about 120) for a GUI start.
- The test runs with no env vars. A display-less run will not pass the TCP probe unless the display layer serves 3001 on its own. This is a blocker (section 10), not something to weaken.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/usr/lib/firefox/browser/defaults/preferences/firefox.js` (prefs) | Ship as `defaults/` file, copy to `/app/firefox/defaults/pref/` at build time (writes only at build, never at run). |
| `HOME` profile and `~/.mozilla` | `HOME=/config`, `--profile /config/profile`. |
| Caches `~/.cache` | `XDG_CACHE_HOME=/tmp/.cache`. |
| Crash reports, minidumps | `MOZ_CRASHREPORTER_DISABLE=1` (UNVERIFIED flag name for this version). |
| Content sandbox (needs user namespaces) | Under `--read-only`, it may fail. Open question (section 10). Do not add `privileged`. |

Draft's security expectations (root, `readOnlyRootFilesystem: false`, common root caps) are replaced: the target is `USER apps`, read-only rootfs with `/tmp` and `/config` only. Chart `runAsUser 0` is not carried over. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- **Blocker: display layer.** The draft's Selkies/VNC image is not available here. The tarball needs an X11 or Wayland display. Options: (a) use `apps/kasmvnc` or `apps/xvfb` as a dependency and wire `DISPLAY`/web port (not inspected in this run); (b) reject the app as out of scope for a headless base. Decide before building. Without this, protocol step 3 cannot show a readiness signal.
- **Blocker: sandbox.** Firefox's content sandbox uses user namespaces; under read-only rootfs it may need `MOZ_DISABLE_CONTENT_SANDBOX=1`. UNVERIFIED impact; document any use in the PR.
- Version drift: draft's URL resolved to the then-current release; pinning `161.0` avoids drift.
- arm64: aarch64 tarball exists; build and run unverified.
- Memory: the desktop plus browser is heavy; document a memory note in settings only if verified.
- Upstream `docker-entrypoint` (not applicable here): Selkies base scripts in `root/` are not fetched; any behavior they provide (desktop, icon, web UI) is UNVERIFIED and must not be assumed.
- Packages: runtime library names are UNVERIFIED (section 4 step 3).

## 11. Build and test steps

From `apps/firefox`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run and parse logs:
   ```sh
   docker run --rm -d --name firefox-probe --read-only --tmpfs /tmp \
     -v firefox-probe-config:/config firefox:161.0
   docker logs -f firefox-probe
   ```
   Expected readiness signal: process still running after the startup window, and the port 3001 open (`ss -ltn` inside the container). Check for `ldd` missing-library errors first: `docker run --rm --entrypoint sh firefox:161.0 -c 'ldd /app/firefox/firefox | grep "not found"'` must print nothing.
4. Clean up: `docker rm -f firefox-probe; docker volume rm firefox-probe-config`.
5. Test suite: `forgetool containers test --image firefox:161.0 --config ./apps/firefox/container-test.yaml`.
6. Do not build arm64 unless the amd64 failure is arm64-specific.

## 12. PR checklist

- Branch: `feat/add-firefox`. Commit: `feat(firefox): add new container`. Title matches the commit.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- State what is untested: at minimum, whether the display layer, the sandbox and arm64 were run, and that UNVERIFIED items (renovate datasource, license, runtime libs, prefs loading) are open.
- Downstream: none (not a `FROM` base), so no `DOWNSTREAM_CHANGES.md`.
