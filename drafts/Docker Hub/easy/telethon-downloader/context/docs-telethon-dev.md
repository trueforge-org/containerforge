# docs.telethon.dev (Telethon library docs)

**Source URL(s) + fetch date**
- https://docs.telethon.dev (fetched 2026-11-26; the page only partly loaded)

**What it is**
Telethon is a Python library for the Telegram client API. The landing page gives an example that uses `TelegramClient('name', api_id, api_hash)` with `client.run_until_disconnected()`.

**Install/build steps**
Not on the fetched page (it links to an Installation page that was not followed). pip package name not confirmed here; the upstream requirements.txt lists `telethon`.

**Runtime deps**
Python only.

**Gotchas**
- The page does not cover bot login (`bot_token`). The upstream app logs in with `TelegramClient('bot', ...)` and `bot.start(bot_token=...)` (see GitHub file).
- Supported Python versions: not stated on the fetched page.
