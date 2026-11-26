# Docker Hub thedaviddelta/lingva-translate

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/thedaviddelta/lingva-translate/ (2026-11-26)
- https://hub.docker.com/v2/repositories/thedaviddelta/lingva-translate/tags?page_size=10 (2026-11-26)

## What it is
- Image `thedaviddelta/lingva-translate`. Description: "Alternative front-end for Google Translate".
- `last_updated` 2022-10-21. `pull_count` 308136. Total tags: 1.

## Tags
| Tag | Arch | Pushed |
| --- | --- | --- |
| latest | amd64 | 2022-10-21 |

- No arm64 image. No version tags.
- Digest pinned by chart: `sha256:7c983756...` (not cross-checked against the tag digest in this run).

## Runtime (from full_description, README copy)
- Port 3000. Env: `site_domain` (required; `NEXT_PUBLIC_SITE_DOMAIN`), `force_default_theme` (`light`/`dark`), `default_source_lang` (default `auto`), `default_target_lang` (default `en`).
- Example: `docker run -p 3000:3000 -e site_domain=lingva.ml -e force_default_theme=light -e default_source_lang=auto -e default_target_lang=en thedaviddelta/lingva-translate:latest`.

## Gotchas
- Image is 3+ years old; upstream repo activity is separate (see github-lingva-readme.md).
