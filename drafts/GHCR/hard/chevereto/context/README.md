# Context: chevereto

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chevereto/values.yaml | truecharts-chevereto.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chevereto/Chart.yaml | truecharts-chevereto.md | fetched |
| https://raw.githubusercontent.com/rodber/chevereto-free/1171863/httpd-php.Dockerfile | github-chevereto-free-dockerfile.md | fetched |
| https://github.com/rodber/chevereto-free/blob/1171863/httpd-php.Dockerfile | github-chevereto-free-dockerfile.md | same file as raw |
| https://raw.githubusercontent.com/rodber/chevereto-free/1171863/composer.json | github-chevereto-free-composer.md | fetched |
| https://raw.githubusercontent.com/rodber/chevereto-free/1171863/LICENSE | github-chevereto-free-license.md | fetched |
| https://v4-docs.chevereto.com | chevereto-v4-docs.md | fetched (plus install and PHP sub-pages) |
| https://chevereto.com | chevereto-com-home.md | fetched |
| https://github.com/rodber/chevereto-free | (none) | not fetched; covered by the raw repo files above |
| https://chevereto-free.github.io/setup/stable/environment.html | (none) | FAILED: 404; alt https://chevereto-free.github.io/setup/ also 404 |

Skipped categories: none in urls.txt were skipped as boilerplate/templated/binary. Docker Hub: no Docker Hub URL in this app (image is ghcr.io/rodber/chevereto-free, base is ubuntu via GHCR), so no dockerhub-*.md was written.

Failures: chevereto-free.github.io environment docs (404 on both the given URL and one alternative).

## plan.md corrections
- None. Checked plan facts (AGPL-3.0-only, PHP ~7.4, php:7.4-apache base, env var defaults, CMD, persistence paths, fsGroup 33) against fetched sources; no clear factual error found.
- Unverified: the release zip checksum (plan already marks it UNVERIFIED); the environment doc that would confirm the env var meanings was unavailable.
- Note: chart sets CHEVERETO_DB_NAME and CHEVERETO_DB_USER from swapped depconfig keys (see truecharts-chevereto.md). Both currently `chevereto`, so no plan change.
