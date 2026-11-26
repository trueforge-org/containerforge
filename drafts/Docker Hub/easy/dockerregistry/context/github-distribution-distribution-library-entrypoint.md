# distribution/distribution-library-image entrypoint.sh (commit 775973b)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/distribution/distribution-library-image/775973b655bb4b11561db92a1cf50113148ce530/entrypoint.sh · 2026-11-26

## Script
```
#!/bin/sh
set -e
case "$1" in
    *.yaml|*.yml) set -- registry serve "$@" ;;
    serve|garbage-collect|help|-*) set -- registry "$@" ;;
esac
exec "$@"
```

## Behaviour
- `*.yaml`/`*.yml` first arg -> `registry serve <args>`.
- `serve`, `garbage-collect`, `help`, or first arg starting with `-` -> `registry <args>`.
- Otherwise args unchanged. Always `exec`.
- Matches plan.md section 1 description.
