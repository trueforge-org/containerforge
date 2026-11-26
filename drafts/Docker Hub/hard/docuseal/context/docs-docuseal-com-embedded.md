# docuseal.com docs: embedded forms

Source URL(s) + fetch date:
- https://www.docuseal.com/docs/embedded
- Fetched 2026-11-26

## What it is
- Documentation for embedding the signing form in a web page via the `<docuseal-form>` web component (JS, Vue, Angular, React variants).
- Attributes: form URL (`/d/{slug}` templates, `/s/{slug}` signers), email, name, role, external ID, JWT token (generated on the backend and signed with the API key), preview mode, field ordering, autoscroll, decline/complete buttons, prefill, read-only fields, appearance, completion redirect.
- Callbacks: init, load, completed, declined.

## Env vars/ports/self-hosting
- None listed. No self-hosting instructions on this page.

## Gotchas
- Embedding is a hosted-API feature; the container itself is not described here.
