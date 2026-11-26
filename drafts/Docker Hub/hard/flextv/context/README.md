# Context for flextv

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/d8ahazard/FlexTV | github-d8ahazard-flextv.md |
| https://github.com/d8ahazard/FlexTV/releases | github-d8ahazard-flextv.md |
| https://raw.githubusercontent.com/d8ahazard/FlexTV/master/readme.md | github-d8ahazard-flextv.md |
| https://api.github.com/repos/d8ahazard/FlexTV/releases/latest | github-d8ahazard-flextv.md |
| https://github.com/d8ahazard/FlexTV/wiki | github-d8ahazard-flextv-wiki.md |
| https://github.com/d8ahazard/FlexTV/wiki/Using-Docker | github-d8ahazard-flextv-wiki.md |
| https://hub.docker.com/r/jcreynolds/flextv | dockerhub-jcreynolds-flextv.md |
| https://registry.hub.docker.com/r/jcreynolds/flextv | dockerhub-jcreynolds-flextv.md (alias, not fetched separately) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flextv | truecharts-flextv.md |

Skipped: CLA link, containerforge apps/<base> links (ubuntu, python), ghcr image refs (`ghcr.io/trueforge-org/ubuntu`, `ghcr.io/trueforge-org/python`), `archive/<sha>.tar.gz` templated source tarball, and `https://app.phlexchat.com` (hosted SaaS, plan mention only).

## Fetch failures

- https://raw.githubusercontent.com/d8ahazard/FlexTV/master/README.md: 404. One alternative (`readme.md`, the real name) worked.
- https://api.github.com/repos/d8ahazard/FlexTV/releases/latest: 404, consistent with "There aren't any releases here".
- Wiki sub-pages other than Home and Using-Docker not fetched (budget; most sidebar pages showed "error while loading").

## plan.md corrections

- None made. No clear factual error proven by the fetched sources.
- Confirmed: PHP, not Python (repo root has index.php, api.php, PHPTail.php).
- Unverified conflict (not edited): draft and plan cite `jcreynolds/flextv`, but the FlexTV wiki Using-Docker page documents `digitalhigh/FlexTV` (web UI port 80, `/config`, PUID/PGID). Which image is authoritative is not resolved.
- Unverified (not edited): license name (`license.txt` and `gpl.txt` exist in the repo root, content not fetched).
- Unverified (not edited): `composer install` step (no composer.json seen in the root listing).
- Unverified (not edited): port 8080 and health path `/` (chart defines no probes; wiki gives port 80 for the other image).
