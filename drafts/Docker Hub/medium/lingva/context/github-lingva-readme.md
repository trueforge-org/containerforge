# Upstream README (TheDavidDelta/lingva-translate, main)

## Source URL(s) + date
- https://raw.githubusercontent.com/TheDavidDelta/lingva-translate/main/README.md (2026-11-26)
- License file: https://raw.githubusercontent.com/TheDavidDelta/lingva-translate/main/LICENSE (first lines): GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007.
- Not fetched: github.com/TheDavidDelta/lingva-translate repo root (README and LICENSE covered via raw).

## What it is
- Lingva Translate: Next.js project, alternative front-end for Google Translate. Deploy anywhere Next is supported.

## Env vars (README)
| Name | Required | Meaning |
| --- | --- | --- |
| NEXT_PUBLIC_SITE_DOMAIN | yes | domain used for canonical URL and meta tags |
| NEXT_PUBLIC_FORCE_DEFAULT_THEME | no | `light` or `dark` |
| NEXT_PUBLIC_DEFAULT_SOURCE_LANG | no | default `auto` |
| NEXT_PUBLIC_DEFAULT_TARGET_LANG | no | default `en` |

## Docker (README)
- Official image `thedaviddelta/lingva-translate`. Compose example: `site_domain=lingva.ml`, port `3000:3000`.
- `docker run -p 3000:3000 -e site_domain=lingva.ml ... thedaviddelta/lingva-translate:latest`.

## Gotchas
- Vercel deployment is the upstream primary model.
