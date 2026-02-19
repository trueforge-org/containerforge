# ldap-auth: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Package libldap-2.4-2 is not available, but is referred to by another package.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-ldap-auth:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&     apt-get update &&     apt-get install -y --no-install-recommends         build-essential         libldap2-dev         python3-dev         libffi-dev &&     echo \"**** install runtime packages ****\" &&     apt-get install -y --no-install-recommends         libldap2         libffi8         python3 &&     python3 -m venv /app/venv &&     /app/venv/bin/pip install -U --no-cache-dir         pip         wheel &&     /app/venv/bin/pip install -U --no-cache-dir         cryptography         legacy-cgi         python-ldap==\"${VERSION}\" &&     echo \"**** cleanup ****\" &&     apt-get remove -y --purge         build-essential         libldap2-dev         python3-dev         libffi-dev &&     apt-get autoremove -y &&     apt-get clean &&     rm -rf         /var/lib/apt/lists/*         /tmp/*         $HOME/.cache" did not complete successfully: exit code: 1
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 failing-unattempted batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after adding SASL development/runtime packages and python3-venv setup.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 failing-unattempted follow-up batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after adding libsasl2 build/runtime dependencies and ensuring python3-venv setup.
- Full log: `amd64-build.log`
