# Build stage: compile the static site with node from the python-node base
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION

USER root
WORKDIR /app

ENV HOME=/tmp \
    NPM_CONFIG_CACHE=/tmp/npm

# VERSION is a commit SHA of ASKJR/quiz-game (the repo has no releases or tags)
# UNVERIFIED: node in python-node may differ from the upstream node 12. If npm fails, check package.json engines. Do not pin an EOL node.
RUN set -eux; \
    curl -fsSL "https://github.com/ASKJR/quiz-game/archive/${VERSION}.tar.gz" | tar -xz -C /app --strip-components=1; \
    npm ci --no-audit --no-fund; \
    npm run build

# Final stage: static files served by the ContainerForge nginx base
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

USER root
WORKDIR /app

COPY --from=build /app/dist /app/www
RUN chmod -R go=rX /app/www

# Replaces the base default site. The base entrypoint copies it to /config/sites/default.conf with cp -n.
COPY --chmod=0755 . /

USER apps

EXPOSE 8080
VOLUME /config
