# nebula-sync — implementation plan
> Source: ./draft.md · Target: apps/nebula-sync/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.11.3` (release tag `v0.11.3`, published 2026-10-20). Confirmed latest via `gh api repos/lovelaze/nebula-sync/releases/latest`. Draft matches. Source: https://api.github.com/repos/lovelaze/nebula-sync/releases/tags/v0.11.3 |
| Renovate | `// renovate: datasource=github-releases depName=lovelaze/nebula-sync versioning=semver` |
| License | MIT (https://raw.githubusercontent.com/lovelaze/nebula-sync/main/LICENSE). Use `LICENSE = "MIT"` in bake. |
| Source URL | https://github.com/lovelaze/nebula-sync |
| Per-arch download | amd64: https://github.com/lovelaze/nebula-sync/releases/download/v0.11.3/nebula-sync_0.11.3_linux_amd64.tar.gz · arm64: https://github.com/lovelaze/nebula-sync/releases/download/v0.11.3/nebula-sync_0.11.3_linux_arm64.tar.gz |
| Checksum source | `checksums.txt` release asset (name confirmed in the release API). Its line format is `UNVERIFIED: checksums.txt contents were not fetched`; read the file once before writing the `sha256sum` step. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/lovelaze/nebula-sync/v0.11.3/Dockerfile: builder `golang:1.26-alpine`, `CGO_ENABLED=0`, `-trimpath -w -s`, `-X …/version.Version=$VERSION`; final `FROM scratch`; `USER 1001`; `ENV API_ENABLED=true`; `HEALTHCHECK` runs `nebula-sync healthcheck`; `ENTRYPOINT ["nebula-sync"]`, `CMD ["run"]`; no EXPOSE, no VOLUME. |
| Binary type | Static Go binary (CGO off), so it runs on glibc Ubuntu. No musl issue. |
| Ports | UNVERIFIED: the README does not state a listen port, and upstream has no EXPOSE. Only the optional `API_ENABLED` server is mentioned by name. |
| Config and data paths | UNVERIFIED: the README names no config file or data directory for nebula-sync itself. Upstream declares no VOLUME. |
| Env vars (README) | Required: `PRIMARY` (`URL\|password`), `REPLICAS` (comma-separated), `FULL_SYNC` (true/false). File alternatives: `PRIMARY_FILE`, `REPLICAS_FILE`. Optional: `CRON` (no default), `RUN_GRAVITY` (false), `TZ`, `CLIENT_SKIP_TLS_VERIFICATION` (false), `CLIENT_RETRY_DELAY_SECONDS` (1), `CLIENT_TIMEOUT_SECONDS` (20). Selective sync (`FULL_SYNC=false` only): `SYNC_CONFIG_{DNS,DHCP,NTP,RESOLVER,DATABASE,MISC,DEBUG}`, `SYNC_GRAVITY_{…}`, `SYNC_CONFIG_<SECTION>_{INCLUDE,EXCLUDE}`. Webhooks: `WEBHOOK_SYNC_<SUCCESS\|FAILURE>_{URL,METHOD,BODY,HEADERS}`, `WEBHOOK_CLIENT_SKIP_TLS_VERIFICATION`. Source: https://raw.githubusercontent.com/lovelaze/nebula-sync/main/README.md |
| Dependencies | External Pi-hole (v6) or AdGuard Home instances as source and target. No ContainerForge app dependency. |
| arm64 | Yes: `linux_arm64` tarball is a release asset. |

Draft corrections: none on version. The draft's "Ports: none" is right in practice, but the port question is still open (section 10).

## 2. Target layout

Files in `apps/nebula-sync/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: validates required env, then `exec`s the binary)
- `defaults/` — not needed (nebula-sync takes everything from env, no seeded config file)
- `DOWNSTREAM_CHANGES.md` — not needed (not used as a `FROM` base)
- `root/` — never used

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why: the upstream binary is static, so it needs no runtime packages. Ubuntu is the generic base in the protocol table for prebuilt binaries.
- Closest sibling: `apps/adguardhome-sync` (prebuilt Go tarball from GitHub release, `USER apps`, `/app` binary, `start.sh` that `exec`s it).
- No runtime image needed. The draft's "Runtime image: none" is confirmed.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download the release tarball for `TARGETARCH` into `/tmp`. Map `TARGETARCH` to the release name: `amd64` → `linux_amd64`, `arm64` → `linux_arm64`. Use `curl -fL` and `-o /tmp/nebula-sync.tar.gz`.
3. Download `checksums.txt` for the same tag and verify the tarball with `grep " nebula-sync_${VERSION}_linux_${arch}.tar.gz$" checksums.txt | sha256sum -c -`. Mark this step as not yet tested, since the file format is UNVERIFIED.
4. Extract only the binary (`tar xzf … -C /app nebula-sync`). Check the tarball's member list first, since it may also hold LICENSE and README.
5. Ship the license under `/usr/share/licenses/nebula-sync/` (MIT, from the upstream LICENSE, fetched from the tag, not from `main`).
6. `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -f /tmp/nebula-sync.tar.gz`.
7. `ENV API_ENABLED=true`, mirroring upstream. Upstream sets it, so it is safe to keep. Document it in `settings.yaml` only if the app reads it (see section 6).
8. `USER apps`, `COPY --chmod=0755 . /`.
9. `VOLUME /config` only if start.sh writes state there. Current plan: no writes, so skip. Final decision after section 7 review.

Keep `COPY --chmod=0755 . /` as the required directive.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "nebula-sync"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=lovelaze/nebula-sync versioning=semver
  default = "0.11.3"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/lovelaze/nebula-sync"
}

group "default" {
  targets = ["image-local"]
}

target "image" { … args VERSION, labels source and licenses … }
target "image-local" { inherits = ["image"]; output = ["type=docker"]; tags = ["${APP}:${VERSION}"] }
target "image-all" { inherits = ["image"]; platforms = ["linux/amd64", "linux/arm64"] }
```

Validate with `docker buildx bake --print` from `apps/nebula-sync/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/lovelaze/nebula-sync"
ports:
  []   # UNVERIFIED: no listen port documented; revisit once the API port is confirmed
env:
  - name: PRIMARY
    default: ""
    required: true
  - name: REPLICAS
    default: ""
    required: true
  - name: FULL_SYNC
    default: "true"
    required: true
  - name: CRON
    default: ""
    required: false
  - name: RUN_GRAVITY
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

Notes:

- `required: true` env vars need a non-empty default or handling in `start.sh`. `PRIMARY` and `REPLICAS` have no safe default, so the rule in `settings-yaml.instructions.md` conflicts with the app. Resolve this in section 10 before writing the file.
- `volumes`: none, since no state is written. If an empty-`/config` requirement applies, add `/config` as `required: true` and seed nothing.
- Do not add the selective-sync variables by default. List only what `start.sh` or the app reads.

## 7. start.sh

- `#!/usr/bin/env bash` with `set -euo pipefail`.
- Validate `PRIMARY` and `REPLICAS` (or `*_FILE`) and `FULL_SYNC`. If missing, print one clear line to stderr and exit 1. This keeps the no-env test path honest.
- Set `TZ` default to `Etc/UTC` only if unset.
- `cd /app` and `exec /app/nebula-sync run`. Do not add `CRON` defaults silently (see section 10).
- Do not write to `/app`. Nothing under `/config` is needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /app/nebula-sync
```

- No `tcp` or `http` probe, because no port is confirmed (see section 10). Add one only once the port is known.
- The test runs with no env vars, so the required-env path in `start.sh` is what runs. Add an assertion for it only if forgetool supports one; otherwise cover it manually in section 11.
- `timeoutSeconds`: not set. `apps/adguardhome-sync/container-test.yaml` sets none either, so the forgetool default applies.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (UID from the base image), not root, as set in the Dockerfile.
- Read-only rootfs: the binary only reads `/app` and writes nothing at runtime. `/tmp` is the only scratch space the protocol needs.
- Upstream runs as UID 1001. The chart's `runAsUser` is 568 (draft). These do not match; `apps` is the ContainerForge convention, so keep `apps`.
- No privileged mode, no extra persistence (draft: none). Draft security expectations are consistent with this layout: non-root yes, read-only yes, privileged no.

## 10. Risks, caveats and open questions

- **Required env with no default.** `PRIMARY`, `REPLICAS` and `FULL_SYNC` are all required, so the container cannot start without them. The protocol's run step (step 3) needs a "still running" process and readiness log, which needs valid env. Plan: run step 3 manually with real-looking test values (e.g. `PRIMARY=http://127.0.0.1:1|x`) and expect a failed connection, not a clean start. Decide the readiness signal before writing the test.
- **`CRON` unset means one-shot.** Without `CRON` the README implies the process runs once and exits, which fails the "still running" criterion. Decide whether to default `CRON` in `start.sh` or leave the container as a one-shot job. Do not invent a default silently.
- **Port.** UNVERIFIED. Upstream has `HEALTHCHECK` with `nebula-sync healthcheck`, and `API_ENABLED=true`, but no port. Confirm with a run, or the upstream source in `v0.11.3`, before adding `ports` and a `tcp` probe.
- **Checksum format.** UNVERIFIED: `checksums.txt` contents not fetched. Confirm the line format before writing the `sha256sum` step.
- **Pi-hole/AdGuard dependency.** The container does nothing useful without external instances. Expect the first run to fail on connection; this is by design.
- **Credentials in env.** `PRIMARY` contains a password. Support `PRIMARY_FILE` and `REPLICAS_FILE` for Docker secrets, and keep the env path documented as the less safe option. Do not echo the value in `start.sh` logs.
- **`settings.yaml` vs required env.** See section 6. Needs a decision.
- Blockers: none found. Not privileged, no GPU, arm64 available.

## 11. Build and test steps

From `apps/nebula-sync/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe with an empty `/config` volume, read-only rootfs:
   ```sh
   docker run --rm -d --name nebula-sync-probe --read-only --tmpfs /tmp \
     -e PRIMARY='http://127.0.0.1:1|test' -e REPLICAS='http://127.0.0.1:2|test' -e FULL_SYNC=true \
     -v nebula-sync-probe-config:/config nebula-sync:0.11.3
   docker logs -f nebula-sync-probe
   docker rm -f nebula-sync-probe; docker volume rm nebula-sync-probe-config
   ```
   Expected readiness signal: to be defined once the app's log lines are seen. Failure to connect to a replica is expected and does not count as "ready".
4. `forgetool containers test --image nebula-sync:0.11.3 --config ./apps/nebula-sync/container-test.yaml`
5. Clean up scratch containers and volumes.

## 12. PR checklist

- Branch `feat/add-nebula-sync`, commit `feat(nebula-sync): add new container`, PR title the same.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, all sections and checkboxes kept; only tick boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested: any step not run locally (for example arm64 build, the checksum step, the healthcheck command), and the open port question.
