# recyclarr — implementation plan
> Source: ./draft.md · Target: apps/recyclarr/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Version | 8.8.1 (chart and draft agree) | chart values: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/recyclarr/values.yaml |
| Release date | not fetched (REST API rate-limited); UNVERIFIED | — |
| Renovate | `datasource=github-releases depName=recyclarr/recyclarr versioning=semver` | repo tags `v8.8.1` |
| License | MIT | `gh api repos/recyclarr/recyclarr/license` |
| amd64 asset (glibc) | https://github.com/recyclarr/recyclarr/releases/download/v8.8.1/recyclarr-linux-x64.tar.xz (34809900 B) | release asset list |
| arm64 asset (glibc) | https://github.com/recyclarr/recyclarr/releases/download/v8.8.1/recyclarr-linux-arm64.tar.xz (32783080 B) | release asset list |
| Draft amd64 asset | `recyclarr-linux-musl-x64.tar.xz`: framework-dependent (ships managed DLLs), needs a .NET runtime. Not used. | tarball listing (fetched) |
| Checksums | no checksum asset in the release listing; UNVERIFIED: checksum source | release asset list |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/recyclarr/recyclarr/v8.8.1/Dockerfile | SDK `dotnet/sdk:10.0-alpine`, runtime `dotnet/runtime:10.0-alpine`, `USER 1000:1000`, `VOLUME /config`, ENTRYPOINT tini + `/entrypoint.sh` |
| Entrypoint reviewed | https://raw.githubusercontent.com/recyclarr/recyclarr/v8.8.1/docker/scripts/entrypoint.sh | no args: writes `$CRON_SCHEDULE /cron.sh` to `/tmp/crontab`, runs `supercronic`; args: runs `recyclarr "$@"`; `RECYCLARR_CREATE_CONFIG=true` runs `recyclarr config create` |
| Cron job | https://raw.githubusercontent.com/recyclarr/recyclarr/v8.8.1/docker/scripts/cron.sh | runs `recyclarr sync --log` (uses `RECYCLARR_LOG_LEVEL`) |
| Env vars | `RECYCLARR_CONFIG_DIR=/config`, `RECYCLARR_CREATE_CONFIG=false`, `CRON_SCHEDULE=@daily`, `RECYCLARR_LOG_LEVEL` | Dockerfile + entrypoint + cron.sh |
| Ports | none (no listening service; chart disables the service) | chart values |
| Data paths | `/config` (recyclarr.yml and state). Upstream also creates `/data`; not used by the entrypoint. | Dockerfile |
| Docs | https://recyclarr.dev/ | fetched (top page only) |
| glibc tarball contents | single `recyclarr` executable plus `Recyclarr.*.xml` docs; self-contained publish is likely but UNVERIFIED | tarball listing (fetched) |

## 2. Target layout

- `apps/recyclarr/Dockerfile`
- `apps/recyclarr/docker-bake.hcl`
- `apps/recyclarr/settings.yaml`
- `apps/recyclarr/container-test.yaml`
- `apps/recyclarr/start.sh` (the cron loop and the CLI passthrough)

No `defaults/` (recyclarr.yml is created by the user, not seeded). No `DOWNSTREAM_CHANGES.md` (not a base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why: upstream is musl/alpine, but the glibc linux-x64 tarball needs only glibc, so ubuntu is the right base. The brief's rule for generic userland applies.
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary, `/config` persistence).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Map `amd64` to `x64` and `arm64` to `arm64`. Stop on any other arch.
2. `USER root`. Install `curl`/`xz-utils` only if the base does not already have them (check first).
3. Download `recyclarr-linux-${ARCH}.tar.xz` to `/tmp`. Verify against a checksum: none is published upstream, so record `UNVERIFIED: no upstream checksum` in the PR and rely on the pinned version plus HTTPS.
4. Extract into `/app/recyclarr/` (matches upstream layout). `chown -R apps:apps /app && chmod -R 755 /app`. Ensure the `recyclarr` executable is `0755`.
5. Install a cron runner. Upstream uses supercronic (alpine package). No apt package is confirmed for ubuntu: UNVERIFIED. Options: (a) download the supercronic static binary from its upstream release (URL and checksum to confirm), or (b) run a bash loop that calls `recyclarr sync` on a fixed interval derived from `CRON_SCHEDULE`. Choose (a) if the release is confirmed; otherwise (b), and state the difference in the PR.
6. Remove temp files in the same `RUN`.
7. `ENV RECYCLARR_CONFIG_DIR=/config CRON_SCHEDULE=@daily RECYCLARR_CREATE_CONFIG=false PATH="${PATH}:/app/recyclarr"` plus `COMPlus_EnableDiagnostics=0` (copied from upstream, to avoid diagnostics-port writes).
8. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `CMD ["/start.sh"]`. No `EXPOSE`.

Version alignment: `ARG VERSION` must be `8.8.1` to match bake.

## 5. docker-bake.hcl

- `APP` = `recyclarr`
- `VERSION`: `// renovate: datasource=github-releases depName=recyclarr/recyclarr versioning=semver` then `default = "8.8.1"`
- `LICENSE` = `MIT`, `SOURCE` = `https://github.com/recyclarr/recyclarr`
- Four standard targets plus the default group, as in `apps/adguardhome-sync/docker-bake.hcl`.
- Validate: `cd apps/recyclarr && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/recyclarr/recyclarr"
ports: []
env:
  - name: RECYCLARR_CONFIG_DIR
    default: "/config"
    required: false
  - name: CRON_SCHEDULE
    default: "@daily"
    required: false
  - name: RECYCLARR_CREATE_CONFIG
    default: "false"
    required: false
  - name: RECYCLARR_LOG_LEVEL
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `ports: []`: nothing listens. Do not list a port.
- `RECYCLARR_LOG_LEVEL` is read only by `cron.sh`; keep it only if start.sh passes it on.

## 7. start.sh

- Idempotent: if `RECYCLARR_CREATE_CONFIG=true` and `/config/recyclarr.yml` is missing, run `recyclarr config create`. Never overwrite an existing file.
- With arguments: `exec recyclarr "$@"` (CLI passthrough, as upstream).
- Without arguments: run the cron runner from section 4 step 5 in the foreground, `exec`-ing it so signals reach it, and run `recyclarr sync` on each tick.
- Caches and scratch go to `/tmp` only. Never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
```

- No `tcp` or `http` probes: there are no ports (section 6).
- Add a `filePaths` assertion that `/app/recyclarr/recyclarr` exists and is executable (the forgetool file-check form; check the schema for the exact key names).
- Process check (if forgetool supports it) that the cron runner is alive after startup.
- Test runs with no env vars: the default `CRON_SCHEDULE` applies, so the start path is covered. The `RECYCLARR_CREATE_CONFIG=true` branch is not covered; say so in the PR.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as `1000:1000`. Our base uses `apps`. Confirm `apps` UID matches the chart expectation (common default 568 per the draft); do not hard-code 1000.
- `readOnlyRootFilesystem` is compatible: all writes go to `/config` (persistent) or `/tmp` (scratch). Upstream `/tmp/crontab` maps to `/tmp`.
- `/data` is not needed (upstream creates it, but the entrypoint does not use it). Do not create it.
- Draft expectations: non-root yes, read-only rootfs yes, privileged no, extra persistence none. These match the plan.

## 10. Risks, caveats and open questions

- Checksum: no upstream checksum asset is published for v8.8.1. Ship with `UNVERIFIED` noted in the PR.
- glibc build: the draft linked the musl build. It is framework-dependent and would need a .NET runtime. The plan uses the glibc build instead; confirm it runs on the ubuntu base (`recyclarr --version`).
- Cron: `CRON_SCHEDULE` accepts cron expressions and `@daily`. A bash loop (option b) cannot parse full cron expressions. If only `@daily` style is supported, document the limit.
- Sync targets (Sonarr/Radarr with API keys) and `recyclarr.yml` are manual setup in `/config`. This is expected, not a defect.
- Blockers: none confirmed. arm64 is built upstream; not validated here.

## 11. Build and test steps

1. `cd apps/recyclarr && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name recyclarr-probe --read-only --tmpfs /tmp -v recyclarr-probe-config:/config recyclarr:<version>`
4. `docker logs -f recyclarr-probe`: expect a cron/startup line (exact text to confirm on first run; UNVERIFIED) and no fatal error.
5. `forgetool containers test --image recyclarr:<version> --config ./apps/recyclarr/container-test.yaml`
6. Cleanup: `docker rm -f recyclarr-probe; docker volume rm recyclarr-probe-config`

## 12. PR checklist

- Branch: `feat/add-recyclarr`
- Commit / PR title: `feat(recyclarr): add new container`
- Notes section: `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- PR template: fill in `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies.
- State in the PR: no upstream checksum, musl build not used, cron runner choice, arm64 untested, and the RECYCLARR_CREATE_CONFIG branch untested.
