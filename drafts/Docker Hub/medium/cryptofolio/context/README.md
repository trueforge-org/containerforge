# context README: cryptofolio

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/Xtrendence/cryptofolio/master/Dockerfile | upstream-github.md |
| https://raw.githubusercontent.com/Xtrendence/cryptofolio/master/apache/000-default.conf | upstream-github.md |
| https://raw.githubusercontent.com/Xtrendence/cryptofolio/master/apache/start-apache | upstream-github.md |
| https://api.github.com/repos/Xtrendence/cryptofolio/releases/latest | upstream-github.md |
| https://github.com/Xtrendence/Cryptofolio | upstream-github.md (repo root, covered by raw files) |
| https://github.com/Xtrendence/Cryptofolio/releases/expanded_assets/V.2.2 | upstream-github.md (asset names via API) |
| https://github.com/Xtrendence/cryptofolio/blob/51f7263e77cad118bd8f2244d0ded81e5d647261/Dockerfile | upstream-github.md (same as raw master, plan pins commit 51f7263) |

Skipped: TrueCharts tree page (chart reference, not build source); Docker Hub page https://hub.docker.com/r/xtrendence/cryptofolio (JS-rendered, not fetched); GitHub HTML page https://github.com/Xtrendence/Cryptofolio (HTML only, covered by API).
Failures: none.

## plan.md corrections
None. Checked against fetched sources: PHP 7.4-apache base, EXPOSE 80, CMD start-apache, no USER/VOLUME/ENV, release V.2.2 with API-And-Website.zip: consistent.
Not a conflict, for the build: upstream `start-apache` honours a `PORT` env var (rewrites Apache Listen/vhost port). plan.md says the upstream has no env vars; that is true for the Dockerfile ENV only. No edit made.
