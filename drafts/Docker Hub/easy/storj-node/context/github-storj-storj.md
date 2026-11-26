# storj/storj (upstream node binaries, release v1.166.4 / latest v1.167.1)

Source URL(s) + fetch date (all 2026-11-26):
- https://raw.githubusercontent.com/storj/storj/v1.166.4/LICENSE
- https://raw.githubusercontent.com/storj/storj/v1.166.4/cmd/storagenode/cmd_setup.go
- https://github.com/storj/storj/releases

## What it is
Storj network code. Produces `storagenode` (the storage node) and `identity` (identity generator) binaries, plus `multinode`. Node source is AGPL v3 (LICENSE at v1.166.4: "GNU AFFERO GENERAL PUBLIC LICENSE, Version 3, 19 November 2007").

## Install/build steps
- Node is distributed as release zips (not built in the image). Asset names (plan.md; visible on the releases page for some arches): `storagenode_linux_<arch>.zip`, `identity_linux_<arch>.zip`, with `arch` in amd64, arm, arm64 (page lists identity_linux_amd64, identity_linux_arm, identity_linux_arm64, identity_freebsd_amd64, identity_macos_*, identity_windows_amd64, multinode_* ...).
- Each zip contains one binary (plan.md: `storagenode` about 101 MB, `identity` about 69 MB; not checked here).
- Upstream Docker image does not compile; it downloads binaries from the version server at container start (see github-storagenode-docker.md).

## Setup flow (cmd/storagenode/cmd_setup.go at v1.166.4)
- `cmdSetup`: checks setup directory validity via `fpath.IsValidSetupDir(cfg.SetupDir)`; aborts with "storagenode configuration already exists (%v)" when not valid (validity function body not shown; the summary cannot confirm that it tests `config.yaml`).
- Loads identity (`cfg.Identity.Load()`), creates the setup dir with mode 0700.
- Overrides: `log.level: info`; `server.address` defaults to `:28967` unless the flag was set; `server.private-address` defaults to `127.0.0.1:7778` unless set.
- Writes `config.yaml` in the setup dir via `process.SaveConfig`.
- Unless `EditConf`, creates a new storage node DB (`storagenodedb.OpenNew`) and a pieces verification file for the identity ID, then closes the DB.
- No console address default in this file (console default comes from the entrypoint: `STORJ_CONSOLE_ADDRESS` default `0.0.0.0:14002`).

## Runtime deps
None beyond the binaries (static Go binaries per plan.md; not verified here).

## Binaries/entrypoint/CLI flags
- `storagenode setup`, `storagenode run`, `storagenode-updater run|should-update`, `identity create`.
- Flags used by the upstream entrypoint: `--config-dir config`, `--identity-dir identity`, `--storage.allocated-disk-space`, `--contact.external-address`, `--operator.email`, `--operator.wallet`, `--log.level`, `--version.server-address`.

## Env vars
Upstream image env vars are in github-storagenode-docker.md (and not STORJ_* in this file).

## Ports
Node public port 28967 (tcp and udp per the TrueCharts chart; server.address default `:28967`). Private API `127.0.0.1:7778` (localhost only). Dashboard/console 14002 (entrypoint default `0.0.0.0:14002`).

## Volumes/paths and persistent data
Setup writes `config.yaml`, a node database, and a verification file under the setup dir (`--config-dir`). Identity in `--identity-dir`. Storage defaults to `<config>/storage` (per plan.md; not verified here).

## User/UID & permissions
Setup creates the config dir with mode 0700.

## Healthcheck/readiness endpoints
None in this file.

## Version/release info and asset naming
- Releases page: v1.167.1 (25 Nov) marked **Latest** (stable); v1.167.1-rc (24 Nov, pre-release); v1.167.0-rc (20 Nov, pre-release); v1.166.4 (15 Nov, stable, not Latest); v1.166.3 (10 Nov); v1.166.2 (8 Nov); v1.166.1 (5 Nov); v1.166.0 (3 Nov); v1.166.0-rc (2 Nov, pre-release); v1.165.6 (27 Oct).
- v1.166.4 notes: server fix so a failed connection setup does not halt serving; MPTCP disabled; compensation and usage-report work.
- v1.167.1 notes: drpc v1.1.0, MPTCP off on listeners, white-label console config, piecestore download read queueing.
- Release page reports 36 assets per release; only 10 file entries are visible (identity and multinode zips plus source archives). storagenode zips and any checksum file are in the hidden part, so not listed here.

## Arch support
Visible identity zips include amd64, arm and arm64 for linux.

## Gotchas
- Latest stable is now v1.167.1, not v1.166.4 (see plan.md correction).
- Node requires an authorized identity, which takes long to generate (per Storj docs landing page: "may take hours or days").

## Contradictions with plan.md
- plan.md's "v1.166.4 is the latest stable": the releases page marks v1.167.1 as Latest (25 Nov). Corrected in plan.md section 1 (Version row).
- plan.md's "setup refuses only when config.yaml exists": the refusal depends on `fpath.IsValidSetupDir`, whose body is not in the fetched content. Unverified.
