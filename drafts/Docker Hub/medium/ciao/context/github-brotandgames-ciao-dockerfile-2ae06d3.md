# brotandgames/ciao Dockerfile @ 2ae06d3

Source: https://raw.githubusercontent.com/brotandgames/ciao/2ae06d337c5f8e669273228852613575cdb91e2d/Dockerfile (fetched 2026-11-26)

## Stage 1 `builder`
- `FROM ruby:4.0.6-slim`; ARG RACK_ENV=production -> ENV RACK_ENV
- apt-get update -qq; install `--no-install-recommends` build-essential git libsqlite3-dev tzdata; apt-get clean; rm /var/lib/apt/lists/*
- WORKDIR /app; COPY Gemfile Gemfile.lock
- `bundle config set --local without 'development test'`; `bundle install --jobs $(nproc) --retry 3`; rm /usr/local/bundle/cache/*.gem; delete *.c, *.o under /usr/local/bundle/gems/
- COPY . ./
- `SECRET_KEY_BASE=foo bundle exec rake assets:precompile`; rm /tmp/*, app/assets, lib/assets, spec, tmp/cache, vendor/assets

## Stage 2 final
- `FROM ruby:4.0.6-slim`; LABEL org.opencontainers.image.source=https://github.com/brotandgames/ciao
- COPY --from=builder /usr/local/bundle and /app
- Group `rails` GID 1000; user `rails` UID 1000 GID 1000, home created, shell /bin/bash
- chown -R rails:rails db log storage tmp
- USER rails:rails
- ENV RAILS_LOG_TO_STDOUT=true, RAILS_SERVE_STATIC_FILES=true, EXECJS_RUNTIME=Disabled
- EXPOSE 3000; VOLUME /app/db/sqlite
- CMD ["./start.sh"]; no ENTRYPOINT

## Notes
- No downloads, checksums or ARG beyond RACK_ENV
