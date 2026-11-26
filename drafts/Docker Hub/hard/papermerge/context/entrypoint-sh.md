# docker/standard/entrypoint.sh (papermerge-core @ 831c2e355cf5c841c4587fea19d89e9b46a92b79)

Source URL: https://raw.githubusercontent.com/papermerge/papermerge-core/831c2e355cf5c841c4587fea19d89e9b46a92b79/docker/standard/entrypoint.sh (fetched)

## Commands (first arg = CMD)
| Arg | Behaviour |
| --- | --- |
| (empty) | prints error, exit 1 |
| server | full init (migrate, perms sync, system user, standard roles, superuser); renders core.js.tmpl to auth_server and ui html dirs; sed-patches ui index.html; exec supervisord -c /core_app/supervisord.conf |
| server_without_init | like server, skips init and auth_server config; exec supervisord |
| init | init sequence only |
| migrate | migration only |
| createsuperuser | superuser only |
| create_token.sh / list_users.sh | exec the script with the next arg |
| other | exec given args |

## Init steps
- (/core_app) `uv run task migrate`
- `uv run pm perms sync`
- `uv run pm users create-system-user`
- `uv run pm roles create-standard-roles`
- (/auth_server_app) `uv run auth-cli users create --superuser`

## Env vars
| Var | Default | Purpose |
| --- | --- | --- |
| PM_SECRET_KEY | random 64-char (base64 stripped) if unset | secret key; warning printed |
| PM_USERNAME | admin | superuser name |
| PM_EMAIL | admin@example.com | superuser email |
| NODE_NAME | unset | if set, k8s mode: sets PAPERMERGE__MAIN__S3_QUEUE_NAME = s3_${PAPERMERGE__MAIN__PREFIX}_${NODE_NAME} and PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME = s3preview_... if unset |

## Directories / files written
- Writes papermerge-runtime-config.js into /usr/share/nginx/html/auth_server/ and /usr/share/nginx/html/ui/
- Edits /usr/share/nginx/html/ui/index.html in place
- Creates/chowns no directories

## Gotchas
- Shebang /bin/sh but uses bashisms ([[ ]]).
- Unquoted `[ -z $CMD ]`.
