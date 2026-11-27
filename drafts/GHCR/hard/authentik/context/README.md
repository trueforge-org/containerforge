# Context index: authentik

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/authentik/values.yaml + Chart.yaml | truecharts-authentik.md |
| https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684.../lifecycle/container/Dockerfile (+ github blob variant) | github-authentik-dockerfile.md |
| https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684.../authentik/lib/default.yml | github-authentik-default-yml.md |
| https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684.../LICENSE | github-authentik-license.md |
| https://api.github.com/repos/goauthentik/authentik/releases/tags/version/2026.8.6 (403) + https://github.com/goauthentik/authentik/releases/latest (redirect) | github-authentik-release.md |

Skipped categories: GitHub blob variant of the Dockerfile (same as raw), github repo root page, goauthentik.io homepage and goauthentik.io/docs (marketing/docs site; not fetched, budget spent on source files), Docker Hub (images are GHCR, no Docker Hub URL listed).
Not read (not needed for the plan's decisions yet): `lifecycle/ak` (the plan flags its subcommand map as UNVERIFIED).

Failures:
- https://api.github.com/repos/goauthentik/authentik/releases/tags/version/2026.8.6: 403 (rate limit). Alternative used: releases/latest redirect.

## plan.md corrections
- No edit made. Unverified conflicts:
  - Plan builds `2026.8.6`. The latest published release is `2026.8.7` (releases/latest redirect), and the TrueCharts chart uses `2026.8.7`. The plan's version is still a valid published tag, so this is a version choice for the maintainer, not an error.
  - Plan `variable "LICENSE" default = "UNVERIFIED-MIT-OR-SEE-LICENSE"`: the fetched core LICENSE is MIT (outside `website/` CC BY-SA 4.0 and `authentik/enterprise/`). Plan left unchanged; maintainer may set `MIT` with the notes above.
