# context: dispatch

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/khlieng/dispatch (README via raw master) | github-khlieng-dispatch.md | 2026-11-26 |
| https://github.com/khlieng/dispatch/releases/latest (plan's `${VERSION}` release page) | github-khlieng-dispatch.md | 2026-11-26 |
| https://github.com/khlieng/dispatch/blob/d3d8323/Dockerfile | github-khlieng-dispatch-dockerfile.md | 2026-11-26 |
| https://raw.githubusercontent.com/khlieng/dispatch/${VERSION}/LICENSE (fetched as v0.7) | github-khlieng-dispatch-license.md | 2026-11-26 |
| https://raw.githubusercontent.com/khlieng/dispatch/v0.7/config.default.toml (followed from plan.md) | github-khlieng-dispatch-config-default-toml.md | 2026-11-26 |
| https://hub.docker.com/r/khlieng/dispatch | dockerhub-khlieng-dispatch.md | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dispatch (read via raw values.yaml) | truecharts-dispatch.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link.
- https://github.com/khlieng/dispatch/releases/download/${VERSION}/dispatch_${VERSION#v}_linux_${A}.tar.gz, .../releases/download/v0.7/dispatch_0.7_linux_x64.tar.gz, .../dispatch_0.7_linux_arm64.tar.gz, and .../releases/download/${VERSION}/checksums.txt: direct archive/checksum downloads. Naming in plan.md; not confirmed by fetch.
- http://127.0.0.1:8080/: localhost.

## Fetch failures
- https://dispatch.khlieng.com (hosted demo, plan/draft site): DNS failure (ENOTFOUND). Not retried.
- releases/latest: asset list did not load; no checksums or digests visible.

## plan.md corrections
- None made. Confirmed from context: v0.7 release, `golang:alpine`/`alpine` Dockerfile with EXPOSE 80, VOLUME /data, ENTRYPOINT, CMD `--dir=/data`; config.default.toml values (address, port 80, https enabled 443, auth anonymous/login/registration true); MIT license.
- Unverified (left as-is): plan.md's checksum values (no checksums text visible on the release page); plan.md's "no identd or DCC feature" at v0.7 (README on master lists DCC downloads as a feature, and plan.md section 12 lists DCC as untested; these are not consistent with each other); the flag names in plan section 1 (`commands/dispatch.go`); the `--dir`-based config watch/reload.
- Note for maintainers (not a plan edit): chart uses `khlieng/dispatch:latest` with HTTPS 443 and `/data`.
