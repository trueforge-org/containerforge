# context: rss-to-telegram

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rss-to-telegram/values.yaml | truecharts-rss-to-telegram.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rss-to-telegram/Chart.yaml | truecharts-rss-to-telegram.md |
| https://hub.docker.com/v2/repositories/bokker/rss.to.telegram/ (+ tags?page_size=10) | dockerhub-rss-to-telegram.md |
| https://api.github.com/repos/BoKKeR/RSS-to-Telegram-Bot | github-rss-to-telegram.md |
| https://api.github.com/repos/BoKKeR/RSS-to-Telegram-Bot/contents/.env.example | github-rss-to-telegram.md |
| https://api.github.com/repos/BoKKeR/RSS-to-Telegram-Bot/contents/.nvmrc | github-rss-to-telegram.md |
| https://api.github.com/repos/BoKKeR/RSS-to-Telegram-Bot/releases/tags/2.0.9 | github-rss-to-telegram.md |
| https://raw.githubusercontent.com/BoKKeR/RSS-to-Telegram-Bot/3675d2e9c4d9731cec685a8417f7b724e2921e9a/Dockerfile | github-rss-to-telegram.md |
| https://raw.githubusercontent.com/BoKKeR/RSS-to-Telegram-Bot/3675d2e9c4d9731cec685a8417f7b724e2921e9a/package.json | github-rss-to-telegram.md |
| https://raw.githubusercontent.com/BoKKeR/RSS-to-Telegram-Bot/3675d2e9c4d9731cec685a8417f7b724e2921e9a/LICENSE (follow-up for plan license conflict) | github-rss-to-telegram.md |
| start_bot.sh at 3675d2e (follow-up, referenced by Dockerfile) | github-rss-to-telegram.md |
| https://github.com/BoKKeR/RSS-to-Telegram-Bot (repo HTML) | skipped: covered by api repo call |
| https://github.com/BoKKeR/RSS-to-Telegram-Bot/blob/3675d2e.../Dockerfile | skipped: raw variant fetched |
| https://github.com/BoKKeR/RSS-to-Telegram-Bot/releases/tag/2.0.9 | skipped: api releases/tags used |

Skipped categories: GitHub HTML/blob variants (raw or api used), repo HTML page. No templated, binary-download, CLA or image-ref URLs in list.

Failures: none.

## plan.md corrections
- No edits made.
- Resolved (no edit needed): plan line 10 license conflict. The LICENSE file at 3675d2e is GPL-3.0 (matches plan default `GPL-3.0` at line 81); package.json says MIT. Plan's UNVERIFIED marker can be cleared by the author.
- Confirmed: Dockerfile (alpine-node:16, no EXPOSE/ENV/VOLUME/USER), .nvmrc v16.14.2, .env.example env list, start_bot.sh behaviour (no exec).
- Note: Docker Hub reports only amd64 for tags (plan says copy-from amd64 = no; consistent).
