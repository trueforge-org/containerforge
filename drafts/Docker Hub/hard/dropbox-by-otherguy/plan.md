# dropbox-by-otherguy — implementation plan
> Source: ./draft.md · Target: apps/dropbox-by-otherguy/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | UNVERIFIED: no pinned version. The wrapper image `otherguy/dropbox:latest` downloads the current Dropbox daemon at start (resolves the redirect of `https://www.dropbox.com/download/?plat=lnx.x86_64` and parses the version from it, per `docker-entrypoint.sh`). There is no tag to track. |
| Renovate | Not applicable: no versioned upstream release. The wrapper repo (https://github.com/otherguy/docker-dropbox) has no release asset used here. If a version label is needed, set `VERSION` to a date or a repo commit and leave renovate to `datasource=git-refs`; UNVERIFIED that this fits repo conventions, ask maintainers. |
| License | Dropbox daemon: proprietary (Dropbox terms), closed source. Wrapper scripts: UNVERIFIED (license of otherguy/docker-dropbox not checked). `LICENSE` in bake must be the license of the software in the image, so the image should contain only our scripts (which are not upstream code) and download the daemon at runtime. |
| Source URL | https://www.dropbox.com/install (the wrapper source is https://github.com/otherguy/docker-dropbox). |
| Downloads | amd64 only: https://www.dropbox.com/download?plat=lnx.x86_64 (redirects to a versioned tarball). Dropbox does not publish an arm64 Linux daemon in this flow (draft says `no`). The CLI helper `dropbox.py` comes from `https://www.dropbox.com/download?dl=packages/dropbox.py`. |
| Checksum | None published. UNVERIFIED. |
| Upstream Dockerfile reviewed | https://github.com/otherguy/docker-dropbox/blob/master/Dockerfile: `ubuntu:22.04`; apt `software-properties-common gnupg2 curl wget gosu tzdata ca-certificates python3-pip python3-gpg` plus X11/graphics libs (`libglapi-mesa libxext-dev libxdamage-dev libxshmfence-dev libxxf86vm-dev libxcb-*`); `ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 POLLING_INTERVAL=5 SKIP_SET_PERMISSIONS=false ENABLE_MONITORING=false`; `EXPOSE 17500`; `VOLUME /opt/dropbox`; user `dropbox` home `/opt/dropbox`; `ENTRYPOINT /docker-entrypoint.sh`, `CMD /opt/dropbox/bin/dropboxd`. |
| Entrypoint facts | Env read: `TZ DROPBOX_UID DROPBOX_GID POLLING_INTERVAL SKIP_SET_PERMISSIONS DROPBOX_SKIP_UPDATE ENABLE_MONITORING`. Runs as root then `gosu dropbox`; writes `/etc/timezone`, `/etc/localtime`; installs the daemon into `/opt/dropbox/bin`, creates `.dropbox-dist` as a locked dir to block self-update; removes `command_socket iface_socket unlink.db dropbox.pid` from `/opt/dropbox/.dropbox/`; installs `/usr/bin/dropbox` wrapper; monitoring via `prometheus_client` pip install. |

## 2. Target layout

```
apps/dropbox-by-otherguy/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `root/`, no `DOWNSTREAM_CHANGES.md`. App folder name per the draft is `dropbox-by-otherguy`; consider whether the name should be `dropbox` (open question).

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Closest sibling: `apps/steamcmd` (downloads a vendor binary at runtime/first start into a writable path).

## 4. Dockerfile

1. `ARG VERSION`; `USER root`.
2. `apt-get install -y --no-install-recommends python3 libglib2.0-0 libxcb1 libxext6 libxdamage1 libxxf86vm1 libxshmfence1 libgl1`; the daemon's real library needs are UNVERIFIED (the wrapper pulls the X11 list above because the Dropbox binary links them); verify with `ldd` on the downloaded `dropbox-lnx.x86_64-*/dropbox` and trim. `gosu`, `tzdata` and `pip` are not needed (we start as `apps`, TZ via env).
3. No daemon in the image: the daemon is proprietary, so redistributing it in a published image is a licensing risk (UNVERIFIED legal status), and it is amd64 only. Download happens in start.sh into `/config/bin` on first start.
4. Licenses: no upstream license text to ship; add our own note `/usr/share/licenses/dropbox-by-otherguy/README` stating the daemon is downloaded at runtime under Dropbox's terms.
5. `ENV HOME=/config DROPBOX_HOME=/config`; `COPY --chmod=0755 . /`; `EXPOSE 17500`; `VOLUME /config`; `USER apps`.
6. arm64: the image must not claim arm64. `image-all` is set to `linux/amd64` only, deviating from the standard two-platform list (open question for maintainers).

## 5. docker-bake.hcl

`APP=dropbox-by-otherguy`, `VERSION` = UNVERIFIED (no upstream version); use wrapper commit or date placeholder; `// renovate:` comment only if a datasource is chosen (e.g. `datasource=git-refs depName=https://github.com/otherguy/docker-dropbox`, UNVERIFIED), `LICENSE` = "LicenseRef-Dropbox-Proprietary" for the downloaded daemon (UNVERIFIED which SPDX to use), `SOURCE=https://www.dropbox.com/install`. Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 only), `default` group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.dropbox.com/install"
ports:
  - port: 17500
    protocol: tcp
    required: false
env:
  - {name: POLLING_INTERVAL, default: "5", required: false}
  - {name: DROPBOX_SKIP_UPDATE, default: "", required: false}
  - {name: ENABLE_MONITORING, default: "false", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
dependencies: []
```
Variable names verified in the upstream entrypoint. `DROPBOX_UID`, `DROPBOX_GID` and `SKIP_SET_PERMISSIONS` are dropped on purpose (we run as `apps`, no usermod/chown). `ENABLE_MONITORING` requires pip/prometheus, UNVERIFIED if kept. Port 17500 is the LAN sync port the daemon listens on (EXPOSE in upstream; draft calls it "web UI" which is wrong, UNVERIFIED role).

## 7. start.sh

- `mkdir -p /config/Dropbox /config/.dropbox /config/bin /tmp/dropbox`; export `HOME=/config`.
- Remove stale `command_socket iface_socket unlink.db dropbox.pid` from `/config/.dropbox/` at every start.
- If `/config/bin/dropboxd` is missing (or `DROPBOX_SKIP_UPDATE` unset and a newer version exists): read the `Location` redirect of the download URL, curl the tarball into `/tmp`, extract to `/config/bin`; if `DROPBOX_SKIP_UPDATE` is set and a binary exists, skip. Block self-update by `chmod 000` on `/config/.dropbox-dist` as upstream does.
- Keep logic idempotent; no writes to `/app`. First start needs internet.
- Keep the container alive while the daemon runs: `exec /config/bin/dropboxd` (the upstream polling loop and `/tmp` cleanup are replaced by tmpfs). `DROPBOX_UID`/`GID`/`gosu` logic is removed.
- Account linking prints a URL in the daemon log (standard Dropbox behavior, UNVERIFIED in this image).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
  - port: '17500'
filePaths:
  - /start.sh
  - /usr/share/licenses/dropbox-by-otherguy/README
```
No env is set by the test. Whether the daemon listens on 17500 before the account is linked, and whether the CI runner has internet to download it, is UNVERIFIED. If the port does not open before linking, this probe cannot pass and the `tcp` assertion must not be weakened: escalate to maintainers. `timeoutSeconds` is a guess (sibling `apps/steamcmd` not compared).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/dropbox/bin` (daemon), `/opt/dropbox/.dropbox-dist` | `/config/bin`, `/config/.dropbox-dist` |
| `/opt/dropbox/.dropbox` (account state) | `/config/.dropbox` |
| `/opt/dropbox/Dropbox` (synced files) | `/config/Dropbox` |
| `/etc/timezone`, `/etc/localtime` | env `TZ` only |
| `/usr/bin/dropbox`, `/opt/dropbox.py` | not installed (or in `/config/bin`) |
| `/tmp` | tmpfs |

Draft expects UID 0 and persistence of `/opt/dropbox/.dropbox` and `/opt/dropbox/Dropbox`. Reconciliation: UID `apps`, read-only rootfs, single volume `/config`. A user who wants a separate volume for synced files can mount `/config/Dropbox`. The daemon is documented to need file-system notification (inotify); `fs.inotify.max_user_watches` is a host setting (UNVERIFIED for this image).

## 10. Risks, caveats and open questions

- BLOCKER candidates: closed-source amd64-only daemon downloaded at runtime (no arm64, no checksum, no version pinning, network at first start), and a proprietary license with no SPDX id. The maintainers should decide if the project hosts such an image at all.
- The daemon may change behavior without notice (draft caveat); `DROPBOX_SKIP_UPDATE` helps but the self-update lock is needed.
- Draft caveats confirmed: manual account link is required.
- Dropbox supports only certain filesystems (ext4 etc.) for the synced folder, a claim from general knowledge, UNVERIFIED here.
- Upstream's `/opt/dropbbox.py` typo (found in entrypoint) means a download on every start: not copied.

## 11. Build and test steps

```sh
cd apps/dropbox-by-otherguy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dropbox-by-otherguy-probe --read-only --tmpfs /tmp \
  -v dropbox-by-otherguy-probe-config:/config dropbox-by-otherguy:<version>
docker logs -f dropbox-by-otherguy-probe
docker rm -f dropbox-by-otherguy-probe; docker volume rm dropbox-by-otherguy-probe-config
forgetool containers test --image dropbox-by-otherguy:<version> --config ./apps/dropbox-by-otherguy/container-test.yaml
```
Expected readiness signal: daemon log asking to link the account ("This computer isn't linked to any Dropbox account", UNVERIFIED wording), process still running, port 17500 open.

## 12. PR checklist

- Branch `feat/add-dropbox-by-otherguy`, commit `feat(dropbox-by-otherguy): add new container`, PR template filled, only applicable boxes checked.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user, https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything (build, runtime download, port 17500, arm64 is unsupported by design); no license or version verified.
