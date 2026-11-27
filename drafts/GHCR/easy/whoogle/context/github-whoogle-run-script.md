# Upstream run script: benbusby/whoogle-search @ v1.2.4 (run)

Source URL(s) + date: https://raw.githubusercontent.com/benbusby/whoogle-search/v1.2.4/run (fetched 2026-11-27)

## Behaviour
- `./run` runs web app; `./run test` runs pytest.
- Sets APP_ROOT=$SCRIPT_DIR/app and STATIC_FOLDER; removes app/static/build/*.js and *.css; mkdir static dir.
- If UNIX_SOCKET set: `python3 -um app --unix-socket "$UNIX_SOCKET"`.
- Else: listens on `${ADDRESS:-0.0.0.0}` and port `${PORT:-${EXPOSE_PORT:-5000}}`: `python3 -um app --host ... --port ...`.

## Env vars used
| Env | Default | Use |
| --- | --- | --- |
| ADDRESS | 0.0.0.0 | bind host |
| PORT | falls back to EXPOSE_PORT, then 5000 | bind port |
| EXPOSE_PORT | 5000 (from Dockerfile ENV) | port fallback |
| UNIX_SOCKET | unset | unix socket mode |
