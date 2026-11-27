# Context: hasty-paste

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hasty-paste/values.yaml | truecharts-hasty-paste.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hasty-paste/Chart.yaml | truecharts-hasty-paste.md |
| https://raw.githubusercontent.com/enchant97/hasty-paste/ad6a831789716dfdfde3a68e22ff5bb2ef1b0851/app/Dockerfile (also blob URL) | github-enchant97-hasty-paste.md |
| https://raw.githubusercontent.com/enchant97/hasty-paste/main/README.md (repo main page) | github-enchant97-hasty-paste.md |
| https://github.com/enchant97/hasty-paste/releases/tag/v2.5.1 (HTML, replaces API) | github-enchant97-hasty-paste.md |
| https://github.com/enchant97/hasty-paste/blob/main/docs/install.md | failed (404 on main, and on master); see failures |

Skipped categories: the `api.github.com/repos/enchant97/hasty-paste/releases/latest` call (403, see failures); the docs site `hastypaste.docs.enchantedcode.co.uk` (linked from README, not fetched; budget); Buy Me A Coffee and demo video links (not build inputs).

Failures:
- https://api.github.com/repos/enchant97/hasty-paste/releases/latest: 403. One alternative (HTML release tag page `v2.5.1`): 200, no release asset links found.
- https://raw.githubusercontent.com/enchant97/hasty-paste/main/docs/install.md: 404. One alternative (`master` branch): 404. Not summarized.

## plan.md corrections
- None applied. Plan values match the fetched sources (port 8080 in the upstream image, `VOLUME /opt/hasty-paste/data`, `DB_URI`, `ATTACHMENTS_PATH`, Dockerfile pinned at ad6a831).
- Confirmed by fetch: "The release has zero assets" is consistent with the HTML release page (no `releases/download/v2.5.1/` links). Not a conflict.
