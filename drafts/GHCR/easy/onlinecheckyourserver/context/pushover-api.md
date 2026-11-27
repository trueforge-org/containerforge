# Pushover messages API

Source URL(s) + date: https://pushover.net/api (alternative for https://api.pushover.net/1/messages.json, which returned 400 to GET) (fetched 2026-11-27)

## Endpoint
- https://api.pushover.net/1/messages.json, HTTPS only, POST only (GET not accepted).
- Input: form-encoded, multipart/form-data, or application/json. XML reply via .xml suffix.

## Required params
| Param | Notes |
| --- | --- |
| token | application API token, 30 chars |
| user | user or group key, 30 chars; up to 50 comma-separated, no spaces |
| message | body, max 1024 UTF-8 chars |

## Optional params
- title (default app name, max 250), device (max 25 each), priority (-2 none, -1 quiet, 0 default, 1 bypass quiet hours, 2 emergency), retry (min 30, required with priority 2), expire (max 10800, required with priority 2), callback, tags, html (1), monospace (1), timestamp, ttl, url (max 512), url_title (max 100), sound, attachment (max 5 MiB), attachment_base64, attachment_type, encrypted (1).

## Response
- Success HTTP 200, status 1, request id. Failure HTTP 4xx, status not 1, errors array. Over quota HTTP 429.

## Limits
- Free 10,000 msgs/month per account; Teams 25,000. Max 2 concurrent connections. On 5xx retry no sooner than 5 s. Do not retry 4xx unchanged.
