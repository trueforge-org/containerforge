# authelia — implementation plan
> Source: ./draft.md · Target: apps/authelia/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **v4.39.28** (published 2026-09-17T12:13:30Z, GitHub `releases/latest`). Matches the draft. |
| Renovate | `// renovate: datasource=github-releases depName=authelia/authelia versioning=semver` |
| License | Apache-2.0 (GitHub API `license.spdx_id`) |
| Source URL | https://github.com/authelia/authelia |
| Download (amd64) | https://github.com/authelia/authelia/releases/download/v4.39.28/authelia-v4.39.28-linux-amd64-musl.tar.gz (in the release asset list; musl build, draft choice) |
| Download (arm64) | https://github.com/authelia/authelia/releases/download/v4.39.28/authelia-v4.39.28-linux-arm64-musl.tar.gz (in the release asset list) |
| Non-musl alternatives | `authelia-v4.39.28-linux-amd64.tar.gz` and `authelia-v4.39.28-linux-arm64.tar.gz` also exist. Either works on glibc Ubuntu; keep the musl pair to match the draft unless the binary fails to run. |
| Checksums | https://github.com/authelia/authelia/releases/download/v4.39.28/checksums.sha256 (signed by `checksums.sha256.sig`). Values read from it: amd64-musl `ce2526b633ce3eec06680fae2f26060dc8cef3a92cdbc376410b28bcca6c97e1`, arm64-musl `7c4e6537f575f70b25af19a8695635b51510eacb4c6fd8b5a6338262af4baae4`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/authelia/authelia/8da42b2348b0351c6284a2940a9c5eec3d4cd3fd/Dockerfile: `FROM authelia/base:${TAG}@sha256:${SHA}`, copies `authelia-${TARGETOS}-${TARGETARCH}/authelia` to `/app`, copies `LICENSE`, `entrypoint.sh`, `healthcheck.sh`, `.healthcheck.env`; `ENTRYPOINT ["/app/entrypoint.sh"]`; `HEALTHCHECK CMD /app/healthcheck.sh`; `EXPOSE 9091`; `ENV PATH=/app:$PATH PUID=0 PGID=0 X_AUTHELIA_CONFIG=/config/configuration.yml`; no USER, no VOLUME. |
| Port | 9091/tcp (`EXPOSE` in upstream Dockerfile). |
| Env vars confirmed | `X_AUTHELIA_CONFIG` (=/config/configuration.yml), `PUID`, `PGID` (used by upstream base/entrypoint; **we do not use the authelia base, so drop PUID/PGID**). |
| Env vars NOT confirmed | Authelia's own `AUTHELIA_*` overrides and the JWT/session/storage secret env names: UNVERIFIED (docs not fetched). Do not list them until checked. |
| Config path | `/config/configuration.yml` (via `X_AUTHELIA_CONFIG`). Not copied into the image. |
| Data path | SQLite (optional) and user database file: path is set in the config (UNVERIFIED which key/path); keep it under `/config`. |
| Dependencies | valkey and postgresql are **optional** (`apps/valkey`, `apps/postgresql` both exist, ✅). Not hard dependencies. |

## 2. Target layout

- `apps/authelia/Dockerfile`
- `apps/authelia/docker-bake.hcl`
- `apps/authelia/settings.yaml`
- `apps/authelia/container-test.yaml`
- `apps/authelia/start.sh`

No `defaults/` unless the seeded config template is kept as a file (recommended: `defaults/configuration.yml` seeded to `/config` only when missing, see section 7). No `etc/`, `root/`, `health/` (the image's own `healthcheck.sh` is not needed; use a `tcp`/`http` check in tests). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (brief's exact string; siblings use tag `26.4` with the same digest).

Fits because Authelia is one static Go binary (musl build runs on glibc). Closest siblings: `apps/valkey` (prebuilt binary on ubuntu, `/config` data) and `apps/adguardhome-sync` (prebuilt binary with arch mapping). Upstream `authelia/base` is not used: it is an Alpine-style base with PUID/PGID handling we do not need.

## 4. Dockerfile

Single stage (prebuilt binary, nothing to compile).

1. `ARG VERSION` (= `docker-bake.hcl` VERSION, `4.39.28`), `ARG TARGETARCH`.
2. `USER root` only for the download and install steps.
3. Install packages only if missing from the base: check `ca-certificates` and `curl` (the base carries curl and tar per siblings; confirm). `rm -rf /var/lib/apt/lists/*`.
4. Download and verify in `/tmp`:
   ```sh
   cd /tmp
   asset="authelia-v${VERSION}-linux-${TARGETARCH}-musl.tar.gz"
   base="https://github.com/authelia/authelia/releases/download/v${VERSION}"
   curl -fsSL -o "${asset}" "${base}/${asset}"
   curl -fsSL -o checksums.sha256 "${base}/checksums.sha256"
   grep " ${asset}\$" checksums.sha256 | sha256sum -c -
   mkdir -p /tmp/authelia && tar -xzf "${asset}" -C /tmp/authelia
   ```
   Check `TARGETARCH` is `amd64` or `arm64` and fail on anything else. The checksum file is signed (`checksums.sha256.sig`); verifying the signature is optional and not done in this plan (note it in the PR).
5. Install the binary: `install -D -m 0755 /tmp/authelia/authelia /app/authelia/authelia`. Confirm the member name in the tar with `tar -tzf` on the first build (UNVERIFIED: the tar layout was not listed here; the upstream Dockerfile copies `authelia-${TARGETOS}-${TARGETARCH}/authelia`, so the member may sit in a directory).
6. License: `install -D -m 0644 <LICENSE> /usr/share/licenses/authelia/LICENSE`. Take it from the upstream source tarball `https://github.com/authelia/authelia/archive/refs/tags/v4.39.28.tar.gz` (not fetched: UNVERIFIED) or from the release tar if it carries one (UNVERIFIED).
7. Seed template: `COPY --chmod=0644 defaults/configuration.yml /defaults/configuration.yml` (the template, not a secret). Keep it free of real secrets.
8. `ENV X_AUTHELIA_CONFIG=/config/configuration.yml PATH=/app/authelia:$PATH`.
9. `rm -rf /tmp/authelia /tmp/*.tar.gz /tmp/checksums.sha256`, then `mkdir -p /config && chown apps:apps /config`.
10. Final lines:
    ```dockerfile
    USER apps
    COPY --chmod=0755 . /
    EXPOSE 9091
    VOLUME /config
    WORKDIR /app/authelia
    ENTRYPOINT ["/start.sh"]
    ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "authelia"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=authelia/authelia versioning=semver
  default = "4.39.28"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/authelia/authelia"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate: `cd apps/authelia && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/authelia/authelia"
ports:
  - port: 9091
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: X_AUTHELIA_CONFIG
    default: "/config/configuration.yml"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
opt_dependencies:
  - valkey
  - postgresql
```

Rules: list only env names the binary or start.sh actually read. Do not add `PUID`/`PGID` (not used). Add `AUTHELIA_*` overrides only after they are verified (section 1). `dependencies` stays empty because both DB and valkey are optional; this keeps the database exception out of scope.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `export X_AUTHELIA_CONFIG="${X_AUTHELIA_CONFIG:-/config/configuration.yml}"`.
- Create `/config` if missing. If `${X_AUTHELIA_CONFIG}` does not exist, seed it from `/defaults/configuration.yml` **only when missing**. The seeded file needs generated secrets: generate with `openssl rand -hex 64` (or `head -c 64 /dev/urandom | base64`) into the file **once**, and never overwrite an existing config. Secrets must not appear on the process list or in logs.
- Storage: the template points the SQLite database at `/config` (UNVERIFIED key name; confirm against the Authelia config reference).
- Bind to all interfaces: the server's listen address is set in the config (UNVERIFIED key/default). Set `0.0.0.0` in the seeded template.
- No writes to `/app`. Scratch in `/tmp`.
- Final line: `exec /app/authelia/authelia --config "${X_AUTHELIA_CONFIG}"` (the `--config` flag is UNVERIFIED: confirm with `authelia --help` on the first build).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /app/authelia/authelia
- /config
tcp:
- port: '9091'
httpCommands: []
```

- Authelia with the seeded config and SQLite should run without an external DB, so the full run check is in scope. Use an `http` probe on the health endpoint only after confirming the path (UNVERIFIED; commonly `/api/health`).
- A test-only check must not weaken the run: if the seeded config is not generated in the test, the file path check on `/config/configuration.yml` will fail, which is correct.
- `timeoutSeconds`: use the value from a sibling (e.g. `apps/valkey` or another Go-binary app) unless the forgetool default is enough.
- Coverage: the `tcp` probe covers the one `settings.yaml` port.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs with `PUID=0`/`PGID=0` (root) through the authelia base entrypoint. We drop that: final stage `USER apps` (UID 568).
- Read-only rootfs: binary and templates live under `/app` and `/defaults` (read-only at runtime). Writable state: `/config` (config + SQLite) and `/tmp`.
- `/config` must be `apps:apps` at build time so an empty volume works.
- No privileged, no extra persistence beyond `/config`. Chart expectations (draft): non-root yes, read-only yes, privileged no, confidence high.
- Reverse proxy and TLS in front are a runtime concern (draft caveat, inferred); not enforced by the image.

## 10. Risks, caveats and open questions

- **Unverified config names**: session/storage/JWT/secret config keys and `AUTHELIA_*` env overrides were not fetched. The plan avoids inventing them; verify before writing the template.
- **Secrets**: generated once on first start and written to `/config`. Never commit or log them.
- **Musl binary on glibc Ubuntu**: expected to run (static musl build). Confirm during the first run.
- **Draft mention of arm64 debs**: not seen in the release asset list; the plan uses the tarballs. Draft statement is UNVERIFIED.
- **Checksum signature**: `checksums.sha256.sig` is published; the plan verifies the hash only, not the signature. Note it in the PR.
- **Blockers**: none known. Both architectures have published assets.
- **Base tag string**: `26.04` (brief) vs `26.4` (siblings); same digest; confirm.

## 11. Build and test steps

```sh
cd apps/authelia
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

# Run check (fresh /config volume, read-only rootfs)
docker volume create authelia-probe-config
docker run --rm -d --name authelia-probe --read-only --tmpfs /tmp \
  -v authelia-probe-config:/config authelia:4.39.28
docker logs -f authelia-probe
docker rm -f authelia-probe; docker volume rm authelia-probe-config

# Test suite (mirrors CI)
forgetool containers test --image authelia:4.39.28 --config ./apps/authelia/container-test.yaml
```

- Expected readiness signal: Authelia log line indicating the server listening on port 9091 (exact wording UNVERIFIED; record it from the first run).
- Also run with a pre-seeded config (second volume) to test non-empty `/config` restart.
- Not run in this planning step: nothing was built.

## 12. PR checklist

- Branch `feat/add-authelia`, commit `feat(authelia): add new container`, PR title matching.
- PR template at `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; only tick what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- Say what was not tested (arm64 run, secret generation path, signature verification not done).
- Protocol checks: `docker buildx bake --print` passes; image-local build; empty `/config` start; `container-test.yaml` assertions pass; no assertion weakened; scratch containers and volumes removed.
- No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
