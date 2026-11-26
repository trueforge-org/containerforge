# Upstream README (libreddit/libreddit master)

## Source URL(s) + date
- https://raw.githubusercontent.com/libreddit/libreddit/master/README.md (2026-11-26)

## Status
- Header: "As of July 12th, 2023, Libreddit is currently not operational as Reddit's API changes ... went into effect."
- Maintainer note present in README.

## Install (README)
- `cargo install libreddit` (Rust stable + cargo).
- Docker: `docker run -d --name libreddit -p 8080:8080 libreddit/libreddit`.
- Deploy: `libreddit` binds `0.0.0.0:8080`.
- Upstream repos: GitHub libreddit/libreddit, GitLab libreddit/libreddit, Docker Hub libreddit/libreddit.

## Instance settings (`LIBREDDIT_{X}`)
| Name | Values | Default |
| --- | --- | --- |
| SFW_ONLY | on/off | off |
| BANNER | string | empty |
| ROBOTS_DISABLE_INDEXING | on/off | off |
| PUSHSHIFT_FRONTEND | string | www.unddit.com |

## Default user settings (`LIBREDDIT_DEFAULT_{Y}`)
| Name | Values | Default |
| --- | --- | --- |
| THEME | system, light, dark, black, dracula, nord, laserwave, violet, gold, rosebox, gruvboxdark, gruvboxlight | system |
| FRONT_PAGE | default, popular, all | default |
| LAYOUT | card, clean, compact | card |
| WIDE | on/off | off |
| POST_SORT | hot, new, top, rising, controversial | hot |
| COMMENT_SORT | confidence, top, new, controversial, old | confidence |
| SHOW_NSFW | on/off | off |
| BLUR_NSFW | on/off | off |
| USE_HLS | on/off | off |
| HIDE_HLS_NOTIFICATION | on/off | off |
| AUTOPLAY_VIDEOS | on/off | off |
| SUBSCRIPTIONS | `+`-delimited subs | none |
| HIDE_AWARDS | on/off | off |
| DISABLE_VISIT_REDDIT_CONFIRMATION | on/off | off |

- Config file alternative: `libreddit.toml` with the same `LIBREDDIT_DEFAULT_*` keys.

## Gotchas
- Status note above: not operational since 2023-07-12 per upstream.
- Hosting behind NGINX documented in README (section "Proxying using NGINX").
