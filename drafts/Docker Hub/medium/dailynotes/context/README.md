# context README: dailynotes

| Source URL | File |
| --- | --- |
| https://github.com/djedi/DailyNotes | upstream-github.md (repo root, covered by raw files) |
| https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/Dockerfile | upstream-github.md |
| https://github.com/djedi/DailyNotes/blob/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/Dockerfile | upstream-github.md (same as raw) |
| https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/README.md | upstream-github.md |
| https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/LICENSE | upstream-github.md |
| https://github.com/djedi/DailyNotes/blob/HEAD/requirements.txt | upstream-github.md (requirements, HEAD raw) |
| https://raw.githubusercontent.com/djedi/DailyNotes/HEAD/requirements.txt | upstream-github.md |
| https://hub.docker.com/v2/repositories/m0ngr31/dailynotes/tags/latest | upstream-github.md (Docker Hub section) |
| https://hub.docker.com/r/m0ngr31/dailynotes | not fetched (JS-rendered; tag API used) |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dailynotes/values.yaml | not fetched (chart reference; plan already cites its values) |
| run.sh and verify_env.py (followed sub-pages) | upstream-github.md |

Skipped: TrueCharts tree page (chart reference, not build source).
Failures: none. Releases API not called (not in urls.txt; plan already lists release 2026.10.29-00).

## plan.md corrections
None edited. Checked against fetched sources:
- Dockerfile at 9d1a3a7e, EXPOSE 8000, healthcheck, no USER/VOLUME/ENV, MIT license, env var list: consistent.
- Plan line 20 says run.sh "may do ownership changes (PUID/PGID)". Fetched run.sh does not: it runs verify_env.py, `flask db upgrade`, verify_data_migrations.py, then `exec gunicorn server:app -b 0.0.0.0:8000`. Not a proven error in the plan, but it is a fact to use in the build: no PUID/PGID handling. Left unchanged.
- Build-time gotcha (not in plan): run.sh needs `flask` and `gunicorn`, which are not in requirements.txt. The plan should account for them.
