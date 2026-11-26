# outline/outline repository README (main)

Source URL: https://raw.githubusercontent.com/outline/outline/main/README.md (fetched)

- What: team knowledge base / wiki; React + Node.js + TypeScript; styled-components; Vitest; Sequelize migrations; Crowdin i18n.
- License: BSL 1.1 (per LICENSE file).
- Hosted version at getoutline.com; self-host docs at docs.getoutline.com/s/hosting/.
- Images published to Docker Hub as `outlinewiki/outline` (release + nightly).
- Node version: not stated in README.
- Postgres: not named in README (Sequelize migrations; `make test` creates test DB).
- Redis: not mentioned in README.
- Dev commands: `make test`, `make watch`, `yarn test:server`, `yarn test:app`, `yarn db:migrate`, `yarn db:rollback`, `yarn db:create-migration --name X`.
- Debug: DEBUG=http, DEBUG=*, LOG_LEVEL=debug|silly.
