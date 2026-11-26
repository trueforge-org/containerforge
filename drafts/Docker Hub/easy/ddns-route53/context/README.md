# context: ddns-route53

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/crazy-max/ddns-route53 (README via raw master) | github-crazy-max-ddns-route53.md | 2026-11-26 |
| https://github.com/crazy-max/ddns-route53/releases/latest | github-crazy-max-ddns-route53.md | 2026-11-26 |
| https://github.com/crazy-max/ddns-route53/blob/master/Dockerfile | github-crazy-max-ddns-route53-dockerfile.md | 2026-11-26 |
| https://github.com/crazy-max/ddns-route53/blob/d8e3a348afe6152e8919e9f2360ad4fec2a2b323/Dockerfile | github-crazy-max-ddns-route53-dockerfile.md (same file family; not separately fetched) | 2026-11-26 |
| https://crazymax.dev/ddns-route53/ | docs-crazymax-dev-ddns-route53-overview.md | 2026-11-26 |
| https://crazymax.dev/ddns-route53/config/ | docs-crazymax-dev-ddns-route53-config.md | 2026-11-26 |
| https://crazymax.dev/ddns-route53/usage/cli/ | docs-crazymax-dev-ddns-route53-cli.md | 2026-11-26 |
| https://hub.docker.com/r/crazymax/ddns-route53 | dockerhub-crazymax-ddns-route53.md | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ddns-route53 (read via raw values.yaml) | truecharts-ddns-route53.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link.
- https://github.com/crazy-max/ddns-route53/releases/download/v2.16.1/ddns-route53_2.16.1_linux_amd64.tar.gz, ..._linux_arm64.tar.gz, and the `${VERSION}` template: direct archive downloads. Naming recorded in github-crazy-max-ddns-route53.md.
- https://github.com/crazy-max/ddns-route53/releases/download/v${VERSION}/checksums.txt: direct download (checksums file). Format recorded.
- https://github.com/crazy-max/ddns-route53/archive or releases/download with `${VERSION}`: template.

## Fetch failures
- releases/latest page: asset list did not load; checksum values not shown. Naming taken from upstream Dockerfile.

## plan.md corrections
- None made. Confirmed: version 2.16.1 is latest, MIT license, CLI flags and defaults, config search paths, no ports, the chart's `latest` tag, upstream `alpine` base and uid 1000, `ENTRYPOINT`/`CMD`.
- Unverified (left as-is): plan.md section 1 says env values override file values (confirmed in `internal/config/config.go`). The docs only say sources are "evaluated in the order listed". The source file was not fetched.
- Unverified: plan.md's sha256 values for amd64/arm64 tarballs (no checksum text fetched).
