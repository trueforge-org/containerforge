# verysync — implementation plan
> Source: ./draft.md · Target: apps/verysync/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v2.33.2 (draft matches). Latest release, published 2026-10-11T13:14:33Z. Source: `gh api repos/Jonnyan404/verysync/releases/latest` |
| Renovate | `datasource=github-releases depName=Jonnyan404/verysync versioning=semver` (suggested; not confirmed on a fetched renovate config) |
| License | MIT (repo `license.spdx_id` = MIT; `LICENSE` in repo root). Source: `gh api repos/Jonnyan404/verysync` |
| Source URL | https://github.com/Jonnyan404/verysync |
| Release assets | `verysync-docker-v2.33.2-{amd64,arm64,armv7}.tar.gz` are OCI image archives for `docker load` (verified: `blobs/`, `index.json`, `manifest.json`). They are NOT used by this plan. |
| Binary tarballs used | Committed in the repo under `files/`: `https://raw.githubusercontent.com/Jonnyan404/verysync/master/files/verysync-linux-amd64-v2.33.2.tar.gz` and `.../verysync-linux-arm64-v2.33.2.tar.gz`. Each has one top directory `verysync-linux-<arch>-v2.33.2/` containing `verysync` (amd64 is an ELF x86-64 statically linked binary). |
| Per-arch | amd64: yes. arm64: yes (`files/verysync-linux-arm64-v2.33.2.tar.gz`). armv7: file exists, out of scope. |
| Checksums | Release docker archives: GitHub asset digests (amd64 `29646b1b8fd62ece78456883b415d1d109f9bbcac2d60e8ad10c58dcdf5ac7e4`, arm64 `0e497318d5d2bac03f2e4f499a073d3d96a86fe08e6efead48cfcc055da4b36b`). Raw tarballs: no upstream checksum file. Self-computed sha256 at 2026-11-25: amd64 `8a4b347669cd33def98b3bf1888576c8dc786ed77485080901bba0101c4413bd`, arm64 `708702fa19c321acb7e1aaa895a6f2cf8cb6189ab8ede6edf5049b61ad1f0ae0`. UNVERIFIED as upstream values; they pin the bytes we tested. |
| Upstream Dockerfile reviewed | https://github.com/Jonnyan404/verysync/blob/master/Dockerfile (HEAD; the draft pins 29eb0b8). Two stages on `alpine:latest`. Builder extracts the `files/` tarball for `TARGETPLATFORM` into `/usr/bin/verysync` and downloads `gosu` 1.19. Final stage adds `tzdata bash`, `/data` (chmod 777), user `nonverysync`, `HEALTHCHECK nc -z 127.0.0.1 ${PORT}`, `ENTRYPOINT /app/docker-entrypoint.sh`. ENV `TZ=Asia/Shanghai PORT=8886 VUID=0`. No `USER`, no `VOLUME`. |
| Entrypoint | https://github.com/Jonnyan404/verysync/blob/master/docker-entrypoint.sh: refuses non-root; with `VUID` runs `gosu $VUID verysync`, else runs directly; both pass `-no-browser -home /data/.config -gui-address :${PORT}`. |
| Real env vars | `PORT` (web UI port, default 8886), `VUID` (upstream only: uid to drop to; not applicable, see section 9), `TZ` (tzdata). No others found in README or entrypoint. |
| Ports | 8886 web UI (README: required, default 8886). 22330 data transfer (README: default 22330; plain `-p` so tcp by default). 22027/udp and 22037/udp LAN discovery (optional). 3000 public relay (optional). Source: https://github.com/Jonnyan404/verysync/blob/master/README.md |
| Data/config paths | Upstream: `-home /data/.config`; sync folder chosen in the web UI (README: set download dir to `/data`). |
| Dependencies | None. No database, no external service. |

## 2. Target layout

- `apps/verysync/Dockerfile`
- `apps/verysync/docker-bake.hcl`
- `apps/verysync/settings.yaml`
- `apps/verysync/container-test.yaml`
- `apps/verysync/start.sh`

No `defaults/`, `etc/`, `scripts/` or `health/` needed: the app creates its own config under `/config` on first start. No `root/`. No `DOWNSTREAM_CHANGES.md`: this app is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because the verysync binary is statically linked, so the glibc Ubuntu base is more than enough, and no runtime is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball per `TARGETARCH`, extracted into `/app`, `HOME=/config`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config PORT=8886`.
2. Map the arch with a `case`: `amd64` → `amd64`, `arm64` → `arm64`, anything else → `echo "unsupported arch" && exit 1`.
3. Pinned checksums as Dockerfile ARG defaults, bumped together with `VERSION`:
   `ARG SHA256_AMD64=8a4b347669cd33def98b3bf1888576c8dc786ed77485080901bba0101c4413bd` and `ARG SHA256_ARM64=708702fa19c321acb7e1aaa895a6f2cf8cb6189ab8ede6edf5049b61ad1f0ae0`.
4. Download `https://raw.githubusercontent.com/Jonnyan404/verysync/<COMMIT>/files/verysync-linux-${ARCH}-v${VERSION}.tar.gz` to `/tmp` (the bake `VERSION` is `2.33.2` without `v`; the upstream file names carry the `v`). Prefer a commit SHA over `master` for `<COMMIT>`, found with `gh api repos/Jonnyan404/verysync/commits?path=files/verysync-linux-amd64-v2.33.2.tar.gz`. The commit is UNVERIFIED until the implementer resolves it. Either way the sha256 check is mandatory: `echo "${SHA256} /tmp/verysync.tar.gz" | sha256sum -c -`.
5. `tar -xzf /tmp/verysync.tar.gz -C /tmp`, then `install -m 0755 /tmp/verysync-linux-${ARCH}-v${VERSION}/verysync /app/verysync/verysync` (create `/app/verysync` and `/usr/share/licenses/verysync` first with `mkdir -p`). Binaries belong in `/app` (read-only at runtime).
6. Ship the license: `curl -fsSL https://raw.githubusercontent.com/Jonnyan404/verysync/<COMMIT>/LICENSE -o /usr/share/licenses/verysync/LICENSE` (same commit, same pin).
7. `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -rf /tmp/*`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8886 22330
VOLUME /config
WORKDIR /app/verysync
```

Do not install `gosu`, `bash` or `tzdata` unless the build shows the Ubuntu base lacks `tzdata` for `TZ`. Do not add `VUID` handling (see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "verysync"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Jonnyan404/verysync versioning=semver
  default = "2.33.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Jonnyan404/verysync"
}
```

Then the default group and the four standard targets (`image`, `image-local`, `image-all`) copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `cd apps/verysync && docker buildx bake --print`. Renovate bumps `VERSION` only, so the two sha256 ARGs in the Dockerfile must be updated by hand in the same PR (open question 10).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Jonnyan404/verysync"
ports:
  - port: 8886
    protocol: tcp
    required: false
  - port: 22330
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "8886"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Port 22330 is listed only if the run in section 11 shows it listening at startup. Otherwise remove it and state why (section 8 needs a probe for every listed port). `VUID` is not listed because the image does not read it. No `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/verysync

exec /app/verysync/verysync \
  -no-browser \
  -home /config/verysync \
  -gui-address ":${PORT:-8886}"
```

- Idempotent: creates the config directory only, never overwrites state.
- Nothing is written to `/app`. The `-home` directory is the only persistent write.
- `:${PORT}` binds all interfaces, which the server-binding rule requires.
- `exec` hands PID 1 to verysync.
- Open question: whether the download/sync folder default lives under `-home`. If it does, it lands in `/config`, which is correct. Confirm in section 11.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8886'
- port: '22330'
http:
- port: '8886'
  path: /
filePaths:
- /app/verysync/verysync
- /usr/share/licenses/verysync/LICENSE
```

- The `22330` tcp probe is kept only together with its `settings.yaml` entry (section 6).
- The http path `/` is UNVERIFIED: the web UI may redirect or return a login page. Use the path that returns the expected status in the run.
- No `timeoutSeconds`, as in `apps/adguardhome-sync`, unless the run shows slow startup.
- The test runs with no env vars, which is fine: nothing in this app needs one to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path or behavior | Plan |
| --- | --- |
| `/data/.config` (`-home`) | `/config/verysync` (`-home` in start.sh). |
| `/data` (default download/sync dir, README) | Sync folders are chosen in the web UI. Default goes under `/config` unless the build shows otherwise. Optional extra volume `/data` is open question 11. |
| `gosu` / `VUID` / root start | Not applicable: the image runs as `apps` from the start. `VUID` is not supported. |
| `TZ=Asia/Shanghai` | Changed to `Etc/UTC` to match sibling defaults. |
| Self-update into its own install path (draft caveat) | UNVERIFIED. If verysync writes into `/app`, the read-only test in section 11 fails and the update must be disabled or redirected. Do not work around it without evidence. |
| Chart security (draft): runAsUser 0, readOnlyRootFilesystem true, privileged false, extra persistence `/data` and `/Sync` | Runs as `apps` (non-root). Read-only rootfs kept. Not privileged. `/config` is the single persistent volume; `/Sync` maps to nothing: there is no such path upstream and it is a chart detail. |

## 10. Risks, caveats and open questions

- Release assets are OCI image archives, not binaries. The plan uses the `files/` tarballs, so the draft's asset names are not the ones to fetch.
- Mutable source: the raw `master` URL can change. Mitigation: pin a commit SHA, and always sha256-check.
- No upstream checksum files for the raw tarballs. The pinned sha256 values were computed here.
- Redistribution: MIT covers the repo. The committed binaries are the upstream author's own build. Third-party components inside the Go binary were not inspected. Draft flagged this; it is a caveat to confirm, not a blocker found.
- `.metadata/release.sig` exists in each tarball. Its verification was not attempted (no public key found on a fetched page).
- LAN discovery (22027/22037 udp) and relay (3000) need host networking or explicit port mapping. Bridge networking limits discovery. Document in the PR.
- Open question 10: how renovate bumps the sha256 ARGs with `VERSION`. Hand-edit in the PR, or add a regex manager.
- Open question 11: add a `/data` volume (`required: false`) or keep one `/config` volume.
- Blockers: none confirmed.

## 11. Build and test steps

```sh
cd apps/verysync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name verysync-probe --read-only --tmpfs /tmp \
  -v verysync-probe-config:/config verysync:2.33.2
docker logs -f verysync-probe        # expected readiness: verysync starts and listens on :8886 (exact line UNVERIFIED; the upstream entrypoint prints a Chinese "service starting" banner)
ss -ltn                              # or a TCP probe: 8886 open; 22330 open only if listed
curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:8886/   # from the host, after publishing 8886

forgetool containers test --image verysync:2.33.2 --config ./container-test.yaml

docker rm -f verysync-probe; docker volume rm verysync-probe-config
```

- Empty `/config` on the first start, then a restart on the same volume, to check idempotency.
- arm64: build only if the amd64 build fails on an arm64-specific point. Not required for the draft.
- Scratch containers and volumes are removed between rounds.

## 12. PR checklist

- Branch `feat/add-verysync` from `main`. Commit and PR title `feat(verysync): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, every section and checkbox kept, only applicable boxes checked. Notes section contains `🤖 This PR is AI generated.`
- State what was not tested (arm64 build, the web UI login flow, LAN discovery, self-update) and do not tick "Built container locally" unless the build ran.
- Pre-completion: changes app-scoped; bake and Dockerfile version-aligned; no `DOWNSTREAM_CHANGES.md` (not a base).
