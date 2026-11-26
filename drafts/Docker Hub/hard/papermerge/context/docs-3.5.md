# docs.papermerge.io (3.5)

Sources:
- https://docs.papermerge.io: redirect to 3.5/ ("Redirecting to 3.5/"); no content.
- https://docs.papermerge.io/3.5/ (follow-up): docs home; nav lists setup/docker, setup/docker-compose, setup/requirements, settings (Main, Auth, Security, OCR, Database, Redis, Search Engine, S3/OCR/I3 workers), admin-manual. No install content.
- https://docs.papermerge.io/3.5/setup/docker/ (follow-up): fetched.

## Docker setup (3.5 docs)
- Image: papermerge/papermerge, tag 3.5.3. Apple Silicon: `--platform linux/amd64`.
- Env (required): PAPERMERGE__SECURITY__SECRET_KEY, PAPERMERGE__AUTH__PASSWORD (admin password)
- Port: container 80; example host 12000 -> 80; UI at http://localhost:12000
- Login user: admin
- Volumes, UID, DB/Redis requirements: not on this page (settings docs / compose page).
- Run: `docker run -p 12000:80 -e PAPERMERGE__SECURITY__SECRET_KEY=abc -e PAPERMERGE__AUTH__PASSWORD=pass123 papermerge/papermerge:3.5.3`
- Compose page not included.

## Conflicts (unverified, not applied)
- Env naming in docs 3.5 (PAPERMERGE__SECURITY__*, PAPERMERGE__AUTH__*) vs hub 3.6 tag (PAPERMERGE__MAIN__SECRET_KEY, DJANGO_SUPERUSER_*) vs entrypoint (PM_SECRET_KEY, PM_USERNAME, PM_EMAIL).
