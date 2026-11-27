# Context: gamevault-backend

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gamevault-backend/values.yaml | truecharts-gamevault-backend.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gamevault-backend/Chart.yaml | truecharts-gamevault-backend.md |
| https://raw.githubusercontent.com/Phalcode/gamevault-backend/17.2.0/Dockerfile (also blob URL) | github-phalcode-gamevault-backend-17.2.0.md |
| https://raw.githubusercontent.com/Phalcode/gamevault-backend/17.2.0/entrypoint.sh | github-phalcode-gamevault-backend-17.2.0.md (followed from Dockerfile COPY) |
| https://raw.githubusercontent.com/Phalcode/gamevault-backend/17.2.0/README.md (repo main page) | github-phalcode-gamevault-backend-17.2.0.md |
| https://github.com/Phalcode/gamevault-backend/releases/tag/17.2.0 | github-phalcode-gamevault-backend-17.2.0.md (HTML title only) |
| https://github.com/Phalcode/gamevault-backend | covered by raw README at tag 17.2.0 |

Skipped categories: source tarball `archive/refs/tags/17.2.0.tar.gz` (source archive, not fetched); no Docker Hub entry (image is GHCR only); gamevau.lt marketing/support links (not build inputs).

Failures:
- https://api.github.com/repos/Phalcode/gamevault-backend/releases/latest: 403. One alternative (HTML release page `17.2.0`): 200, title only. Asset list not confirmed from this fetch (plan records no binary assets from an earlier API read).

## plan.md corrections
- None applied. Plan values match the fetched sources (Dockerfile stages, `SERVER_PORT=8080`, `SERVER_HTTPS_PORT=8443`, PUID/PGID 1000, entrypoint, HEALTHCHECK path `/api/status`, no USER, no VOLUME).
- Noted, not an edit: plan license row (CC-BY-NC-SA-4.0 from LICENSE) matches the README license section (CC BY-NC-SA 4.0).
- Noted: chart probes use `/api/v1/health` while the Dockerfile healthcheck uses `/api/status` (gotcha in truecharts file, not a plan error).
