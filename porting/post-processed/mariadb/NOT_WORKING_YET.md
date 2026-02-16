# mariadb: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Canonical container already exists in `/apps/mariadb`; this porting copy is kept only as a post-processing artifact.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.
