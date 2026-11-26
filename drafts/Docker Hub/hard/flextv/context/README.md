# Context for flextv

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/d8ahazard/FlexTV | github-d8ahazard-flextv.md |
| https://raw.githubusercontent.com/d8ahazard/FlexTV/master/readme.md | github-d8ahazard-flextv.md (README; `README.md` returned 404, `readme.md` is the real name) |
| https://api.github.com/repos/d8ahazard/FlexTV/releases/latest | github-d8ahazard-flextv.md (404, no latest release) |
| https://github.com/d8ahazard/FlexTV/releases | github-d8ahazard-flextv.md (no releases) |
| https://github.com/d8ahazard/FlexTV/wiki | github-d8ahazard-flextv-wiki.md |
| https://github.com/d8ahazard/FlexTV/wiki/Using-Docker | github-d8ahazard-flextv-wiki.md (followed sub-page) |
| https://hub.docker.com/r/jcreynolds/flextv | dockerhub-jcreynolds-flextv.md |
| https://registry.hub.docker.com/r/jcreynolds/flextv | dockerhub-jcreynolds-flextv.md (alias of the same repo; not fetched separately) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flextv | truecharts-flextv.md |

## Skipped URLs

Skipped categories: CLA link; containerforge apps/<base> links (ubuntu, python); ghcr image refs; `ghcr.io/trueforge-org/python`.

| URL | Reason |
| --- | --- |
| https://app.phlexchat.com | hosted SaaS app, not a self-hosting source (plan mention only; not in URL list) |

## Fetch failures

- https://raw.githubusercontent.com/d8ahazard/FlexTV/master/README.md: 404. One alternative tried (`readme.md`), which worked.
- https://api.github.com/repos/d8ahazard/FlexTV/releases/latest: 404, consistent with "There aren't any releases here".
- Wiki sub-pages other than Home and Using-Docker were not fetched (budget; most of them returned "error while loading" in the Home listing).

## plan.md corrections

- No edits made. No clear factual error proven by the fetched sources.
- Unverified conflict (not edited): plan section 1 and draft cite `jcreynolds/flextv` as the upstream image. The FlexTV wiki Using-Docker page documents `digitalhigh/FlexTV` (port 80, /config, PUID/PGID). Which image is authoritative is not resolved from sources.
- Plan section 1 says "README states none" for license: consistent. The license name (`license.txt` / `gpl.txt` in repo root) is still UNVERIFIED.
- Plan's PHP-not-Python finding is confirmed by the repo root listing (index.php, api.php, PHPTail.php).
- Plan's `composer.phar` / `composer install` step: UNVERIFIED (no composer.json seen in root listing).
- Plan's port 8080 and root `/` health path: UNVERIFIED; chart defines no probes.
