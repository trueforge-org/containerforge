# caldav (PyPI)

Source URL(s) + fetch date:
- https://pypi.org/project/caldav/
- Fetched 2026-11-26

## What it is
A CalDAV (RFC 4791) client library for Python. Creates/modifies calendars, creates/updates/deletes events, searches events by date. Async support via `caldav.aio`. Dual-licensed GPL-3.0-or-later or Apache-2.0. Dev status "4 - Beta".

## Version
- Latest: caldav 3.7.0, released Oct 29, 2026. A 3.7.0a0 pre-release came out the same day.
- Requires-Python: `>=3.10` (classifiers: 3.10 through 3.14).

## Dependencies
- Runtime dependencies: NOT listed on the page.
- Optional extras shown: `jmap`, `niquests`, `test`.
- README (per page): sync client uses `niquests` by default, falls back to `requests`. Async client prefers `niquests`, then the httpx family (`httpx2`, `httpxyz`, `httpx`).

## API hints shown
- `get_davclient()` imported from `caldav`, used as a context manager (page does not mention `DAVClient` by name).
- `client.principal()` returns the principal.
- `principal.get_calendars()` returns calendars; each has a `name` attribute.
- Async: `caldav.aio.get_async_davclient()` with `async with`; `await client.principal()`, `await principal.get_calendars()`.
- `save_event` not shown on this page (event create/update/delete mentioned only as features).

## Caveats
- The page says user docs are current as of version 3.2, so they may lag 3.7.0.
- Release files were uploaded without Trusted Publishing and without provenance attestations.

## Relevance to plan.md / upstream code
- Upstream import_ics (2022) uses `caldav.DAVClient`, `principal().calendars()`, `make_calendar`, `save_event(ical=...)`. This page does not confirm those names for 3.x. Still UNVERIFIED (plan section 10).
- Plan section 1 says PyPI metadata lists `niquests` and that caldav does not depend on `requests`. The page shows `niquests` only as an optional extra and does not list runtime deps, so this could not be verified here.
