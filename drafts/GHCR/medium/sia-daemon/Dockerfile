FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS buildstage

# build variables
ARG VERSION
USER root

# UNVERIFIED: which of these the base already has; drop duplicates after the first build
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    golang-go \
    make

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/siad && \
  curl -fL -o /tmp/siad-src.tar.gz \
    "https://github.com/SiaFoundation/siad/archive/${VERSION}.tar.gz" && \
  tar xf /tmp/siad-src.tar.gz -C /tmp/siad --strip-components=1

RUN \
  echo "**** compile siad ****" && \
  cd /tmp/siad && \
  # UNVERIFIED: upstream runs git status so the Makefile sees a clean tree; the tarball has no .git, so commit once here
  git init -q && \
  git add -A && \
  git -c user.name=build -c user.email=build@localhost commit -qm "source ${VERSION}" && \
  GOCACHE=/tmp/go-build GOPATH=/tmp/go GOFLAGS=-mod=mod make static && \
  mkdir -p /app/siad && \
  cp /tmp/siad/release/siad /app/siad/siad && \
  install -D -m 0644 /tmp/siad/LICENSE /usr/share/licenses/sia-daemon/LICENSE

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

COPY --from=buildstage /app/siad/ /app/siad/
COPY --from=buildstage /usr/share/licenses/sia-daemon/ /usr/share/licenses/sia-daemon/

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 9980 9981 9982 9983

WORKDIR /config
VOLUME /config
