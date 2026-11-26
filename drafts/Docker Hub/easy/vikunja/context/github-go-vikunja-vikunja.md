# go-vikunja/vikunja

Source URL(s) + fetch date: https://github.com/go-vikunja/vikunja · https://raw.githubusercontent.com/go-vikunja/vikunja/main/README.md · https://raw.githubusercontent.com/go-vikunja/vikunja/v2.8.0/Dockerfile · https://github.com/go-vikunja/vikunja/releases · fetched 2026-11-26

## What it is
- Open-source task manager ("The task manager you actually own"). Go API with the Vue frontend built in. Current release v2.8.0.
- Docs: https://vikunja.io/docs/ (see docs-vikunja-io.md).

## Install/build steps and build deps
- Upstream v2.8.0 Dockerfile is multi-stage:
  1. `frontendbuilder`: `node:24.21.0-alpine`, pnpm install with frozen lockfile, `pnpm run build`, writes `src/version.json`.
  2. `apibuilder`: `ghcr.io/techknowlogick/xgo:go-1.27.x`, `go install github.com/magefile/mage@latest`, `mage build:clean`, `mage release:xgo vikunja <os>/<arch>/<variant>`.
  3. Final: `FROM scratch`, copies the binary and CA certs.
- So the binary is cgo-built by xgo (matches plan.md section 10 about cgo/SQLite).
- Build-from-source docs: https://vikunja.io/docs/build-from-sources/ and https://vikunja.io/docs/magefile/.

## Runtime deps
- None in the final image (scratch). The binary embeds the frontend.

## Binaries/entrypoint/CLI flags
- Binary: `/app/vikunja/vikunja`. ENTRYPOINT `["/app/vikunja/vikunja"]`.
- `--config` flag pins a config file and skips the search (docs).

## Env vars (upstream Dockerfile)
| Name | Value in image | Notes |
| --- | --- | --- |
| `VIKUNJA_SERVICE_ROOTPATH` | `/app/vikunja/` | |
| `VIKUNJA_DATABASE_PATH` | `/db/vikunja.db` | |
| `GODEBUG` | `multipathtcp=0` | Mitigates a kernel MPTCP issue, per upstream comment; remove once kernels are patched |

## Ports
- `EXPOSE 3456`.

## Volumes/paths and persistent data
- `WORKDIR /app/vikunja`. Upstream compose example mounts `./files:/app/vikunja/files`.
- DB default path in image: `/db/vikunja.db`.

## User/UID & permissions
- `USER 1000` in the final image. `/tmp` is copied with `chmod 1777`, owner 1000:1000. Docs: the files directory must be writable by UID 1000; `/tmp` must be writable for data exports.
- Docs: `PUID`/`PGID` have no effect; use Docker's `user:` to change the user.

## Config files and formats
- Config file `config.yaml` (YAML) or the `--config` path. Search order (docs): rootpath (defaults to cwd), `/etc/vikunja`, `~/.config/vikunja`, cwd.
- Env var naming: `VIKUNJA_` + config path with dots turned into underscores, uppercase (e.g. `service.secret` -> `VIKUNJA_SERVICE_SECRET`). Env vars win over file values.
- Defaults (docs config-options): `service.interface` `:3456`; `service.publicurl` empty; `service.secret` random per start if unset (invalidates tokens); `service.enableregistration` true; `service.timezone` GMT; `database.type` sqlite; `database.path` `./vikunja.db`; `files.basepath` `./files`; `log.enabled` true; `log.path` `<rootpath>logs`; `keyvalue.type` memory; `redis.host` `localhost:6379`.

## Healthcheck/readiness endpoints
- `/health` (used by TrueCharts chart probes and plan.md). Not in the fetched README; confirmed only via the chart and plan.md.

## Version/release info and asset naming
- Latest release: v2.8.0 (marked Latest; dated 5 Nov on the release page).
- Release assets: `veans-v2.8.0-<arch>.<ext>` (CLI, aarch64/armv7 .apk/.archlinux/.deb/.rpm), `veans-v2.8.0-darwin-10.15-<amd64|arm64>-full.zip`, source zip and tar.gz, release attestation JSON. The `vikunja-v2.8.0-linux-<arch>-full.zip` assets are not shown in the visible list (only 13 of 69 assets displayed); draft/plan say they exist (HTTP 200 per plan.md).
- No `.sha256` or `.sig` assets visible on the releases page.

## Arch support
- Release builds for linux amd64 and arm64 per draft/plan; darwin and arm variants in the release list.

## Gotchas
- The draft's `veans-*` links are the CLI tool, not the server (matches plan.md).
- The container image is `scratch`: no shell.
- Upstream builds with `mage` and xgo; the plan's use of `vikunja-...-linux-<arch>-full.zip` is not contradicted here.
