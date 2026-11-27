# filebot context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/filebot/values.yaml | truecharts-filebot-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/filebot/Chart.yaml | truecharts-filebot-chart.md |
| https://raw.githubusercontent.com/jlesage/docker-filebot/v26.09.2/Dockerfile | jlesage-docker-filebot-dockerfile.md |
| https://raw.githubusercontent.com/jlesage/docker-filebot/master/LICENSE | jlesage-docker-filebot-license.md |
| https://www.filebot.net/getting-started/index.html | filebot-getting-started.md (no content) |
| https://github.com/jlesage/docker-filebot/releases/tag/v26.09.2 (HTML fallback for API) | not written; date only, recorded here: published 2026-09-22T15:17:17Z |

Skipped: github.com blob Dockerfile (same as raw), github.com repo page (HTML), get.filebot.net portable tarball (binary, not downloaded), get.filebot.net listing and FileBot_5.3.0 listing (not fetched, budget/binary), filebot.net home (not fetched), FileBot 5.3.0 portable tarball URL (binary).

Failures:
- https://api.github.com/repos/jlesage/docker-filebot/releases/tags/v26.09.2: HTTP 403. One alternative (HTML releases tag page) used; date recovered, asset list not recovered.
- https://www.filebot.net/getting-started/index.html: no usable content (not summarized beyond the note file).

## plan.md corrections
- plan.md line 8, "Chart tag today": was `ghcr.io/jlesage/filebot:v26.09.2`. TrueCharts values.yaml and appVersion (fetched 2026-11-27) pin `v26.11.2`. Edited line 8 to state v26.11.2 and keep the v26.09.2 release facts.
- The plan still builds the wrapper at v26.09.2 (Dockerfile reviewed at that tag). The v26.11.2 wrapper Dockerfile was not fetched (not in urls.txt); a decision on the build tag is still open.
- Unverified (not edited): plan.md line 15 FileBot's own license (not confirmed by any fetched page here).
