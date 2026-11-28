# shiori — implementation plan
> Source: ./draft.md · Target: apps/shiori/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.8.0 (tag `v1.8.0`, published 2025-09-26). Latest stable in repo, matches the chart image `ghcr.io/go-shiori/shiori:v1.8.0`. Source: `gh api repos/go-shiori/shiori/releases/latest` |
| Renovate | `datasource=github-releases depName=go-shiori/shiori versioning=semver` (tags are strict semver with a `v` prefix; the `v` is stripped in VERSION, as in `apps/adguardhome-sync`) |
| License | MIT (SPDX `MIT`). https://github.com/go-shiori/shiori/blob/master/LICENSE |
| Source URL | https://github.com/go-shiori/shiori |
| Download (amd64) | https://github.com/go-shiori/shiori/releases/download/v1.8.0/shiori_Linux_x86_64_1.8.0.tar.gz |
| Download (arm64) | https://github.com/go-shiori/shiori/releases/download/v1.8.0/shiori_Linux_aarch64_1.8.0.tar.gz |
| Checksum source | `checksums.txt` on the same release: https://github.com/go-shiori/shiori/releases/download/v1.8.0/checksums.txt. Linux lines: `20552c4d91c720dc9786d73a7f5b68abd9ed32addb177861f89ea5d4e5937d3f  shiori_Linux_x86_64_1.8.0.tar.gz`, `ebfb94cc5ab955f379ec3af0b7194191f3989096ad37e7cb59e9ef3c12528fba  shiori_Linux_aarch64_1.8.0.tar.gz` |
| Upstream Dockerfile reviewed | https://github.com/go-shiori/shiori/blob/v1.8.0/Dockerfile. Builder `alpine:3.19` copies a prebuilt `dist/shiori_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}/shiori`; final `FROM scratch`; `ENV PORT=8080`, `ENV SHIORI_DIR=/shiori`, `EXPOSE ${PORT}`, `ENTRYPOINT ["/usr/bin/shiori"]`, `CMD ["server"]`. No `USER`, no `VOLUME`. We take only the binary and ignore the scratch image. |
| Env vars (real) | Verified in `docs/Configuration.md` (v1.8.0) and `internal/config/config.go`: `SHIORI_DIR` (data dir, default current dir), `SHIORI_HTTP_PORT` (8080), `SHIORI_HTTP_ADDRESS` (`:`), `SHIORI_HTTP_ROOT_PATH` (`/`), `SHIORI_HTTP_SERVE_WEB_UI` (True), `SHIORI_HTTP_SECRET_KEY` (session key), `SHIORI_HTTP_ACCESS_LOG` (True), `SHIORI_DATABASE_URL` (optional; SQLite default), `SHIORI_DEVELOPMENT` (False). |
| Hostname variable | `config.go` marks `SHIORI_HOSTNAME` as `required` (line 110) but the docs do not list it. `config.go` (line 185) fills it from the process's OS `HOSTNAME` variable, which Docker sets for every container, so no extra env var is needed. Confirm on the first run (section 10). |
| Secret key behaviour | Docs say `SHIORI_HTTP_SECRET_KEY` is required. `config.go` only logs a warning and uses a random key when it is unset, which invalidates sessions on every restart. |
| Default login | UNVERIFIED: not confirmed on a fetched page. Do not document a default username or password. |
| Ports | 8080/tcp (HTTP web UI and API) |
| Data path | `SHIORI_DIR`, SQLite database and offline archives. Upstream image sets `/shiori`; ContainerForge uses `/config`. |
| arm64 | Yes: `shiori_Linux_aarch64_1.8.0.tar.gz` |
| Dependencies | None required. PostgreSQL, MySQL and MariaDB are optional via `SHIORI_DATABASE_URL`. `apps/postgresql` exists (✅) but is optional. |

## 2. Target layout

- `apps/shiori/Dockerfile`
- `apps/shiori/docker-bake.hcl`
- `apps/shiori/settings.yaml`
- `apps/shiori/start.sh` (generates and persists the secret key, then `exec`s the server)
- `apps/shiori/container-test.yaml`

No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The app is one static Go binary, so no runtime stack is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu, `/config` volume).

## 4. Dockerfile

1. `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the arch: `amd64` to `x86_64`, `arm64` to `aarch64`. Only these two are built. Use a shell `case` with `exit 1` for any other value.
3. Download the tarball and `checksums.txt` into `/tmp`. Verify with `grep " shiori_Linux_${ARCH}_${VERSION}.tar.gz$" checksums.txt | sha256sum -c -`. A failed check must fail the build.
4. `tar xzf ... -C /tmp shiori` then `install -D -m 0755 /tmp/shiori /app/shiori`. Also copy the upstream `LICENSE` to `/usr/share/licenses/shiori/` (download from the same tag, or note it in the tarball if present; UNVERIFIED whether the tarball ships a LICENSE).
5. `rm -rf /tmp/*` to clean up (`apt-get` is not needed: the binary is static and the base already has CA certificates and tzdata; UNVERIFIED that the base has both, check at build time).
6. `ENV SHIORI_DIR=/config HOME=/config SHIORI_HTTP_PORT=8080`. `/config` is the data dir, so SQLite and archives land there. Caches must not go to `/config`; Go does not need one at runtime.
7. `chown -R apps:apps /app`, `chmod -R 755 /app`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `CMD ["/start.sh"]`.

Do not set `ENTRYPOINT` to `/usr/bin/shiori`; the start script owns the command line.

## 5. docker-bake.hcl

- `APP = "shiori"`
- `VERSION` default `1.8.0`, preceded by `// renovate: datasource=github-releases depName=go-shiori/shiori versioning=semver`
- `LICENSE = "MIT"`
- `SOURCE = "https://github.com/go-shiori/shiori"`
- The standard targets: `docker-metadata-action`, `image` (args VERSION, OCI labels source and licenses), `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (amd64 and arm64), `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/shiori && docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1` as in sibling apps; `upstream_env_url: "https://github.com/go-shiori/shiori"`.
- `ports`: `8080`, `protocol: tcp`, `required: false`.
- `env`:
  - `SHIORI_HTTP_PORT`, default `"8080"`, required false
  - `SHIORI_HTTP_SECRET_KEY`, default empty, required false (generated by `start.sh` when unset, see section 7)
  - `SHIORI_HTTP_ROOT_PATH`, default `"/"`, required false
  - `SHIORI_HTTP_SERVE_WEB_UI`, default `"True"`, required false
  - `SHIORI_DATABASE_URL`, default empty, required false (optional external DB)
  - `TZ`, default `"Etc/UTC"`, required false (match sibling apps)
  - Do not add `SHIORI_HOSTNAME` until it is verified (section 10).
- `volumes`: `/config`, `required: true`.
- `dependencies`: none. Optional PostgreSQL is noted in the description, not listed as a hard dependency.

## 7. start.sh

```
#!/usr/bin/env bash
set -eu
umask 077
# secret key: use env value; otherwise persist a random one in /config so sessions survive restarts
if [ -z "${SHIORI_HTTP_SECRET_KEY:-}" ]; then
  if [ ! -s /config/.secret_key ]; then
    head -c 32 /dev/urandom | base64 > /config/.secret_key
  fi
  SHIORI_HTTP_SECRET_KEY="$(cat /config/.secret_key)"
  export SHIORI_HTTP_SECRET_KEY
fi
exec /app/shiori server
```

- Read the key with `cat`, never pass it as an argument, so it stays out of the process list.
- `umask 077` is set at the top of the script, before the key file is written.
- Empty `/config` works: the key file is created on first start.
- Do not write to `/app`.
- Bind: `SHIORI_HTTP_ADDRESS` default `:` (all interfaces). Verified in docs.
- Use `exec` for PID 1 handoff.

## 8. container-test.yaml

```
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120

tcp:
- port: '8080'
```

Add an `http` probe on `/` with port 8080 for the web UI, using the sibling `nginx` pattern. `timeoutSeconds` is an estimate (UNVERIFIED against a sibling of the same family; Go servers start in under a few seconds). Test runs with no env vars, so the secret-key generation path is exercised by the test itself.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as the default user. ContainerForge runs as `apps` (`USER apps`), port 8080 is above 1024.
- Writes: `SHIORI_DIR=/config` (SQLite, archives, secret key). Nothing writes under `/app`.
- `/tmp` is the only other writable path; Shiori does not need it beyond the default.
- Upstream data path `/shiori` is remapped to `/config`. Draft caveat: the TrueCharts chart mounts `/data`, so an existing database must be moved from the chart's `/data` into `/config` (migration note for the user, not a container change).
- Security expectations from the draft: non-root yes, read-only rootfs yes, privileged no. These match the target.

## 10. Risks, caveats and open questions

- `SHIORI_HOSTNAME` is `required` in `config.go` but undocumented; it is read from the OS `HOSTNAME` variable, which Docker always sets. Confirm on the first run that the server starts, and do not add an env var for it.
- Default login: UNVERIFIED. Check the first-run log or docs before documenting it.
- The secret key default: random key persisted in `/config/.secret_key`. Documented upstream as required, so this is a deliberate choice, flagged for review.
- arm64 is available in the release, but only amd64 is verified by a run. Test arm64 after amd64 passes.
- Checksum: verified from `checksums.txt` on the same release (same host as the download, so this proves integrity, not origin).
- Blockers: none known. No musl, GPU, privileged or arm64 gaps.

## 11. Build and test steps

From `apps/shiori/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name shiori-probe --read-only --tmpfs /tmp -v shiori-probe-config:/config shiori:1.8.0`, then `docker logs -f shiori-probe`. Expected readiness signal: a line with `listening` or `server started` on port 8080 (exact text UNVERIFIED, confirm on the run). Cleanup: `docker rm -f shiori-probe; docker volume rm shiori-probe-config`.
4. `forgetool containers test --image shiori:1.8.0 --config ./apps/shiori/container-test.yaml`. If forgetool is unavailable, probe 8080 by hand.
5. Repeat step 3 with the same volume to check restart idempotence (secret key reused).

## 12. PR checklist

- Branch: `feat/add-shiori`
- Commit: `feat(shiori): add new container`
- PR title: `feat(shiori): add new container`
- Body: PR template at `.github/PULL_REQUEST_TEMPLATE.md`, with `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Report what was not tested (arm64 build, default login, `SHIORI_HOSTNAME`).
- Do not tick "Built container locally" unless the build and run above were done.

## Fix attempt (2026-11-28)

- Wrote the full file set. Verified again: v1.8.0 is still the latest release; both Linux tarball checksums match the lines in `checksums.txt`; the x86_64 tarball contains `LICENSE`, `README.md` and `shiori`, so the licence is installed from the tarball. Base digest corrected to `f01a4295...` (as in `apps/adguardhome-sync`).
- Not verified: no build or run; `SHIORI_HOSTNAME` behaviour, default login, and whether `/` returns 200 for the http probe.
