# GitHub: TriliumNext/Trilium apps/server/src/services/config.ts (tag v0.107.0)

Source URL(s): https://raw.githubusercontent.com/TriliumNext/Trilium/v0.107.0/apps/server/src/services/config.ts (fetched 2026-11-27)

## Config precedence (per file header)
1. Environment variables `TRILIUM_[SECTION]_[KEY]` (highest)
2. config.ini (user config, copied from sample on first run)
3. Hardcoded defaults

## Key env vars (names found in source)
| var | default (source) |
| --- | --- |
| TRILIUM_NETWORK_HOST | 0.0.0.0 |
| TRILIUM_NETWORK_PORT | 8080 (DEFAULT_NETWORK_PORT) |
| TRILIUM_NETWORK_HTTPS | false |
| TRILIUM_NETWORK_CERTPATH / KEYPATH | "" (required when https=true) |
| TRILIUM_NETWORK_TRUSTEDREVERSEPROXY | false |
| TRILIUM_NETWORK_CORS_ALLOW_ORIGIN, _METHODS, _HEADERS | "" |
| TRILIUM_NETWORK_CORS_RESOURCE_POLICY | same-origin |
| TRILIUM_GENERAL_NOAUTHENTICATION | false |
| TRILIUM_GENERAL_READONLY | false |
| TRILIUM_GENERAL_NOBACKUP | false |
| TRILIUM_GENERAL_NODESKTOPICON | false |
| TRILIUM_GENERAL_INSTANCENAME | "" |
| TRILIUM_LOGGING_RETENTION_DAYS | 90 |
| TRILIUM_OAUTH_* (BASE_URL, CLIENT_ID, CLIENT_SECRET, CLIENT_AUTH_METHOD, ISSUER_BASE_URL, ISSUER_NAME default "Google", ISSUER_ICON, SCOPE default "openid profile email", HTTP_TIMEOUT 30000, ID_TOKEN_SIGNING_ALG) | see source; ISSUER_BASE_URL default https://accounts.google.com |
| TRILIUM_MULTIFACTORAUTHENTICATION_OAUTH* | alias group of the above |

- Session cookie max age default: 21 days (1814400 s).
- Backend script execution default: false on server builds.

## Notes
- Source has both underscore and no-underscore forms for some keys (e.g. CORS_ALLOW_ORIGIN and CORSALLOWORIGIN).
