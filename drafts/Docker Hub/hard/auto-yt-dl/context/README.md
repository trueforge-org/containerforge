# auto-yt-dl context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://hub.docker.com/r/guhu007/auto-yt-dl | dockerhub-guhu007-auto-yt-dl.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/auto-yt-dl | truecharts-auto-yt-dl.md |
| https://github.com/xXGuhuXx/auto-yt-dl and /yt-channel-dl (both 404) | github-xxguhuxx-auto-yt-dl-and-yt-channel-dl.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base-app link.
- `ghcr.io/trueforge-org/ubuntu`, `docker.io/guhu007/auto-yt-dl`, `xxguhuxx/yt-channel-dl` (image refs, not web pages; the Hub page itself is summarised).

## Fetch failures
- https://github.com/xXGuhuXx/auto-yt-dl: HTTP 404 (also linked from draft.md and plan.md; no retry needed, the Hub page gives no alternative source).
- https://github.com/xXGuhuXx/yt-channel-dl: HTTP 404 (repo named in the Hub example run command). Recorded.

## plan.md corrections
None. Checked: pull count, size, last-updated age, port 5000/tcp, `/app/Downloads`, source 404, no version tags: consistent.

## Unverified (not changed in plan.md)
- plan.md section 1 `/app/data` content: chart mounts it; upstream does not document it.
- Licence: not stated by any fetched source.
- Draft `copy-from` says "app directory, path unknown": no Dockerfile or app layout is public from the fetched sources.
