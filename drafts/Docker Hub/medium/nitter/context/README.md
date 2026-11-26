# context: nitter

Fetched 2026-11-26.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nitter/values.yaml | truecharts-nitter.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nitter/Chart.yaml | truecharts-nitter.md |
| https://hub.docker.com/v2/repositories/zedeus/nitter/ | dockerhub-zedeus-nitter.md |
| https://hub.docker.com/v2/repositories/zedeus/nitter/tags?page_size=10 | dockerhub-zedeus-nitter.md |
| https://github.com/zedeus/nitter | github-nitter.md |
| https://github.com/zedeus/nitter/blob/145ca9eb68d195a74598ae39a4d6da002b252c38/Dockerfile | github-nitter.md (raw variant fetched; identical to master) |
| https://raw.githubusercontent.com/zedeus/nitter/145ca9eb68d195a74598ae39a4d6da002b252c38/Dockerfile | github-nitter.md |
| https://github.com/zedeus/nitter/blob/main/Dockerfile | github-nitter.md (raw main 404; master fetched instead) |

Skipped: none of the categories listed in the batch brief were present. No CLA, forgetool schema, containerforge or templated URLs were in the list.

Failures:
- https://api.github.com/repos/zedeus/nitter/releases/latest: HTTP 403 (rate limit). Alternative: releases HTML page (200, no tags). Recorded.
- https://raw.githubusercontent.com/zedeus/nitter/main/Dockerfile: HTTP 404. Alternative `master` fetched (200).

## plan.md corrections
- plan.md line 15: `https://github.com/zedeus/nitter/blob/main/Dockerfile` -> `https://github.com/zedeus/nitter/blob/master/Dockerfile` (source: raw main 404, raw master 200).

Unverified conflicts (not edited):
- plan.md line 8/178: pinned commit 145ca9eb Dockerfile is now fetched and is byte-identical to master. Plan still says UNVERIFIED.
- plan.md line 15 says upstream `EXPOSE 8080`: confirmed. Chart port 10606 is chart-side (see truecharts-nitter.md).
