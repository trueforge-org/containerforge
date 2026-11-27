# Context sources: GHCR/medium/bytestash

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bytestash/values.yaml + Chart.yaml | truecharts-bytestash.md |
| https://raw.githubusercontent.com/jordan-dalby/ByteStash/eb4ecdfc30f2e7d1424137fa7fe3a9eed663218b/Dockerfile (blob URL in urls.txt) | github-bytestash-dockerfile.md |
| https://github.com/jordan-dalby/ByteStash (repo root, README raw) + https://api.github.com/repos/jordan-dalby/ByteStash | github-bytestash-repo.md |

- Skipped categories: none (blob URL served by raw equivalent).
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt.
- Failures: none.
- Not fetched: server source (`server/src/config/sqlite.js`, `app.js`) referenced by plan.md; outside the urls.txt list.

## plan.md corrections
- None made. Verified against fetched sources: port 5000 (EXPOSE), `CMD ["node","src/app.js"]`, no USER, `mkdir -p ./data/snippets`, node 22.23.4 base, GPL-3.0 (repo SPDX).
- Unverified, not changed: plan.md line 71 assumes `LICENSE` value `GPL-3.0-only` (GitHub SPDX is `GPL-3.0`; LICENSE file not read). Plan already flags this as UNVERIFIED.
