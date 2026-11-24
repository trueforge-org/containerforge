# proxmox-backup-server — implementation plan
> Source: ./draft.md · Target: apps/proxmox-backup-server/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `v4.2.0-1` is the latest ayufan release (published 2026-05-15). Draft tag `v4.2.0` is the PBS version without the packaging suffix. |
| Renovate | `datasource=github-releases depName=ayufan/pve-backup-server-dockerfiles versioning=loose` (the `-1` packaging suffix is not semver) |
| License | Proxmox Backup Server is AGPL-3.0 (UNVERIFIED: licence text not read; the ayufan README states none). Use `AGPL-3.0-or-later` only after checking the `.deb` copyright files. |
| Source URL | https://github.com/ayufan/pve-backup-server-dockerfiles (packaging); product https://www.proxmox.com/en/products/proxmox-backup-server/overview |
| Download URLs | amd64: `https://github.com/ayufan/pve-backup-server-dockerfiles/releases/download/v${VERSION}/proxmox-backup-server-v${VERSION}-amd64.tgz` (97 MB); arm64: same with `-arm64.tgz` (91 MB). Also published: `proxmox-backup-client-*.tgz` (static client). |
| Checksum source | No checksum file. GitHub API shows a SHA-256 `digest` per asset; pin both per-arch digests as `ARG`s when porting (UNVERIFIED values, read them at port time). |
| Upstream Dockerfile | `dockerfiles/Dockerfile.build` @v4.2.0-1 listed by the draft; README says the `dockerfiles` dir exists but how the tgz is installed was not readable. UNVERIFIED: install steps, entrypoint, user. The tgz contains Debian trixie `.deb` files and an `./install` script. |
| Ports | 8007/tcp HTTPS (web UI and API), self-signed certificate. No other port documented. |
| Env | Only `TZ` documented. |
| Auth | Default login `admin` / `pbspbs` (change after first login). |
| Paths | Chart persists `/etc/proxmox-backup`, `/var/lib/proxmox-backup`, `/var/log/proxmox-backup`, `/run` (README says `/run` must be tmpfs, otherwise `admin@pbs` authentication fails). Datastores live on a user mount. |
| Limitations | No ZFS, no shell, PAM auth not working. SMART needs devices plus `SYS_RAWIO`. |

## 2. Target layout

```
apps/proxmox-backup-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh          # seeds /config, links state dirs, starts api + proxy
  defaults/         # only if a seed file is needed (e.g. initial user.cfg, shadow.json)
```
No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits as the draft says (dpkg on ubuntu), but the debs target Debian trixie, so dependency drift is the main risk. Closest sibling: `apps/valkey` (pinned apt packages) and `apps/steamcmd` (non-trivial vendor payload).

## 4. Dockerfile

1. `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `ARG PBS_SHA256_AMD64`, `ARG PBS_SHA256_ARM64`, `USER root`.
2. Download `proxmox-backup-server-v${VERSION}-${TARGETARCH}.tgz` (TARGETARCH is `amd64`/`arm64`, matches asset names) into `/tmp`, verify with `sha256sum -c` using the arch-matching digest.
3. Extract to `/tmp/pbs`. Install with `apt-get install -y --no-install-recommends /tmp/pbs/*.deb` so apt resolves Ubuntu equivalents of Debian dependencies (do NOT use bare `dpkg -i`). UNVERIFIED: which debs are in the tgz and whether `proxmox-backup-server` resolves on 26.04 (libssl, libapt-pkg, fuse3, libacl, systemd stubs). If a dependency has no Ubuntu equivalent, stop and record as blocker (section 10).
4. Do not run the tgz `./install` script (it expects systemd and a host).
5. Remove systemd units/cron that cannot run; keep the binaries `/usr/sbin/proxmox-backup-api`, `proxmox-backup-proxy`, `proxmox-backup-manager`, `proxmox-backup-client`, and the web UI under `/usr/share/javascript/proxmox-backup` (UNVERIFIED paths; list with `dpkg -L`).
6. Licence files: `mkdir -p /usr/share/licenses/proxmox-backup-server && cp /usr/share/doc/proxmox-backup*/copyright ...`.
7. State redirects (root stage): replace `/etc/proxmox-backup`, `/var/lib/proxmox-backup`, `/var/log/proxmox-backup` with symlinks to `/config/etc`, `/config/lib`, `/config/log`, and `/run/proxmox-backup` to `/tmp/run`. Do `rm -rf` the package-created dirs first (UNVERIFIED that PBS follows symlinks and tolerates its own ownership checks; see section 9).
8. `ENV TZ=Etc/UTC HOME=/config`.
9. Cleanup: `apt-get clean`, remove `/var/lib/apt/lists/*` and `/tmp/*`.
10. `USER apps`
11. `COPY --chmod=0755 . /`
12. `EXPOSE 8007`, `VOLUME /config`, `CMD ["/start.sh"]`.
Version alignment: bake `VERSION` is `4.2.0-1`; Dockerfile asserts `test "$(dpkg-query -W -f='${Version}' proxmox-backup-server)" starts with "${VERSION%-*}"` after install (UNVERIFIED version format).

## 5. docker-bake.hcl

```hcl
variable "VERSION" {
  // renovate: datasource=github-releases depName=ayufan/pve-backup-server-dockerfiles versioning=loose extractVersion=^v(?<version>.+)$
  default = "4.2.0-1"
}
variable "APP"     { default = "proxmox-backup-server" }
variable "LICENSE" { default = "AGPL-3.0-or-later" }   // UNVERIFIED, confirm from debs
variable "SOURCE"  { default = "https://github.com/ayufan/pve-backup-server-dockerfiles/" }
```
Add `PBS_SHA256_AMD64` / `PBS_SHA256_ARM64` variables passed in `args` (no renovate automation; update with the version). Standard `docker-metadata-action`, `image`, `image-local`, `image-all`, `default` group copied from `apps/adguardhome-sync`. Check with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ayufan/pve-backup-server-dockerfiles/"
ports:
  - port: 8007
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /datastore
    required: false
dependencies: []
```
`/datastore` is the suggested mount for backup data (any path works). Do not list other env: none are documented.

## 7. start.sh

- `set -euo pipefail`. Create `/config/{etc,lib,log}` and `/tmp/run` (mode 0700 as PBS expects, UNVERIFIED).
- Seed only when missing: if `/config/etc` is empty, copy initial config from an image copy kept at `/defaults/etc-proxmox-backup` (created at build by copying the package-installed `/etc/proxmox-backup` before it is replaced by a symlink). Same for `/config/lib`.
- Admin password: upstream default `admin@pbs`/`pbspbs`; keep that default, and if the user sets none do not generate. No password env var is documented, so do not invent one (open question, section 10).
- Generate the self-signed TLS key/cert in `/config/etc` on first start if the packages do not do so (UNVERIFIED which tool; upstream does it via `proxmox-backup-api` first start).
- Start `proxmox-backup-api` in background, wait for its socket, then `exec proxmox-backup-proxy` (listens on `0.0.0.0:8007`). Use `trap` to stop the API on TERM.
- Never write under `/app` or the rootfs; all state goes to `/config` and `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8007'
filePaths:
- /start.sh
- /usr/sbin/proxmox-backup-proxy
- /usr/sbin/proxmox-backup-api
- /usr/share/licenses/proxmox-backup-server
```
Probe 8007 is a tcp probe (the endpoint is HTTPS with a self-signed cert, so an `http` probe would need TLS skip support; UNVERIFIED in forgetool). No env vars set in tests, and nothing needs one.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
|---|---|
| API daemon runs as root, proxy runs as user `backup` (UID 34) | Run both as `apps`. UNVERIFIED and likely the hardest part: PBS checks ownership/mode of `/etc/proxmox-backup` files against user/group `backup` and uses `chown`, `setuid`. May need a build-time patch or fail outright. |
| `/etc/proxmox-backup` | symlink to `/config/etc` |
| `/var/lib/proxmox-backup` | symlink to `/config/lib` |
| `/var/log/proxmox-backup` | symlink to `/config/log` |
| `/run/proxmox-backup` (README: `/run` must be tmpfs) | symlink to `/tmp/run` |
| Datastore | user mount, e.g. `/datastore`, writable by the `apps` UID |

Draft security expectations: runAsUser 0, `readOnlyRootFilesystem: false`. This plan deviates: UID `apps`, read-only rootfs. If PBS cannot run unprivileged, the fallback is "not feasible rootless" and the PR should not be opened (section 10).

## 10. Risks, caveats and open questions

- Blocker candidate: PBS daemons expect root and user `backup`; rootless may be impossible. Prove it in the first build round before any other work.
- Debian trixie debs on Ubuntu 26.04: missing or incompatible libs (UNVERIFIED).
- Release has no checksum file; digests must be copied from the API at port time.
- PAM auth does not work in the container (upstream), only `@pbs` realm.
- Self-signed certificate warning; no env var to supply a certificate was found.
- No password env var documented; default `pbspbs` is insecure and should be called out in the PR.
- No ZFS, no SMART without device passthrough.
- Datastore ownership and size: needs a large writable volume.
- arm64 asset exists (91 MB) but is untested.
- UNVERIFIED count: 8.

## 11. Build and test steps

```sh
cd apps/proxmox-backup-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create proxmox-backup-server-probe-config
docker run --rm -d --name proxmox-backup-server-probe --read-only --tmpfs /tmp \
  -v proxmox-backup-server-probe-config:/config proxmox-backup-server:<version>
docker logs -f proxmox-backup-server-probe   # expect proxy "listening"/started line, no auth or permission errors
curl -kI https://<container-ip>:8007/        # from another container on the same network
docker rm -f proxmox-backup-server-probe; docker volume rm proxmox-backup-server-probe-config
forgetool containers test --image proxmox-backup-server:<version> --config ./apps/proxmox-backup-server/container-test.yaml
```
Then log in as `admin@pbs`, create a datastore on `/datastore`, restart the container and confirm state persisted. Repeat with `--read-only` and a fresh volume.

## 12. PR checklist

- Branch `feat/add-proxmox-backup-server`; commit and PR title `feat(proxmox-backup-server): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: anything not actually run, in particular rootless operation, arm64, backup/restore with a client, and licence verification.
