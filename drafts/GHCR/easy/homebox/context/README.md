# homebox context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homebox/values.yaml + Chart.yaml | truecharts-homebox.md |
| Docker Hub | none (image is GHCR: ghcr.io/sysadminsmedia/homebox) |
| https://raw.githubusercontent.com/sysadminsmedia/homebox/main/Dockerfile | homebox-upstream-dockerfile-release.md |
| https://raw.githubusercontent.com/sysadminsmedia/homebox/1fd28822634a3d5935c002d569559ef46530d4a0/Dockerfile (raw of pinned blob) | homebox-upstream-dockerfile-release.md |
| https://api.github.com/repos/sysadminsmedia/homebox/releases/latest | homebox-upstream-dockerfile-release.md |
| https://homebox.software/en | homebox-upstream-dockerfile-release.md (landing page, no config content) |

Skipped categories: api.github.com/repos/sysadminsmedia/homebox (repo metadata), github.com blob/repo HTML duplicates, homebox.software/en/ (localised alias not fetched), Dockerfile blob URL (duplicate).

Failures: none.

## plan.md corrections

- No edits made.
- Plan line 16 says the pinned commit 1fd2882 Dockerfile was not fetched. It was fetched (raw) and is identical to main, so the plan's Dockerfile facts hold for the pinned commit too. Plan not edited (no error found).
- Still UNVERIFIED in plan.md (not resolved by fetched sources): whether the binary starts without `/data/config.yml`; `HBOX_AUTH_API_KEY_PEPPER` requirement at first start (chart comment says the binary refuses to start if shorter than 32 bytes, which is a chart-side statement, not verified upstream).
