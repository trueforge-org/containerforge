# context README: explainshell

| Source URL | File |
| --- | --- |
| https://github.com/idank/explainshell | upstream-github.md (repo root) |
| https://github.com/idank/explainshell/blob/827ebe3/prod/docker/Dockerfile | upstream-github.md (same as raw) |
| https://raw.githubusercontent.com/idank/explainshell/827ebe3/prod/docker/Dockerfile | upstream-github.md |
| https://github.com/idank/explainshell/releases | upstream-github.md (releases API 404; db-latest mentioned) |
| https://hub.docker.com/r/spaceinvaderone/explainshell | upstream-github.md (tags API used, HTML not fetched) |
| https://hub.docker.com/v2/repositories/spaceinvaderone/explainshell/tags/latest | upstream-github.md |

Also followed: prod/docker/start.sh (in upstream-github.md). Upstream README (master) for context only.
Skipped: TrueCharts tree page (chart reference, not build source).
Failures: releases API 404 (expected, no release object; not retried).

## plan.md corrections
None edited. Checked against fetched sources:
- Upstream Dockerfile stages, DEBUG=false and DB_PATH ENV, EXPOSE 8080, CMD ./start.sh, requirements.txt split: consistent with plan section 1.
- Plan's gunicorn command (`-w 2 --threads 4 ...`) matches upstream start.sh, but upstream binds [::1]:8081 behind Caddy; plan binds 0.0.0.0:8080 directly. That is a design difference, not a plan error. No edit.
- Plan's DB asset name/digest: not re-checked (release asset page not fetched).
