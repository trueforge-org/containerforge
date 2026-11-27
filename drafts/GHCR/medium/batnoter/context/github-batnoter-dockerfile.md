# Upstream Dockerfile and nginx config: batnoter/batnoter

**Source URL(s):** https://raw.githubusercontent.com/batnoter/batnoter/8722c3af2b81233f158ca17e4818b9251c8cc1d3/Dockerfile (blob URL in urls.txt is the same file); https://raw.githubusercontent.com/batnoter/batnoter/8722c3af2b81233f158ca17e4818b9251c8cc1d3/nginx/default.conf (fetched 2026-11-27)

## Stages
1. **build**: `FROM node:16-alpine`, `WORKDIR /app`, `COPY . .`, `RUN npm i`, `RUN npm run build`.
2. **final**: `FROM nginx:stable-alpine`, `EXPOSE 3000`.
   - `COPY --from=build /app/build /usr/share/nginx/html`
   - `COPY --from=build /app/nginx/default.conf /etc/nginx/conf.d/default.conf`

## nginx/default.conf (upstream)
```
server {
  listen 3000;
  location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
    try_files $uri $uri/ /index.html;
  }
}
```

## Entrypoint/flags
- None set in Dockerfile (inherits nginx base entrypoint/CMD).

## Env vars
- None.

## Ports
- 3000 (listen and EXPOSE)

## Volumes/paths
- Static UI: `/usr/share/nginx/html`. Config: `/etc/nginx/conf.d/default.conf`.

## User/UID
- None set (nginx base default).

## Arch
- No arch conditionals. Alpine (musl) base images.

## Gotchas
- App is a frontend-only React build; no backend in this repo (BatNoter API is a separate repo).
- Upstream uses `npm i` (no lockfile pin in Dockerfile).
