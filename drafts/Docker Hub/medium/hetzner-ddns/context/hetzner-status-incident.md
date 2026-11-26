# Hetzner status incident: DNS Console shutdown
Source URL: https://status.hetzner.com/incident/c2146c42-6dd2-4454-916a-19f07e0e5a44 (fetched 2026-11-26)

- Title: "Shutdown of DNS Console (dns.hetzner.com) in May 2026"
- Status: Resolved. Affected: DNS Console. Start 2026-01-09 10:08 UTC, ends 2026-05-27 07:39 UTC.
- Text: DNS Console shut down in May 2026; migrate zones to the new DNS in Hetzner Console. Docs: https://docs.hetzner.com/networking/dns/faq/beta and .../migration-to-hetzner-console/process
- Update 2026-05-27: "The DNS console and API was removed. dns.hetzner.com redirects as of now to console.hetzner.com."
- Impact on image: the upstream Go client (dns.hetzner.com/api/v1) cannot update records.
