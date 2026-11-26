# Dispatcharr/Dispatcharr pyproject.toml (tag v0.34.1)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/pyproject.toml · 2026-11-26

## Metadata
- Name `dispatcharr`. Version dynamic (hatch, from `version.py`). `requires-python >=3.13`. License `AGPL-3.0-only`. Build backend hatchling; wheel packages `dispatcharr`, `apps`, `core`.

## Pinned (==)
Django 6.0.10 (stay on 6.0.x until django-celery-beat supports 6.1), celery[redis] 5.7.0, djangorestframework 3.18.3, requests 2.34.2, psutil 7.2.2, gevent 26.9.0, rapidfuzz 3.14.6, torch 2.15.0+cpu, sentence-transformers 6.3.0, channels-redis 4.3.0, lxml 6.1.3.

## Ranges
redis `>=8.0.0,<9`; drf-spectacular `>=0.30.0`; django-celery-beat `>=2.9.0`.

## Unpinned
psycopg[binary], pillow, streamlink, python-vlc, yt-dlp, django-db-geventpool, daphne, uwsgi, django-cors-headers, djangorestframework-simplejwt, m3u8, regex, tzlocal, pytz, channels, django-filter, django-redis, packaging.

## uv torch index
- `[[tool.uv.index]]` name `pytorch-cpu`, URL `https://download.pytorch.org/whl/cpu`, `explicit = true`. `[tool.uv.sources]` maps torch to `{ index = "pytorch-cpu" }`.
