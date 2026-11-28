# UNVERIFIED throughout: upstream builds on ruby:4.0.10-alpine. Ubuntu packages for ruby, nodejs, yarnpkg,
# libonnxruntime and the pdfium library, plus the pdfium musl-vs-glibc question, must be checked on the first build.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS download

ARG TARGETARCH
USER root

RUN echo "*** Downloading fonts, model and pdfium ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl unzip && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /out/fonts /out/licenses && \
  curl -fsSL -o /out/fonts/GoNotoKurrent-Regular.ttf "https://github.com/satbyy/go-noto-universal/releases/download/v7.0/GoNotoKurrent-Regular.ttf" && \
  curl -fsSL -o /out/fonts/GoNotoKurrent-Bold.ttf "https://github.com/satbyy/go-noto-universal/releases/download/v7.0/GoNotoKurrent-Bold.ttf" && \
  curl -fsSL -o /out/fonts/DancingScript-Regular.otf "https://github.com/impallari/DancingScript/raw/master/fonts/DancingScript-Regular.otf" && \
  curl -fsSL -o /out/licenses/DancingScript-OFL.txt "https://raw.githubusercontent.com/impallari/DancingScript/master/OFL.txt" && \
  curl -fsSL -o /out/licenses/noto-fonts-LICENSE.txt "https://raw.githubusercontent.com/notofonts/noto-fonts/refs/heads/main/LICENSE" && \
  curl -fsSL -o /out/model.onnx "https://github.com/docusealco/fields-detection/releases/download/2.0.0/model_704_int8.onnx"

# Upstream pins only the musl build of pdfium (checksums from upstream). A glibc build is still to be found (UNVERIFIED).
RUN echo "*** Installing pdfium ***" && \
  case "${TARGETARCH}" in \
    amd64) PDFIUM_ARCH=x86_64; PDFIUM_SHA256=bbca8a648dbd1ba81f9c6c223f21dc394cf1ad381c6c17d60c6dcc4a7d3a2ae0 ;; \
    arm64) PDFIUM_ARCH=aarch64; PDFIUM_SHA256=73b72ed79b9bfdd494dee7e863482c24971a8d4b11f6cd1289aa170d31304a1f ;; \
    *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/pdfium.zip "https://github.com/docusealco/pdfium-binaries/releases/download/20260920/pdfium-musl-${PDFIUM_ARCH}.zip" && \
  echo "${PDFIUM_SHA256}  /tmp/pdfium.zip" | sha256sum -c - && \
  unzip -q /tmp/pdfium.zip -d /tmp/pdfium && \
  find /tmp/pdfium -name 'libpdfium.so' -exec install -m 0644 {} /out/libpdfium.so \; && \
  find /tmp/pdfium -iname 'LICENSE*' -exec install -m 0644 {} /out/licenses/ \; && \
  rm -rf /tmp/pdfium /tmp/pdfium.zip

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
USER root

ENV \
  RAILS_ENV=production \
  NODE_ENV=production \
  BUNDLE_WITHOUT=development:test \
  BUNDLE_PATH=/app/vendor/bundle \
  BUNDLE_APP_CONFIG=/tmp/bundle

RUN echo "*** Installing build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libpq-dev \
    libvips-dev \
    libyaml-dev \
    nodejs \
    ruby \
    ruby-dev \
    yarnpkg && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Fetching DocuSeal ${VERSION} source ***" && \
  mkdir -p /app && \
  curl -fsSL -o /tmp/docuseal.tar.gz "https://github.com/docusealco/docuseal/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/docuseal.tar.gz -C /app --strip-components=1 && \
  rm /tmp/docuseal.tar.gz

RUN echo "*** Installing gems and building assets ***" && \
  cd /app && \
  gem install --no-document bundler && \
  bundle install --jobs 4 --retry 3 && \
  yarnpkg install --network-timeout 1000000 && \
  bundle exec bin/shakapacker && \
  rm -rf /tmp/bundle /usr/local/share/.cache /root/.cache

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

ENV \
  RAILS_ENV=production \
  RAILS_LOG_TO_STDOUT=true \
  HOME=/config \
  WORKDIR=/config/data \
  TMPDIR=/tmp \
  BUNDLE_WITHOUT=development:test \
  BUNDLE_PATH=/app/vendor/bundle \
  BUNDLE_APP_CONFIG=/tmp/bundle \
  BOOTSNAP_CACHE_DIR=/tmp/bootsnap \
  OPENSSL_CONF=/etc/openssl_legacy.cnf \
  VIPS_MAX_COORD=17000 \
  VIPS_BLOCK_UNTRUSTED=1 \
  MALLOC_CONF=dirty_decay_ms:1000,narenas:2,background_thread:true

# UNVERIFIED: runtime packages. onnxruntime (libonnxruntime.so.1) is not packaged here yet and must be provided before the app can run.
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    fontconfig \
    fonts-crosextra-carlito \
    fonts-liberation \
    libjemalloc2 \
    libleptonica6 \
    libpq5 \
    libvips42t64 \
    libyaml-0-2 \
    ruby && \
  rm -rf /var/lib/apt/lists/*

# Upstream expects the legacy OpenSSL providers; content is from upstream's Alpine setup and UNVERIFIED for Ubuntu.
RUN printf '%s\n' \
    'openssl_conf = openssl_init' \
    '.include /etc/ssl/openssl.cnf' \
    '[openssl_init]' \
    'providers = provider_sect' \
    '[provider_sect]' \
    'default = default_sect' \
    'legacy = legacy_sect' \
    '[default_sect]' \
    'activate = 1' \
    '[legacy_sect]' \
    'activate = 1' > /etc/openssl_legacy.cnf

COPY --from=build /app /app
COPY --from=download /out/libpdfium.so /usr/lib/libpdfium.so
COPY --from=download /out/fonts/ /usr/share/fonts/docuseal/
COPY --from=download /out/model.onnx /usr/share/docuseal/model.onnx

# /app/tmp and /app/log are read-only at runtime; point them at /tmp (created by start.sh).
# UNVERIFIED: the model path /usr/share/docuseal/model.onnx must be wired to the app's configured model path.
COPY --from=download /out/licenses/ /usr/share/licenses/docuseal/
RUN echo "*** Finalising image ***" && \
  cp /app/LICENSE /app/LICENSE_ADDITIONAL_TERMS /usr/share/licenses/docuseal/ && \
  rm -rf /app/tmp /app/log && \
  ln -s /tmp/app-tmp /app/tmp && \
  ln -s /tmp/app-log /app/log && \
  fc-cache -f && \
  chown -R root:root /app && chmod -R a+rX /app

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
WORKDIR /app
