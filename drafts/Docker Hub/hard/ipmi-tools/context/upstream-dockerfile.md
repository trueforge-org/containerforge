# IPMI-Fan-Controller Dockerfile (pinned commit)

Source URL(s): https://raw.githubusercontent.com/EdwardChamberlain/IPMI-Fan-Controller/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246/dockerfile (blob: https://github.com/EdwardChamberlain/IPMI-Fan-Controller/blob/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246/dockerfile). Fetched 2026-11-26.

## Base / build
- `FROM tiangolo/meinheld-gunicorn-flask:python3.8`
- ARG/ENV: none
- apt: `apt-get update`, install `ipmitool` (`-y`)
- pip, one RUN per package: `flask-wtf`, `wtforms`, `flask-bootstrap4`
- `COPY ./app /app`
- No WORKDIR, USER, ENTRYPOINT/CMD (inherited from base), EXPOSE, VOLUME, LABEL

## Runtime deps
- ipmitool (apt), Python 3.8 + Flask stack from base image

## Gotchas
- Runs as base image default user (no USER set).
- Inherits base image entrypoint/CMD; not defined here.
