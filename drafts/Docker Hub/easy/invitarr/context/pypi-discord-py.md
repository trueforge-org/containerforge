# discord.py (PyPI)

Source URL(s) + fetch date:
- https://pypi.org/project/discord.py/
- Fetched 2026-11-26

## Version
- Latest: discord.py 2.7.1, released Mar 3, 2026. Previous: 2.7.0 on Feb 27, 2026.
- Requires-Python: `>=3.8`. Classifiers list 3.8 through 3.12.

## Dependencies
- Core runtime deps not listed on the page. Optional: PyNaCl (voice). Extras: `voice`, `docs`, `speed`, `test`, `dev`. On Linux, voice also needs system packages `libffi-dev` and `python-dev`.

## 2.x notes shown
- Intents: `discord.Intents.default()` passed to client/bot constructor.
- `intents.message_content = True` is set in both examples (needed for prefix commands / on_message).
- Async/await API. No migration guide on the page; migration (including `add_cog` awaits) not covered here.
- Virtualenv recommended.

## Relevance
Upstream Invitarr code targets discord.py 1.x (per plan). This page does not confirm the 1.x to 2.x migration details; those remain plan-level UNVERIFIED.
