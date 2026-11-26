# mango: context sources

Fetched 2026-11-26. Summaries for every web source referenced by `draft.md` and `plan.md`.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/getmango/Mango (+ releases/tag/v0.27.0, raw README, LICENSE, src/config.cr, src/storage.cr, Dockerfile.arm64v8 at v0.27.0) | github-getmango-mango.md |
| https://github.com/hkalexling/mango (old name, redirects to getmango/Mango) | github-hkalexling-mango.md |
| https://raw.githubusercontent.com/hkalexling/mango/7a7d9eb/Dockerfile (blob link in draft/plan) | github-hkalexling-mango.md |
| https://hub.docker.com/r/hkalexling/mango | dockerhub-hkalexling-mango.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mango (Chart.yaml and values.yaml via raw) | truecharts-mango.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base link, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema, skipped by rule |
| https://github.com/getmango/Mango/releases/download/v${VERSION}/mango | templated release download |
| https://github.com/getmango/Mango/releases/download/v0.27.0/mango | direct binary download (amd64, ~35 MB static). Pattern and size recorded in github-getmango-mango.md |
| https://raw.githubusercontent.com/getmango/Mango/v${VERSION}/LICENSE | templated form of the LICENSE fetched at v0.27.0 (same file, already summarised) |
| http://<container-ip>:9000 | placeholder address, not a source |

Named but not fetched: Crystal 1.0.0 (`crystallang/crystal:1.0.0-alpine` builder image, upstream build), `arm64v8/ubuntu:18.04` (upstream arm64 base; described in github-getmango-mango.md), `mango-plugins` repo (README mention only), Gitter (README mention), `library/alpine` (upstream final base).

## Fetch failures

- https://github.com/getmango/Mango/releases/tag/v0.27.0: page loaded (date, commit, Latest label), but the asset list did not load ("Assets 5", names not shown). Plan's asset claims (`mango-arm64v8.o`, `mango-arm32v7.o`) and the amd64 binary checksum are not confirmed here. No retry (not 403/404).

## plan.md corrections

No edits made. No fact in plan.md was clearly wrong against the fetched sources.

Confirmed: `v0.27.0` latest and archived 2025-03-23 (23 Mar 2025 per repo page); old `hkalexling/mango` redirects to `getmango/Mango`; MIT license, "Copyright (c) 2020 Alex Ling"; port 9000/tcp, `host` default `0.0.0.0`; `mango -c <file>`; every option readable as an uppercase env var with precedence config file > env > default; `session_secret` default `mango-session-secret`; `db_path` default `~/mango.db` (not under `~/mango/`); missing config is written with defaults; first start creates `admin` with a random password and logs it in plaintext; upstream Dockerfile at 7a7d9eb (crystal 1.0.0 alpine, `make static`, `FROM alpine`, COPY to `/usr/local/bin/mango`, CMD); `Dockerfile.arm64v8` on `arm64v8/ubuntu:18.04` linking `mango-arm64v8.o` after building crystal 1.0.0, myhtml v1.5.8, duktape.cr v1.0.0 and image_size.cr v0.5.0; chart and compose mount `/root/mango` and `/root/.config/mango`; Docker Hub `latest` digest `14b5e1dd` matches the chart.

Unverified (not edited):
- plan.md section 1 (Version row): "The Docker Hub tags `latest` and `v0.27.0` are the same version." Hub page lists only `latest`. `v0.27.0` tag not visible.
- plan.md section 1 (arm64 row): "The release only has `mango-arm64v8.o` and `mango-arm32v7.o`" and "The Docker Hub image `hkalexling/mango:v0.27.0` is amd64 only." Release asset list did not load; Hub does not list architectures. The `Dockerfile.arm64v8` build is confirmed, the release asset list is not.
- plan.md section 1 (amd64 download row): "~35 MB static-pie ELF, with debug info, not stripped (checked with `file`)." Not fetched; the README says the binary is statically linked for amd64.
- plan.md section 1 (Checksum row): sha256 `e2a90d91...` of the amd64 binary. Not checkable from fetched sources.
- plan.md section 1 (Version row): tag date 2022-07-31. Release page shows "31 Jul" with no year.
- plan.md section 1 (Config row): "From `src/config.cr` (master and the v0.27.0 notes)." Confirmed for v0.27.0 only.
- plan.md section 7: writing the default config file includes the generated `session_secret` and the env-derived paths. `src/config.cr` shows `default.to_yaml` written on a missing file, but whether env values feed that default instance was not confirmed.
- plan.md section 10: "`LIBRARY_PATH` is also the name of a GCC build-time variable." Not in any fetched source.
