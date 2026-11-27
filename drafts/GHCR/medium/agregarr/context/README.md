# Context sources: GHCR/medium/agregarr

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/agregarr/values.yaml + Chart.yaml | truecharts-agregarr.md |
| https://raw.githubusercontent.com/agregarr/agregarr/4a101503a89ebfbb3d8ba63445f87053b11b991a/Dockerfile (blob URL in urls.txt) | github-agregarr-dockerfile.md |
| https://api.github.com/repos/agregarr/agregarr + /releases/latest + README (raw, master) | github-agregarr-repo.md |
| https://github.com/agregarr/agregarr (repo root) | covered by github-agregarr-repo.md |
| https://github.com/agregarr/agregarr/releases/tag/v2.4.2 | replaced by api releases/latest (budget rule) |

- Skipped categories: none beyond the blob/repo-root/release-HTML variants, which were served by raw or API equivalents.
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt (GHCR image).
- Failures: `raw.githubusercontent.com/agregarr/agregarr/main/README.md` returned 404; one alternative (`master`) fetched OK.
- Not verified: `package.json` start script (plan claims `NODE_ENV=production node dist/index.js`); package.json not in urls.txt, not fetched.

## plan.md corrections
- None. Verified against fetched sources: port 7171, tag v2.4.2, GPL-3.0, no USER in upstream, no release assets.
