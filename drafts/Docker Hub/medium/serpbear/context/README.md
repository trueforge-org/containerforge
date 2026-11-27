# context: serpbear

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/serpbear/values.yaml | truecharts-serpbear.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/serpbear/Chart.yaml | truecharts-serpbear.md |
| https://hub.docker.com/v2/repositories/towfiqi/serpbear/ (+ tags?page_size=10) | dockerhub-serpbear.md |
| https://api.github.com/repos/towfiqi/serpbear/contents/Dockerfile?ref=v3.1.2 | github-serpbear-dockerfile.md |
| https://api.github.com/repos/towfiqi/serpbear/contents/entrypoint.sh?ref=v3.1.2 | github-serpbear-dockerfile.md |
| https://api.github.com/repos/towfiqi/serpbear/license | github-serpbear-dockerfile.md |
| https://api.github.com/repos/towfiqi/serpbear/releases/tags/v3.1.2 | github-serpbear-dockerfile.md |
| https://github.com/towfiqi/serpbear (repo HTML) | skipped: api variants used |
| https://github.com/towfiqi/serpbear/blob/v3.1.2/Dockerfile | skipped: api variant used |
| https://github.com/towfiqi/serpbear/releases/tag/v3.1.2 | skipped: api releases/tags used |

Skipped categories: GitHub HTML/blob/release pages (api variants used).

Failures: none.

## plan.md corrections
- No edits made.
- Confirmed by Dockerfile/entrypoint: node:22-alpine upstream, USER nextjs uid 1001, EXPOSE 3000, ENTRYPOINT /app/entrypoint.sh, CMD concurrently (plan line 14-15 match).
- Confirmed license MIT (plan line 10 matches).
- Plan line 18 env list (PORT, USER_NAME, PASSWORD, SECRET, APIKEY, NEXT_PUBLIC_APP_URL, SEARCH_CONSOLE_*) is code-level and not in the fetched URLs; not re-verified here. Chart secret keys (secret, password, user, api_key, app_url, session_duration) are the chart-side names that feed serpbear-secret.
