# pwpush-ephemeral Dockerfile (containers/docker/pwpush-ephemeral)

Source URL: https://github.com/pglombardo/PasswordPusher/blob/0590f8d12e5a59f210542fb7d86348c6e7f06a85/containers/docker/pwpush-ephemeral/Dockerfile (fetched via raw.githubusercontent.com, pinned commit)

## Summary
- Single-stage shim. `ARG BASEIMAGE=pwpush:latest`; `FROM $BASEIMAGE`.
- No packages installed. No COPY/ADD.
- RUN edits existing ./containers/docker/pwpush/entrypoint.sh with `sed -i '5 a ...'`, inserting echo lines after line 5: end-of-support banner (no new features or security updates; migrate; points to github.com/pglombardo/PasswordPusher).
- ENV DATABASE_URL=sqlite3:db/db.sqlite3
- No EXPOSE, USER, WORKDIR, VOLUME, HEALTHCHECK. ENTRYPOINT/CMD inherited from base.

## Gotchas
- Image is end-of-support. Runtime behaviour comes entirely from the base pwpush image (see upstream-dockerfile.md).
- Default DATABASE_URL is SQLite in-container path (ephemeral if no volume).
