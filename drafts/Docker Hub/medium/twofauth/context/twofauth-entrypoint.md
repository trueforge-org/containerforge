# 2FAuth docker/entrypoint.sh (tag v9.0.3)

Source URL(s): https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/docker/entrypoint.sh (fetched 2026-11-27)

## Behaviour (sh, `set -e`)
1. `file_env` helper: for each of these, if `VAR_FILE` is set, reads the file into `VAR` (errors if both set):
   APP_KEY, DB_DATABASE, DB_USERNAME, DB_PASSWORD, DB_HOST, MAIL_USERNAME, MAIL_PASSWORD, REDIS_PASSWORD.
2. Prints version, `supervisord version`, `php-fpm84 -v`, `nginx -v`.
3. SQLite handling (only when `DB_CONNECTION=sqlite`):
   - If DB_DATABASE is not the default `/srv/database/database.sqlite`, touches that custom path if missing.
   - Default path: creates `/2fauth/database.sqlite` if missing, replaces `/srv/database/database.sqlite` with symlink to it.
4. Storage: if `/2fauth/storage` missing, moves `/srv/storage` there; otherwise removes `/srv/storage`. Symlinks `/srv/storage` -> `/2fauth/storage`.
5. Warns if APP_KEY empty (does not exit).
6. `php artisan migrate --force` (always).
7. Compares `/2fauth/installed` (stores COMMIT) with `${COMMIT}`:
   - Differs: `cache:clear`, `config:clear`, `2fauth:fix-passport-key-permissions` (non-fatal).
   - No file: `php artisan passport:install --no-interaction`.
   - Writes `${COMMIT}` to `/2fauth/installed`.
8. `storage:link --quiet`, `clear-compiled`, `optimize`.
9. `exec`-less final line: `supervisord` (runs php-fpm84 and nginx per supervisord.conf).

## Gotchas
- Persistent state lives in `/2fauth` (sqlite db, storage, passport keys, `installed` marker).
- No `exec`; supervisord is PID-level launcher.
