# simse/chronos Dockerfile @ 067532f

Source: https://raw.githubusercontent.com/simse/chronos/067532f/Dockerfile (fetched 2026-11-26)

## Base
- `FROM python:3.7-buster` (single stage); no ARG, no USER (root)
- Label: author Simon Sorensen, hello@simse.io

## Steps
- ENV TZ=GMT; RUN links /usr/share/zoneinfo/$TZ -> /etc/localtime, writes /etc/timezone
- Yarn apt repo: curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add; `deb https://dl.yarnpkg.com/debian/ stable main` -> /etc/apt/sources.list.d/yarn.list
- apt-get update; `pip install cython`; apt-get install freetds-dev; `pip install pymssql` (unpinned)
- apt-get install nodejs yarn (Debian repo, unpinned)
- COPY . -> /app/chronos
- WORKDIR /app/chronos/chronos-ui: `yarn`; `yarn build`
- WORKDIR /app/chronos: `pip install -r requirements.txt`

## Runtime
- EXPOSE 5000; VOLUME /chronos
- ENV CHRONOS_PATH=/chronos; CHRONOS=yes_sir_docker
- ENTRYPOINT shell form `python chronos.py`; no CMD
