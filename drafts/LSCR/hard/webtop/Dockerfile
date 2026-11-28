# UNVERIFIED: the plan cited ubuntu digest f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a...; the repo's ubuntu:26.04 siblings use f01a4295... (used here).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# BLOCKED: the desktop variant is not chosen yet (plan section 10). No desktop packages
# are installed here. Add the chosen variant's apt packages in a RUN, pinned where practical.
# No snap browser (snap does not run in the container).

ENV HOME=/config \
    TITLE="Ubuntu i3"

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 3000
VOLUME /config
