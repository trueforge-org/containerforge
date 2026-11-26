# Docker Hub papermerge/papermerge

Source URL: https://hub.docker.com/r/papermerge/papermerge (fetched)

- Image: papermerge/papermerge; size 126 MB; 100K+ pulls.
- Tags listed: 3.6.0a16-oidc (only one shown); `latest` used in examples.
- Port: 8000:8000 in examples.
- Env vars: PAPERMERGE__MAIN__SECRET_KEY (required); DJANGO_SUPERUSER_PASSWORD (required); DJANGO_SUPERUSER_USERNAME (default admin); PAPERMERGE__DATABASE__TYPE, __USER, __PASSWORD, __NAME, __HOST. Default DB sqlite3.
- Volumes: none on app; compose uses postgres_data -> /var/lib/postgresql/data/ on bitnami/postgresql:14.4.0.
- Login: POST http://localhost:8000/api/auth/login/
- Arch: not stated.
- Run: `docker run -p 8000:8000 -e PAPERMERGE__MAIN__SECRET_KEY=abc -e DJANGO_SUPERUSER_PASSWORD=123 papermerge/papermerge:latest`
- Conflict: env var prefix differs from docs 3.5 (PAPERMERGE__SECURITY__SECRET_KEY, PAPERMERGE__AUTH__PASSWORD) and port differs (8000 here vs 12000 in docs; 80 in Dockerfile).
