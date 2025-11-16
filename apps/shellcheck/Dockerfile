############## build stage ##############
FROM ghcr.io/trueforge-org/ubuntu:24.4 as buildstage


USER root

# build environment settings

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
FROM ghcr.io/trueforge-org/ubuntu:24.4

# copy files from build stage
COPY --from=buildstage /tmp/shellcheck/shellcheck /usr/local/bin/
