# Docker Hub danmed/tasmobackupv1

Source URL: https://hub.docker.com/r/danmed/tasmobackupv1 (fetched 2026-11-26)

- Tags: only `latest`. Size 125.7 MB. Updated ~1 month ago. Digest sha256:edd9bad4b…
- Architectures: not stated.
- Pull: `docker pull danmed/tasmobackupv1`
- Ports: container 80 -> host 8259.
- Volume: `./data` -> `/var/www/html/data`.

## Env
| Var | Value / note |
| --- | --- |
| DBTYPE | `sqlite` (default) or `mysql` |
| DBNAME | `data/tasmobackup` for SQLite (data/ prefix required); `tasmobackup` for MySQL |
| MYSQL_SERVER | MySQL host (not needed for SQLite) |
| MYSQL_USERNAME | MySQL user |
| MYSQL_PASSWORD | MySQL password |

- MySQL needs an existing blank database.

## Run
- SQLite: `docker run -d -p 8259:80 -v ./data:/var/www/html/data -e DBTYPE=sqlite -e DBNAME=data/tasmobackup --name TasmoBackup danmed/tasmobackupv1`
- Compose: service `tasmobackup`, container_name TasmoBackup.
- Scheduled backups: `backupall.php`.
