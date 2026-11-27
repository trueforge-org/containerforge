
# Build stage: compile YACReaderLibraryServer from the upstream source tag on the glibc ubuntu base.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG DECOMPRESSION_BACKEND=libarchive
ARG PDF_BACKEND=poppler
USER root

# UNVERIFIED: the Qt6 and CMake package set comes from the upstream wrapper (ubuntu resolute). Confirm it on the trueforge 26.04 base and pin versions.
RUN echo "*** Installing build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libarchive-dev \
    libgl-dev \
    libpoppler-qt6-dev \
    ninja-build \
    qt6-5compat-dev \
    qt6-base-dev \
    qt6-base-dev-tools \
    qt6-l10n-tools \
    qt6-tools-dev \
    qt6-tools-dev-tools && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Cloning YACReader ${VERSION} ***" && \
  git clone --depth 1 --branch "${VERSION}" https://github.com/YACReader/yacreader.git /src

# libarchive is used for decompression, so no third-party 7z tarball is fetched.
# Use the 7zip backend only if RAR5 support is needed, and then verify its sha256 as the upstream wrapper does.
RUN echo "*** Building YACReaderLibraryServer ***" && \
  cmake -S /src -B /src/build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/app \
    -DBUILD_SERVER_STANDALONE=ON \
    -DBUILD_TESTS=OFF \
    -DDECOMPRESSION_BACKEND="${DECOMPRESSION_BACKEND}" \
    -DPDF_BACKEND="${PDF_BACKEND}" && \
  cmake --build /src/build --parallel && \
  cmake --install /src/build

# Record the packages that provide the shared libraries the server links against, for the runtime stage.
RUN ldd /app/bin/YACReaderLibraryServer | awk '/=>/ {print $3}' | sort -u | xargs -r dpkg -S 2>/dev/null | cut -d: -f1 | sort -u > /runtime-packages.txt

# UNVERIFIED: the license file name at the tag.
RUN install -Dm644 /src/LICENSE /usr/share/licenses/yacreaderlibraryserver/LICENSE

# Runtime stage: the server and its runtime libraries only. No s6 and no build tools.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

COPY --from=build /runtime-packages.txt /tmp/runtime-packages.txt
COPY --from=build /app /app
COPY --from=build /usr/share/licenses/yacreaderlibraryserver /usr/share/licenses/yacreaderlibraryserver

# UNVERIFIED: the Qt plugin package names on ubuntu 26.04 (from the upstream wrapper).
RUN echo "*** Installing runtime libraries ***" && \
  apt-get update && \
  xargs -a /tmp/runtime-packages.txt apt-get install -y --no-install-recommends \
    kimageformat6-plugins \
    libqt6sql6-sqlite \
    qt6-image-formats-plugins && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/runtime-packages.txt

# UNVERIFIED: C.UTF-8 instead of the upstream en_US.UTF-8. Keep it only if the server runs with C.UTF-8.
ENV \
  HOME=/config \
  LC_ALL=C.UTF-8 \
  PATH=/app/bin:${PATH}

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
VOLUME /comics
