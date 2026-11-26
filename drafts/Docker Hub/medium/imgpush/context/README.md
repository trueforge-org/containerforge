# Context: imgpush

| Source URL | File |
| --- | --- |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/imgpush | truecharts-imgpush.md |
| https://hub.docker.com/r/hauxir/imgpush | dockerhub-imgpush.md |
| https://github.com/hauxir/imgpush | github-hauxir-imgpush-readme.md |
| https://github.com/hauxir/imgpush/blob/9a44956/Dockerfile | github-hauxir-imgpush-dockerfile.md |
| (nginx.conf, app/entrypoint.sh: referenced by Dockerfile and app; not in urls.txt) | github-hauxir-imgpush-nginx.md, github-hauxir-imgpush-entrypoint.md |
| http://unix:/tmp/imgpush.sock | imgpush-socket-url.md (not a web source; not fetched) |

Skipped: none beyond the above.
Failures: none.

## plan.md corrections
None. The /tmp socket in plan.md is the plan's own rootless design; upstream socket is /app/imgpush.sock, which plan.md already notes.
