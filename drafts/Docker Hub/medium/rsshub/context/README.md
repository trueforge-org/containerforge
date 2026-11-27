# context: rsshub

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rsshub/values.yaml | truecharts-rsshub.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rsshub/Chart.yaml | truecharts-rsshub.md |
| https://hub.docker.com/v2/repositories/diygod/rsshub/ (+ tags?page_size=10) | dockerhub-rsshub.md |
| https://hub.docker.com/v2/repositories/browserless/chrome/ (+ tags?page_size=10) | dockerhub-browserless-chrome.md |
| https://api.github.com/repos/DIYgod/RSSHub (release list) and /releases/latest | github-rsshub-dockerfile.md |
| https://raw.githubusercontent.com/DIYgod/RSSHub/c566e920fd386c19935954e1969ac8d7d3c8b5c4/Dockerfile | github-rsshub-dockerfile.md |
| https://docs.rsshub.app/en/install | docs-rsshub-install.md |
| https://docs.rsshub.app/deploy/ (follow-up) | docs-rsshub-install.md |
| https://github.com/DIYgod/RSSHub/releases/tag/v2026.11.20-8704.fcfe5ae (skipped: covered by releases/latest) | - |

Skipped categories: GitHub HTML repo/blob pages (raw or API variant used instead), github.com releases tag page, docs.rsshub.app root, the other github blob URL for the same Dockerfile.

Failures: 1 (https://docs.rsshub.app/deploy/ returned no extractable content; recorded in docs-rsshub-install.md; not retried).

## plan.md corrections
- No edits made.
- Stale version, not an error at plan time: plan.md (lines 8, 91) pins `v2026.11.25-8755.g8927949`; GitHub latest release at fetch time is `v2026.11.27-8768.gbfc93be`. Not edited (renovate/bake/tests all reference the version; left for the author to bump).
- Confirmed by fetch: EXPOSE 1200, ENTRYPOINT dumb-init, CMD npm run start, node:26 bases, final stage apt packages (plan line 14 matches).
