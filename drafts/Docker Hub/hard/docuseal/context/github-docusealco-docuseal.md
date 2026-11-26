# docusealco/docuseal (repo README, Dockerfiles at 3.3.8 and 3.4.0, LICENSE, releases)

Source URL(s) + fetch date:
- https://github.com/docusealco/docuseal (README via raw master)
- https://raw.githubusercontent.com/docusealco/docuseal/a628dd30daafde9f2e7b9ef161a3a9b7c6f4d9fc/Dockerfile (draft commit, 3.3.8)
- https://raw.githubusercontent.com/docusealco/docuseal/3.4.0/Dockerfile (latest tag)
- https://raw.githubusercontent.com/docusealco/docuseal/master/LICENSE
- https://github.com/docusealco/docuseal/releases/tag/3.3.8 and .../tag/3.4.0
- Fetched 2026-11-26

## What it is
- Open source platform for PDF forms, sending them out and collecting electronic signatures (alternative to DocuSign and PandaDoc). Ruby on Rails app (Puma), Shakapacker/webpack for assets.
- Features (repo tag line "#1 Open Source Document Signing"): WYSIWYG field builder, multiple submitters, SMTP, storage on disk/S3/GCS/Azure, API and webhooks. Pro features (white-label, SSO/SAML, bulk send, embedded forms) listed separately.

## License
- AGPLv3 with "Section 7(b) Additional Terms" (README). Repo has two files: LICENSE and LICENSE_ADDITIONAL_TERMS (the latter copied into the image by the Dockerfile; its text was not fetched).
- LICENSE is GNU AGPL v3 (19 Nov 2007); section 7 is "Additional Terms". Copyright 2023-2026 DocuSeal LLC on files per README.

## Install/build steps and build deps (3.4.0 Dockerfile; 3.3.8 identical in structure, ruby 4.0.10 pinned)
- Stage 1 `download`: `FROM ruby:4.0.10-alpine AS download`, WORKDIR `/fonts`; `apk --no-cache add wget unzip`; fetches:
  - https://github.com/satbyy/go-noto-universal/releases/download/v7.0/GoNotoKurrent-Regular.ttf and ...-Bold.ttf
  - https://github.com/impallari/DancingScript/raw/master/fonts/DancingScript-Regular.otf
  - https://raw.githubusercontent.com/impallari/DancingScript/master/OFL.txt
  - https://raw.githubusercontent.com/notofonts/noto-fonts/refs/heads/main/LICENSE
  - model: https://github.com/docusealco/fields-detection/releases/download/2.0.0/model_704_int8.onnx (saved as /model.onnx)
  - pdfium: https://github.com/docusealco/pdfium-binaries/releases/download/20260920/pdfium-musl-$(uname -m).zip
  - Checksum (sha256 via `case "$(uname -m)"`, pdfium only): x86_64 `bbca8a648dbd1ba81f9c6c223f21dc394cf1ad381c6c17d60c6dcc4a7d3a2ae0`; aarch64 `73b72ed79b9bfdd494dee7e863482c24971a8d4b11f6cd1289aa170d31304a1f`. Fonts, model: no check.
  - `unzip -q pdfium-linux.zip -d /pdfium-linux`.
- Stage 2 `webpack`: `FROM ruby:4.0.10-alpine AS webpack`; ENV RAILS_ENV=production NODE_ENV=production; WORKDIR /app; `apk add --no-cache nodejs yarn git build-base`; `gem install shakapacker`; `yarn install --network-timeout 1000000` with package.json/yarn.lock; copies bin/shakapacker, config/webpack, config/shakapacker.yml, postcss and four tailwind configs, app/javascript, app/views; `echo "gem 'shakapacker'" > Gemfile && ./bin/shakapacker`.
- Stage 3 `app`: `FROM ruby:4.0.10-alpine AS app`; ENV RAILS_ENV=production, BUNDLE_WITHOUT="development:test", OPENSSL_CONF=/etc/openssl_legacy.cnf.
  - `apk upgrade --no-cache ca-certificates-bundle`; `apk add --no-cache libpq vips redis onnxruntime leptonica jemalloc font-liberation font-carlito`; deletes /usr/bin/onnx_test_runner and /usr/bin/onnxruntime_test.
  - Group/user `docuseal` uid/gid 2000, home /home/docuseal, shell /bin/sh. No USER instruction (process runs as root).
  - /etc/openssl_legacy.cnf: includes /etc/ssl/openssl.cnf, activates default and legacy providers.
  - Gem install: temp `apk add build-base git libpq-dev yaml-dev`, `bundle install`, then `apk del` of those; cleanup of spec/doc/test/example/C-source dirs; symlink `/usr/lib/libonnxruntime.so.1` over the onnxruntime gem's vendored .so.
  - COPY (chown docuseal): bin, app, config, db/migrate, log, lib, public, tmp; LICENSE LICENSE_ADDITIONAL_TERMS README.md Rakefile config.ru .version; `.version` also to `./public/version`.
  - From download stage: fonts to /fonts/; `libpdfium.so` to /usr/lib/libpdfium.so; licenses to /usr/lib/libpdfium-licenses/; model to /app/tmp/model.onnx.
  - From webpack stage: /app/public/packs to ./public/packs.
  - Font links into /app/public/fonts and /usr/share/fonts/noto/ (bold/), `fc-cache -f`, `bundle exec bootsnap precompile -j 1 --gemfile app/ lib/`, `chown -R docuseal:docuseal /app/tmp/cache`.
- WORKDIR `/data/docuseal`. ENV HOME=/home/docuseal, WORKDIR=/data/docuseal, VIPS_MAX_COORD=17000, VIPS_BLOCK_UNTRUSTED=1, MALLOC_CONF=dirty_decay_ms:1000,narenas:2,background_thread:true; LD_PRELOAD jemalloc line commented out.
- `EXPOSE 3000`. `CMD ["/app/bin/bundle", "exec", "puma", "-C", "/app/config/puma.rb", "--dir", "/app"]`.
- No ARG, USER, VOLUME or ENTRYPOINT in either Dockerfile.

## Runtime deps
- libpq, vips, redis (apk), onnxruntime, leptonica, jemalloc, font-liberation, font-carlito, pdfium (musl build, from upstream pdfium-binaries).
- Database: SQLite by default; PostgreSQL or MySQL via DATABASE_URL.

## Binaries/entrypoint/CLI flags
- CMD above (Puma). No ENTRYPOINT.

## Env vars
| Name | Default | Notes |
| --- | --- | --- |
| DATABASE_URL | unset | README: selects PostgreSQL or MySQL. Unset = SQLite. |
| HOST | (none) | Compose example only: custom domain; Caddy issues SSL when DNS points to server. |
| RAILS_ENV | production | Dockerfile ENV. |
| WORKDIR | /data/docuseal | Dockerfile ENV. |
| BUNDLE_WITHOUT | development:test | Dockerfile ENV. |
| OPENSSL_CONF | /etc/openssl_legacy.cnf | Dockerfile ENV. |
| VIPS_MAX_COORD | 17000 | Dockerfile ENV. |
| VIPS_BLOCK_UNTRUSTED | 1 | Dockerfile ENV. |
| MALLOC_CONF | dirty_decay_ms:1000,narenas:2,background_thread:true | Dockerfile ENV. |
| HOME | /home/docuseal | Dockerfile ENV. |

- SECRET_KEY_BASE is not mentioned by any fetched source.

## Ports
- 3000/tcp (EXPOSE 3000). Docker run example maps 3000:3000.

## Volumes/paths and persistent data
- Docker README run: `-v.:/data` (current dir at /data). Dockerfile WORKDIR is /data/docuseal.
- Writable paths in the image: /app/tmp, /app/tmp/cache (chowned), /app/log (chown via COPY), /data/docuseal.
- Model at /app/tmp/model.onnx (copied in).

## User/UID & permissions
- Group/user docuseal uid/gid 2000 created; no USER, so the image runs as root. Compose/chart (TrueCharts) also runs root.

## Config files and formats
- /etc/openssl_legacy.cnf (generated at build). /app/config/puma.rb (Puma config).

## Healthcheck/readiness endpoints
- None documented in any fetched source. TrueCharts probes `/` (HTTP).

## Version/release info and asset naming
- 3.4.0: latest, released 23 Nov (year not shown), commit 15b6e77 (signed). Release note: "Bug fixes and security hardening." Release page says 2 assets; names did not load.
- 3.3.8: security release 19 Nov, commit a628dd3. Bumps Ruby to 4.0.10 (fixes memory management vulnerabilities; advisory GHSA-78g6-f52x-q3jx). Release page says 2 assets; names did not load.
- Asset naming: none known. Source tarball pattern `https://github.com/docusealco/docuseal/archive/refs/tags/<ver>.tar.gz` (not downloaded). Tags have no v prefix.
- Pinned third-party artifacts: fields-detection model 2.0.0, pdfium-binaries 20260920, go-noto-universal v7.0.

## Arch support
- Dockerfile handles x86_64 and aarch64 for pdfium checksums (case block); other arches not handled for pdfium.

## Gotchas
- Pdfium is musl-linked (`pdfium-musl-*`); glibc Ubuntu target needs a different build.
- Fonts and the ONNX model are downloaded without checksum verification.
- The 3.3.8 Dockerfile was fetched from the draft commit; the 3.4.0 Dockerfile is now also fetched (same structure, ruby 4.0.10).
