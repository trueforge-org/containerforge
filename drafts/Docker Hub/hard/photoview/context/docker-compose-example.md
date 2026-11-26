# Upstream compose example (docker-compose example/docker-compose.example.yml)

Source URL: https://raw.githubusercontent.com/photoview/photoview/master/docker-compose%20example/docker-compose.example.yml (fetched, follow-up)

## Services
- photoview-prepare: photoview/photoview:2; user root; cap_add CHOWN; runs chown of /home/photoview/media-cache to photoview:photoview after 1s sleep; volume ${HOST_PHOTOVIEW_LOCATION}/storage -> /home/photoview/media-cache
- photoview: photoview/photoview:2; restart unless-stopped; ports 8000:80; seccomp/apparmor unconfined; depends_on prepare (completed) and mariadb (healthy)
  - ENV: PHOTOVIEW_DATABASE_DRIVER, PHOTOVIEW_MYSQL_URL=${MARIADB_USER}:${MARIADB_PASSWORD}@tcp(photoview-mariadb)/${MARIADB_DATABASE}, PHOTOVIEW_LISTEN_IP=0.0.0.0, MAPBOX_TOKEN, PHOTOVIEW_VIDEO_HARDWARE_ACCELERATION
  - volumes: ${HOST_PHOTOVIEW_LOCATION}/storage -> /home/photoview/media-cache; ${HOST_PHOTOVIEW_MEDIA_ROOT} -> /photos (ro); localtime/timezone ro
  - no user set (image default); no healthcheck
- mariadb: mariadb:lts; hostname photoview-mariadb; env MARIADB_AUTO_UPGRADE=1, MARIADB_DATABASE, MARIADB_USER, MARIADB_PASSWORD, MARIADB_ROOT_PASSWORD; volume ${HOST_PHOTOVIEW_LOCATION}/database/mariadb -> /var/lib/mysql; healthcheck healthcheck.sh --connect --innodb_initialized (1m/5s/5/3m)
- watchtower: nickfedor/watchtower:latest (optional auto-update)
- Commented: postgres:18-alpine (+ pgautoupgrade 18), pg_isready healthcheck
- Networks: ui_net (bridge), api_db_net (internal), ext_only_net (bridge)
