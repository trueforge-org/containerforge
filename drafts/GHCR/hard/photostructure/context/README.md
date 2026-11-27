# Context: photostructure

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photostructure/values.yaml + Chart.yaml | truecharts-photostructure.md |
| https://raw.githubusercontent.com/photostructure/photostructure-for-servers/42bd6d0e2f7c2a5abaaa1948cb9591c591163467/Dockerfile | photostructure-for-servers-dockerfile.md |
| https://photostructure.com/server/photostructure-for-docker | photostructure-docker-docs.md |
| https://registry.npmjs.org/photostructure/latest | npm-photostructure.md |

Skipped: blob/contents-API duplicates of the raw Dockerfile (GitHub blob URL, api.github.com contents URL); photostructure.com root (marketing page, covered by docs).

Failures:
- https://api.github.com/repos/photostructure/photostructure-for-servers: 403 rate limit (not retried).
- https://github.com/photostructure/photostructure-for-servers: HTML returned only site chrome, no repo content.
- https://photostructure.com/docs: returned only a tags link, no content.

## plan.md corrections
None. No clear factual error proven by the fetched sources.
Unverified in plan (not checked by these fetches): npm `engines`, Docker Hub tag for 2026.10.3, `PS_LOG_DIR`, `PS_LOG_STDOUT`, `PS_NO_PUID_CHOWN`.
