# GitHub: shenxn/protonmail-bridge-docker build/Dockerfile (build variant)

Source URL(s):
- https://raw.githubusercontent.com/shenxn/protonmail-bridge-docker/master/build/Dockerfile
Fetched: 2026-11-27

## Build stage
| Item | Value |
| --- | --- |
| base | debian:sid-slim AS build (golang not used: no riscv64 support) |
| ARG | `version` (git tag ref) |
| deps | golang, build-essential, libsecret-1-dev |
| source | `ADD https://github.com/ProtonMail/proton-bridge.git#${version} /build/` |
| build | `make build-nogui vault-editor` in /build |

## Runtime stage
| Item | Value |
| --- | --- |
| base | debian:sid-slim |
| maintainer label | Simon Felding (upstream Dockerfile author) |
| EXPOSE | 25/tcp, 143/tcp |
| packages | socat, pass, libsecret-1-0, ca-certificates (no recommends) |
| copied | `gpgparams`, `entrypoint.sh` to /protonmail/; `bridge`, `proton-bridge`, `vault-editor` from build to /protonmail/ |
| ENTRYPOINT | `["bash", "/protonmail/entrypoint.sh"]` |

## Gotchas
- Build depends on `version` build arg matching a proton-bridge tag (e.g. `v3.x.y`).
- Needs `gpgparams` and `entrypoint.sh` next to the Dockerfile in build/.
- Runtime needs `pass` and `libsecret` for the bridge vault.
- No USER directive (runs as root).
