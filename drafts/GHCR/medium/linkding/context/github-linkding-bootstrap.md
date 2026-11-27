# sissbruecker/linkding - bootstrap.sh (v1.47.0)

Source URL(s) + date: https://raw.githubusercontent.com/sissbruecker/linkding/v1.47.0/bootstrap.sh (fetched 2026-11-27)

## Behaviour (container CMD)
1. Env defaults: `LD_SERVER_HOST=[::]`, `LD_SERVER_PORT=9090`.
2. `mkdir -p data data/favicons data/previews data/assets`
3. `python manage.py generate_secret_key`
4. `python manage.py migrate`
5. `python manage.py enable_wal`
6. `python manage.py create_initial_superuser`
7. `python manage.py migrate_tasks`
8. `chown -R www-data: /etc/linkding/data`
9. Start:
   - If `LD_SUPERVISOR_MANAGED=True`: `exec supervisord -c supervisord-all.conf`
   - Else: if `LD_DISABLE_BACKGROUND_TASKS != True`, `supervisord -c supervisord-tasks.conf` (daemon); then `exec uwsgi --http $LD_SERVER_HOST:$LD_SERVER_PORT uwsgi.ini`

## Gotchas
- Script runs `chown www-data:` so the data dir is owned by www-data; running as a non-root UID needs write access to `data/`.
