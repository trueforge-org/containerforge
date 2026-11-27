# Context index: amule

Built 2026-11-27.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/amule/values.yaml | truecharts-amule.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/amule/Chart.yaml | truecharts-amule.md |
| https://raw.githubusercontent.com/ngosang/docker-amule/3.2.0-1/Dockerfile | github-ngosang-docker-amule-dockerfile.md |
| https://github.com/ngosang/docker-amule/blob/3.2.0-1/Dockerfile | github-ngosang-docker-amule-dockerfile.md (same file) |
| https://github.com/ngosang/docker-amule | github-ngosang-docker-amule-dockerfile.md (repo root, not fetched) |
| https://api.github.com/repos/ngosang/docker-amule/releases/latest | failed (403), see below |
| https://api.github.com/repos/amule-org/amule/releases/latest | failed (403), see below; alt in github-amule-org-amule-release.md |
| https://github.com/amule-org/amule | github-amule-org-amule-release.md (repo root, covered by release page) |
| https://github.com/amule-org/amule/releases/latest (fallback) | github-amule-org-amule-release.md |
| https://amule-org.github.io | amule-org-site.md |
| https://amule-org.github.io/docs | amule-org-site.md |

Skipped categories: none in the filtered list beyond the duplicate blob/raw pair above.

Failures:
- https://api.github.com/repos/amule-org/amule/releases/latest (HTTP 403, rate limit). Alternative HTML release page used.
- https://api.github.com/repos/ngosang/docker-amule/releases/latest (HTTP 403, rate limit). No alternative fetched (plan's 3.2.0-1 pin is confirmed by the chart and Dockerfile URL).
- https://packages.ubuntu.com/resolute/amule-daemon (TLS EOF on https; http alternative returned 302 and was not followed). Ubuntu package version not verified (plan says 2.3.3-3.2).

## plan.md corrections
None applied. Chart pin `3.2.0-1@sha256:4b1a4246...`, ports (4711, 4712, 4662, 4665/udp, 4672/udp), persistence paths and the Dockerfile facts agree with sources.

Unverified conflicts (not edited):
- plan.md line 10: amule-org SPDX `NOASSERTION` is still unverified; the amule home page states GPL-2.0 (amule-org-site.md). Left for the author to confirm against COPYING.
- plan.md lines 8, 12: release publish times and asset digests came from the API, not re-checked (403).
- plan.md line 14: Ubuntu `amule-daemon` 2.3.3 not re-checked (packages.ubuntu.com unreachable).
