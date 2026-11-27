# Odoo documentation (on-premise deploy, 20.0)

## Source URL(s) + date
- https://www.odoo.com/documentation/20.0/administration/on_premise/deploy.html (fetched 2026-11-27; reached by redirect from /administration/install/deploy.html)
- https://www.odoo.com/documentation/20.0/administration/install.html: redirect page only (failed, see README)

## Config keys (on-premise deploy)
| Key | Use |
| --- | --- |
| admin_passwd | Master password for DB management screens; set in config file only |
| db_host, db_port, db_user, db_password | PostgreSQL connection |
| dbfilter | Regex to match DB name per host (e.g. `^mycompany.*$`) |
| list_db | Set False to hide DB list when dbfilter maps to one DB |
| proxy_mode | True when behind a reverse proxy (nginx sample) |
| workers | 0 = threaded server (default, also for Docker); >0 = multiprocessing |
| gevent-port | Longpolling/LiveChat worker port in multiprocess mode |

## Ports (nginx sample)
- Odoo HTTP upstream 8069; longpolling / chat upstream 8072.

## Notes
- PostgreSQL by default accepts only UNIX socket and loopback connections; remote access needs config.
- Odoo recommends a reverse proxy with HTTPS for production (sample nginx config in page).

## Not extracted
- odoo.com/documentation landing page: JS-rendered, no usable content.
