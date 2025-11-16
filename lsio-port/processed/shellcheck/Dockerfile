############## build stage ##############
FROM ubuntu as buildstage

# set version label
ARG VERSION

# build environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y \
        cabal-install \
        curl \
        ghc \
        git && \
    echo "**** compile shellcheck ****" && \
    git clone https://github.com/koalaman/shellcheck /tmp/shellcheck && \
    cd /tmp/shellcheck && \
    cabal update && \
    cabal install --dependencies-only && \
    cabal build Paths_ShellCheck && \
    ghc \
        -idist/build/autogen \
        -isrc \
        -optl-pthread \
        -optl-static \
        --make \
        shellcheck && \
    strip --strip-all shellcheck

############## runtime stage ##############
FROM scratch
ADD rootfs.tar.xz /

# set version label
ARG VERSION

# copy files from build stage
COPY --from=buildstage /tmp/shellcheck/shellcheck /usr/local/bin/
