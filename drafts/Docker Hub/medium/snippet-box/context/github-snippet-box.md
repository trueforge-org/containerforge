# GitHub pawelmalak/snippet-box (Dockerfile at f501941a, repo metadata)

Source URL(s) + date:
- https://raw.githubusercontent.com/pawelmalak/snippet-box/f501941a22ead0fccd196d109098e9b065205d98/Dockerfile
- https://api.github.com/repos/pawelmalak/snippet-box
- Fetched 2026-11-27

## Repo metadata (GitHub API)
- full_name `pawelmalak/snippet-box`, license SPDX `MIT`, default branch `master`, pushed 2023-04-05

## Dockerfile (f501941a)
```
FROM node:14-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN mkdir -p ./public ./data && cd client && npm install && npm rebuild node-sass
RUN npm run build && mv ./client/build/* ./public
RUN rm -rf src/ ./client && npm prune --production
EXPOSE 5000
ENV NODE_ENV=production
CMD ["node", "build/server.js"]
```
- Base `node:14-alpine` (Node 14, EOL).
- Native modules: `node-sass` (client rebuild), sqlite3 via server deps.
- Runs as root (no USER). No HEALTHCHECK.
- Creates `./data` at build time (`/app/data`).

## Releases / tags
- `/repos/pawelmalak/snippet-box/releases/latest`: HTTP 404 ("Not Found"), so no GitHub releases.
- `/repos/pawelmalak/snippet-box/tags`: HTTP 403 (API rate limit). Not retried. Tags unknown.

## Gotchas
- Repo last push 2023-04-05; upstream base is EOL Node 14.
