# FlashPaper docker/nginx.conf

Source URL: https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/nginx.conf (commit 7c986b3, fetched 2026-11-27; NOT in urls.txt, fetched to resolve the plan.md listen-port UNVERIFIED item)

## Settings
| Directive | Value |
| --- | --- |
| events | `{}` (defaults) |
| listen | 80 |
| root | /var/www/html |
| index | index.php |
| access_log | /dev/null |
| location / | `try_files $uri $uri/ =404;` with `include mime.types` |
| location ~ \.php$ | `fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;` index index.php; SCRIPT_FILENAME $document_root$fastcgi_script_name; include fastcgi_params; REQUEST_SCHEME from $http_x_forwarded_proto if not empty |

## Gotchas
- No `pid` or `user` directives: nginx default pid path and worker user apply (not set in file).
- Upstream listens on port 80 (plan.md line 19 wording "UNVERIFIED" for the listen port is now resolved).
- Socket path /var/run/php-fpm/php-fpm.sock must match php-fpm.conf (not fetched).
