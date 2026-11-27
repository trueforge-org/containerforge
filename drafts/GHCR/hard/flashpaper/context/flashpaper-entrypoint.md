# FlashPaper docker/entrypoint.sh

Source URL: https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/entrypoint.sh (commit 7c986b3, fetched 2026-11-27)

## Shell
- `#!/usr/bin/env ash`

## Steps
1. `chown -R nginx: /var/www/html/data/`
2. `touch /var/www/html/data/index.php`
3. `php-fpm` (no flags in the script)
4. `nginx -c /etc/nginx/nginx.conf`
5. Readiness loop, 3 tries, 2s sleep: `curl -sm3 localhost | grep -q "AndrewPaglusch/FlashPaper"`; prints ready or not ready
6. Echo "Access logging is disabled for production use. Tailing error logs..."
7. `tail -f /var/log/nginx/error.log /var/log/php/error.log` (keeps PID 1 alive; no exec of a daemon)

## Gotchas
- Uses `chown` on the data dir: needs root or CAP_CHOWN at runtime, and writes into /var/www/html/data.
- `touch data/index.php` creates an empty index file in the data dir.
- Readiness check greps the HTML for the string "AndrewPaglusch/FlashPaper".
- No env vars read.
