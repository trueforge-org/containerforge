# Context: rsshub

| Source URL | File |
| --- | --- |
| https://docs.rsshub.app | (failed, see failures) |
| https://docs.rsshub.app/en/install | (failed, see failures) |
| https://github.com/DIYgod/RSSHub | diygod-rsshub-readme.md |
| https://github.com/browserless/chrome | browserless-chrome-readme.md |
| https://github.com/browserless/chrome/blob/2ebe1345023358d9006a3058b17dbfcc87347843/docker/chrome/Dockerfile | browserless-chrome-dockerfile.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rsshub | truecharts-rsshub-values.md |
| https://hub.docker.com/r/browserless/chrome | dockerhub-browserless-chrome.md |
| https://hub.docker.com/r/diygod/rsshub | dockerhub-diygod-rsshub.md |
| https://raw.githubusercontent.com/DIYgod/RSSHub/master/Dockerfile | diygod-rsshub-dockerfile.md |

Skipped categories: none beyond pre-filtering (urls.txt already filtered).
Failures:
- https://docs.rsshub.app: HTTP 403 (site notice: rsshub.app restricted; points to docs.rsshub.app/deploy/).
- https://docs.rsshub.app/en/install: HTTP 403. One alternative tried: https://docs.rsshub.app/deploy/, also 403. Env/config docs therefore not summarised. Env list in plan.md (from docs.rsshub.app/deploy/config) is unverified.

## plan.md corrections
- None made. Checked plan.md against fetched facts: EXPOSE 1200, no USER in upstream, `dumb-init` entrypoint, `npm run start`, TZ/NODE_ENV/PLAYWRIGHT env, node:26-trixie base, and the browserless/chrome 1.61.1 chart pin. No clear factual error found.
- Unverified in fetched sources (left as is): AGPL-3.0 licence (README fetch did not show it), and the docs.rsshub.app env list (site 403).
- Note for plan line 9: the browserless/chrome GitHub master README now says SSPL-1.0 OR commercial licence, and Docker Hub says free for non-commercial use. Not in plan; flagged here only.
