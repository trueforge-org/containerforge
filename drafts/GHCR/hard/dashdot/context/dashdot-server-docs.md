# dashdot server configuration docs (v6.3.4)

Source URL: https://raw.githubusercontent.com/MauriceNino/dashdot/v6.3.4/apps/docs/content/docs/configuration/server.mdx (fetched 2026-11-27)
Related: https://getdashdot.com/docs (JS-rendered shell, no usable text; not summarized)

## What it is
Docs page for dashdot "Server" widget options. Partial list only; see upstream config for the full env set.

## Options (env vars)
| Env | Type | Default | Notes |
| --- | --- | --- | --- |
| DASHDOT_OS_LABEL_LIST | comma list | `os,arch,up_since` | options: os, arch, up_since, dash_version |
| DASHDOT_SHOW_HOST | bool | `false` | shows host part, e.g. dash. -> dash.mauz.dev |
| DASHDOT_CUSTOM_HOST | string | unset | needs DASHDOT_SHOW_HOST=true |
| DASHDOT_OS_WIDGET_GROW | number | `2.5` | style |
| DASHDOT_OS_WIDGET_MIN_WIDTH | number (px) | `300` | style |
| DASHDOT_OVERRIDE_OS | string | unset | override |
| DASHDOT_OVERRIDE_ARCH | string | unset | override |

## Gotchas
- Docs only cover the server widget; other widget env vars are in config source (not fetched here).
