# Context: retrobot

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/retrobot/values.yaml + Chart.yaml | truecharts-retrobot.md |
| https://raw.githubusercontent.com/rossimo/retrobot/d04ddd8/Dockerfile (+ package.json at d04ddd8, README on master) | rossimo-retrobot-upstream.md |
| https://registry.npmjs.org/retrobot/latest | npm-retrobot-registry.md |

Skipped (not fetched): Docker Hub (image is on GHCR; README mentions a Docker Hub image `rossimo/retrobot`, not fetched); github.com repo root and Dockerfile blob URL (raw used); api.github.com/repos/rossimo/retrobot (not fetched); the CLA; forgetool schemas; containerforge app links; image refs.

Failures: none from urls.txt. A self-guessed LICENSE raw path at d04ddd8 returned 404 (not in urls.txt, not retried); MIT licence is confirmed from package.json and README instead.

## plan.md corrections
- None applied.
- Confirmed by fetched sources: package.json at d04ddd8 is `libretro-webassembly-simple`, MIT, start `ts-node src/index.ts`; npm `retrobot` is an unrelated Slack bot (plan line 16 is correct); Dockerfile matches plan line 14.
- Unverified: plan line 10 cites the GitHub API licence (MIT); MIT is supported by package.json and README, so no conflict.
- Note: README docker example mounts `/retrobot/data`, which matches the chart path. Plan line 19 says the upstream write path is not confirmed; this is a documented mount in the README, not a verified write path.
