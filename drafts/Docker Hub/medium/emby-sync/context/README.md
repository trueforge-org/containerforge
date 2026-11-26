# context README: emby-sync

| Source URL | File |
| --- | --- |
| https://github.com/cameronurnes/emby-sync | upstream-github.md (repo root, covered) |
| https://github.com/cameronurnes/emby-sync/blob/63bd8b3/Dockerfile | upstream-github.md (same as raw) |
| https://raw.githubusercontent.com/cameronurnes/emby-sync/63bd8b3/Dockerfile | upstream-github.md |
| https://github.com/cameronurnes/emby-sync/blob/HEAD/requirements.txt | upstream-github.md (HEAD raw) |
| https://github.com/cameronurnes/emby-sync/releases | upstream-github.md (releases API: 404, no releases) |
| https://hub.docker.com/r/lastelement21/emby-sync | upstream-github.md (tags API used, HTML not fetched) |
| http://emby.invalid | not usable: placeholder host, DNS failure (`.invalid` is reserved); no alternative tried |

Skipped: TrueCharts tree page (chart reference, not build source).
Failures: http://emby.invalid (DNS error, placeholder); releases API 404 (expected: no releases).
Followed sub-pages: boot.sh, config.py (merged into upstream-github.md).

## plan.md corrections
None edited. Checked: Dockerfile at 63bd8b3 (python:3.7-alpine, venv, requirements + gunicorn, FLASK_APP, EXPOSE 5000, ENTRYPOINT boot.sh) and boot.sh (flask db upgrade, gunicorn :5000) match plan section 1. Env vars match config.py. No releases: consistent with plan.
Note (not a plan error): upstream boot.sh uses a relative `venv/`; the plan installs into `/app/venv`, so the plan's start script must activate or call `/app/venv` explicitly.
