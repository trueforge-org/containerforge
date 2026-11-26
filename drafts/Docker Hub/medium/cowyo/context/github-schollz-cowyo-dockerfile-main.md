# schollz/cowyo Dockerfile (main branch)

Source: https://raw.githubusercontent.com/schollz/cowyo/main/Dockerfile (fetched 2026-11-26)

- Fetch returned content identical in structure to commit 77f28842 (see github-schollz-cowyo-dockerfile-77f2884.md):
  - frontend `node:24-alpine` (npm ci, npm run build); backend `golang:1.26.5-alpine`; final `alpine:3.23`
  - build output `/out/cowyo` from `./cmd/cowyo`; SQLITE_PATH=/data/cowyo2.sqlite3; USER cowyo; EXPOSE 8001; CMD /usr/local/bin/cowyo
- CONFLICT: plan.md states main uses `go build ... -o /out/cowyo2 .` and `CMD /usr/local/bin/cowyo2`. Not confirmed by this fetch. Unverified; plan not edited.
