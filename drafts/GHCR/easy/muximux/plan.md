# muximux — implementation plan
> Source: ./draft.md · Target: apps/muximux/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v3.7.4 (published 2026-11-24T23:52:46Z). The draft pins v3.7.3, which is out of date. Source: https://api.github.com/repos/mescon/Muximux/releases/latest |
| Chart image | Draft: `ghcr.io/mescon/muximux:3.7.3`. Its tag must not be used; we build from the release binary. |
| Renovate | `datasource=github-releases depName=mescon/Muximux versioning=semver` (tags carry the `v` prefix, so `VERSION = "v3.7.4"`) |
| License | GPL-2.0. LICENSE text reads "GNU GENERAL PUBLIC LICENSE Version 2, June 1991" (https://raw.githubusercontent.com/mescon/Muximux/main/LICENSE). Exact SPDX suffix (-only vs -or-later) UNVERIFIED: use `GPL-2.0-only` only after confirming the header; otherwise `GPL-2.0`. |
| Source URL | https://github.com/mescon/Muximux |
| Documentation | https://github.com/mescon/Muximux/blob/main/docs/wiki/README.md (not read in this run) |
| Download amd64 | https://github.com/mescon/Muximux/releases/download/v3.7.4/muximux-linux-amd64 |
| Download arm64 | https://github.com/mescon/Muximux/releases/download/v3.7.4/muximux-linux-arm64 |
| Checksum source | `https://github.com/mescon/Muximux/releases/download/v3.7.4/checksums.txt` (format `<sha256>  <name>`). amd64 `20623f410178f91dcc9cfcff7e889f7c0beb45e3382e0ceb30f99863be776a4a`, arm64 `65d227d03a9ff0f9153a23a127bcb04ca2ef3eef832a013f660430eb3998fc7a`. |
| SBOM | https://github.com/mescon/Muximux/releases/download/v3.7.4/muximux-sbom.spdx.json |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/mescon/Muximux/main/Dockerfile (summary via WebFetch). Three stages: `node:26-alpine` frontend build, `golang:1.27-alpine` static build (`CGO_ENABLED=0`, tag `embed_web`), `alpine:3.24` runtime with `docker-entrypoint.sh`, `PUID=1000`, `PGID=1000`, `XDG_DATA_HOME=/app/data`, `VOLUME /app/data`, `EXPOSE 8080`, HEALTHCHECK `wget http://localhost:8080/api/health`, `CMD ./muximux --data /app/data`, no `USER`. |
| Ports | 8080/http (EXPOSE and HEALTHCHECK, confirmed) |
| Env vars (real) | `PUID`, `PGID` (read by upstream entrypoint only; dropped here, see section 4), `XDG_DATA_HOME` (set upstream; Caddy cert/ACME storage). No other env var confirmed from the Dockerfile. UNVERIFIED: any app-level env var (the wiki was not read). |
| Data / config write paths | Upstream: `/app/data` via `--data`. Draft: `/config`. Use `--data /config`. |
| arm64 | Yes (asset confirmed). |
| Dependencies | None. |

## 2. Target layout

- `apps/muximux/Dockerfile`
- `apps/muximux/docker-bake.hcl`
- `apps/muximux/settings.yaml`
- `apps/muximux/container-test.yaml`
- `apps/muximux/start.sh`

Not needed: `defaults/` (Muximux creates its config on first start, UNVERIFIED for every path), `etc/`, `health/`, `root/` (never used), `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The upstream `docker-entrypoint.sh` is not copied: it runs as root and drops privileges, which does not fit `USER apps`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The Muximux binary is `CGO_ENABLED=0` static, so it runs on glibc Ubuntu; no musl runtime is needed, and the upstream alpine base is not copied. Closest siblings: `apps/adguardhome-sync` (prebuilt Go binary, `/app` binary, port 8080) and `apps/cni-plugins` (release download with ARG TARGETARCH).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (buildx `amd64`/`arm64` match the asset names directly).
2. `USER root` for the download step only, then `USER apps` at the end. No `apt-get` needed; `curl` is in the base.
3. Download and verify, in `/tmp`:
   ```sh
   curl -fsSL -o /tmp/muximux "https://github.com/mescon/Muximux/releases/download/${VERSION}/muximux-linux-${TARGETARCH}"
   curl -fsSL -o /tmp/checksums.txt "https://github.com/mescon/Muximux/releases/download/${VERSION}/checksums.txt"
   awk -v f="muximux-linux-${TARGETARCH}" '$2==f {print $1"  /tmp/muximux"}' /tmp/checksums.txt | sha256sum -c -
   ```
   The awk line rewrites the checksum entry to point at the downloaded file. If the awk result is empty, the check must fail the build (`sha256sum -c` on empty input exits 0, so also add a `test -s` guard on the awk output).
4. Install: `install -m 0755 /tmp/muximux /app/muximux`, then `chown -R apps:apps /app` (the `apps` user owns `/app` per the existing siblings, read-only at runtime).
5. License: the upstream LICENSE comes from the repo, not the release asset. `curl -fsSL -o /usr/share/licenses/muximux/LICENSE https://raw.githubusercontent.com/mescon/Muximux/v3.7.4/LICENSE` (mkdir first). Use the tag path so the license matches the binary.
6. `rm -f /tmp/muximux /tmp/checksums.txt`.
7. Environment:
   ```dockerfile
   ENV XDG_DATA_HOME=/config \
       XDG_CACHE_HOME=/tmp
   ```
   Caddy keeps certs under `XDG_DATA_HOME` (persistent, `/config`). `XDG_CACHE_HOME=/tmp` keeps caches off `/config`, per the rules. UNVERIFIED that the binary honours both variables; check at the run step (section 11).
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   ```
   `COPY --chmod=0755 . /` is required and must stay.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "muximux"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mescon/Muximux versioning=semver
  default = "v3.7.4"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/mescon/Muximux"
}
```

Then the default group and the `image`, `image-local` and `image-all` targets copied from `apps/adguardhome-sync/docker-bake.hcl`. Change `LICENSE` to `GPL-2.0-only` only if the SPDX suffix is confirmed. Run `docker buildx bake --print` in `apps/muximux`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mescon/Muximux"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  []
```

- `TZ` is read by the Go runtime and the system; keep it only as a common default (sibling `apps/adguardhome-sync` lists it). Do not list `PUID`/`PGID`: the image does not read them.
- `XDG_DATA_HOME` is set in the Dockerfile, not an input, so it is not listed.
- Port 8080 is the only declared port; the container test must probe it (section 8).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app
exec /app/muximux --data /config
```

- Idempotent: `mkdir -p` on an empty `/config`; Muximux creates its own config and data on first start (UNVERIFIED for file names; check the log on the empty-volume run).
- No writes to `/app`. The binary is not modified at runtime.
- Binds: the upstream listens on 8080; confirm it binds `0.0.0.0` (not localhost) at the run step. If it binds only localhost, add the bind flag the binary provides (UNVERIFIED: flag name, wiki not read).
- `exec` hands PID 1 to the binary.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /api/health
filePaths:
- /app/muximux
- /usr/share/licenses/muximux/LICENSE
```

- Every port in `settings.yaml` (8080) has a `tcp` probe, and an `http` probe on the health endpoint that upstream's HEALTHCHECK uses.
- No env var is required to start, so no `filePaths` for required-env paths.
- `timeoutSeconds: 120` is a choice; siblings range 120-240 (e.g. `apps/babybuddy` 180).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (`--data`, config and state) | `--data /config` in start.sh |
| `XDG_DATA_HOME=/app/data` (Caddy certs, ACME state) | `XDG_DATA_HOME=/config` (persistent, as the draft expects) |
| Caddy cache (if any) | `XDG_CACHE_HOME=/tmp` |
| `PUID` / `PGID` and `su-exec` privilege drop | Removed. Runtime user is `apps` (568). Volume ownership must match `apps` (chart runs as 568 in the draft; see section 10). |
| `/app` | Read-only at runtime; binary only. |

Draft expectations reconciled: the chart runs as UID 0 with `runAsNonRoot false`, but the image itself runs as `apps` and needs no root at runtime. `readOnlyRootFilesystem` is compatible with `--read-only --tmpfs /tmp`. Not privileged, no host mounts.

## 10. Risks, caveats and open questions

- **Data migration (draft caveat).** The chart stores config in `/app/data`; this image uses `/config`. Existing installs must copy their data to the new `/config` before upgrading.
- **Upstream entrypoint dropped.** Upstream starts as root and uses `PUID`/`PGID`. Our image runs as `apps`, so existing `PUID`/`PGID`-based volume ownership will not be re-mapped. Document in the PR.
- **Frame embedding (draft caveat).** Muximux embeds other web apps in frames; mixed HTTP/HTTPS or blocked frame headers break the embedded views (inferred).
- **Binary wiki details not read.** App-level env vars, the bind flag and the first-run file layout are UNVERIFIED. Confirm at the run step before adding any env var to `settings.yaml`.
- **Health endpoint.** `/api/health` is from the upstream HEALTHCHECK, not from a live call. Confirm with the run step.
- **License suffix.** GPL-2.0 vs GPL-2.0-only not confirmed.
- No blockers: static Go binary, arm64 asset present, no dependencies, no GPU.

## 11. Build and test steps

```sh
cd apps/muximux
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name muximux-probe --read-only --tmpfs /tmp \
  -v muximux-probe-config:/config muximux:v3.7.4
docker logs -f muximux-probe
curl -fsS http://127.0.0.1:8080/api/health   # from the host, after publishing or via docker exec
docker rm -f muximux-probe; docker volume rm muximux-probe-config
forgetool containers test --image muximux:v3.7.4 --config ./apps/muximux/container-test.yaml
```

Expected readiness signal: the log shows the server listening on port 8080 (exact text UNVERIFIED; take it from the first run's log), the process stays up, and no fatal errors. Run once with an empty `/config` volume and once more on the same volume to confirm restart behaviour.

## 12. PR checklist

- [ ] Branch `feat/add-muximux`, commit `feat(muximux): add new container`, PR title the same.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` check shows status).
- [ ] PR template `.github/PULL_REQUEST_TEMPLATE.md` kept; only applicable boxes checked.
- [ ] Data-migration note for existing `/app/data` installs in the PR description.
- [ ] Not tested: arm64 build, forgetool test run, any env vars beyond the ones listed. Say so in the PR unless done.
- [ ] `docker buildx bake --print` run for the bake and Dockerfile changes.
