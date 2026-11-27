# context index: xonotic (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xonotic/values.yaml | truecharts-xonotic.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xonotic/Chart.yaml | truecharts-xonotic.md |
| https://raw.githubusercontent.com/ich777/docker-xonotic-server/master/Dockerfile (+ scripts/start.sh, scripts/start-server.sh) | ich777-docker-xonotic-server.md |
| https://dl.xonotic.org/xonotic-0.8.6.sha512 | xonotic-checksums-0.8.6.md |

Skipped: https://github.com/ich777/docker-xonotic-server/blob/master/Dockerfile and /tree/master/scripts (duplicates of raw); https://dl.xonotic.org (index page, not fetched); https://dl.xonotic.org/xonotic-0.8.6.zip (binary download category); https://gitlab.com/xonotic/xonotic and its wiki, https://xonotic.org, https://www.xonotic.org, https://xonotic.org/download (site and repo pages, not fetched).

Failures: none.

## Notes for plan (not edits)
- sha512 file has 4 entries (zip, -source.zip, -high.zip, -mappingsupport.zip). plan.md line 14 names only two; "lists" is incomplete, not wrong. Not edited.
- Chart sets GAME_VERSION 0.8.2 while upstream Dockerfile default is 0.8.5 and the plan targets 0.8.6. Chart value is a downstream override, not a plan fact.

## plan.md corrections
- None made.
