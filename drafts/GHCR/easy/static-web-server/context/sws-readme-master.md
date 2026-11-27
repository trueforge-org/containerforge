# static-web-server README (master, v3 dev)

## Source URL(s) + date
- https://raw.githubusercontent.com/static-web-server/static-web-server/master/README.md
- Fetched 2026-11-27

## Caveat
- README describes upcoming v3 (in development). For production, v2 LTS on the `2.x` branch is recommended. Facts below may not match v2.44.3.

## Facts
- Config from CLI args, env vars, or TOML file (no default filename or path given).
- License: MIT and Apache-2.0 dual license (files `LICENSE-MIT`, `LICENSE-APACHE`). Copyright 2019-present Jose Quintana.
- Health endpoints `/livez` and `/readyz` (GET and HEAD) for k8s-style probes.
- Flags: `--log-format` (JSON), `--log-file`.
- Docker Hub `joseluisq/static-web-server` with Scratch, Alpine, Debian tags.

## Gaps
- No default port, root dir, env prefix/names, or Docker run example on this page.
