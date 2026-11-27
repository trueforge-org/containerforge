# alexta69/metube README + pyproject.toml (master)

Source URL(s) + date:
- https://raw.githubusercontent.com/alexta69/metube/master/README.md (2026-11-27; configuration sections)
- https://raw.githubusercontent.com/alexta69/metube/master/pyproject.toml (2026-11-27)

## pyproject
- name metube, version 0.1.0 (not the release tag), requires-python >=3.13.
- deps: aiohttp, python-socketio>=5.0,<6.0, yt-dlp[default,curl-cffi,deno], watchfiles.
- dev group: pylint, pytest>=8, pytest-aiohttp, pytest-asyncio. pytest testpaths app/tests.

## Env vars (README tables)
| var | default | note |
| --- | --- | --- |
| PUID / PGID | 1000 | legacy UID/GID also accepted |
| UMASK | 022 | |
| CHOWN_DIRS | true | |
| LOGLEVEL | INFO | |
| ENABLE_ACCESSLOG | false | |
| DEFAULT_THEME | auto | light, dark, auto |
| MAX_CONCURRENT_DOWNLOADS | 3 | |
| DEFAULT_OPTION_PLAYLIST_ITEM_LIMIT | 0 | |
| CLEAR_COMPLETED_AFTER | 0 | seconds |
| DELETE_FILE_ON_TRASHCAN | false | also accepts `ask` |
| SUBSCRIPTION_DEFAULT_CHECK_INTERVAL | 60 | minutes |
| SUBSCRIPTION_SCAN_PLAYLIST_END | 50 | |
| SUBSCRIPTION_MAX_SEEN_IDS | 50000 | |
| DOWNLOAD_DIR | /downloads | |
| AUDIO_DOWNLOAD_DIR | same as DOWNLOAD_DIR | |
| TEMP_DIR | /downloads | |
| STATE_DIR | /downloads/.metube | queue, history, subscriptions, cookies |
| CUSTOM_DIRS | true | |
| CREATE_CUSTOM_DIRS | true | |
| CUSTOM_DIRS_EXCLUDE_REGEX | (^\|/)[.@].*$ | |
| DEFAULT_FOLDER | (empty) | requires CUSTOM_DIRS |
| DOWNLOAD_DIRS_INDEXABLE | false | |
| OUTPUT_TEMPLATE | %(title)s.%(ext)s | |
| OUTPUT_TEMPLATE_PLAYLIST | %(playlist_title)s/%(title)s.%(ext)s | |
| OUTPUT_TEMPLATE_CHANNEL | %(channel)s/%(title)s.%(ext)s | |
| OUTPUT_TEMPLATE_CHAPTER | %(title)s - %(section_number)02d - %(section_title)s.%(ext)s | |
| YTDL_OPTIONS | {} | JSON object |
| YTDL_OPTIONS_FILE | (empty) | reloaded on change |
| YTDL_OPTIONS_PRESETS | {} | |
| YTDL_OPTIONS_PRESETS_FILE | (empty) | |
| ALLOW_YTDL_OPTIONS_OVERRIDES | false | allows command execution in container |
| YTDL_NIGHTLY_UPDATE_TIME | (empty) | HH:MM |
| HOST | 0.0.0.0 | |
| PORT | 8081 | |
| URL_PREFIX | / | |
| HTTPS | false | uses CERTFILE and KEYFILE |
| CERTFILE / KEYFILE | (empty) | |
| PUBLIC_HOST_URL | download/ | |
| PUBLIC_HOST_AUDIO_URL | audio_download/ | |
| CORS_ALLOWED_ORIGINS | (empty) | comma separated |
| ALLOW_PRIVATE_ADDRESSES | false | disables SSRF protection |
| ROBOTS_TXT | (empty) | path to file |

## Gotchas
- Only the README configuration sections were read; the remaining README was not summarised.
