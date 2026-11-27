# semaphoreui.com/docs

Source URL(s): https://semaphoreui.com/docs (fetched 2026-11-27)

## Content
- Page is mostly navigation and JavaScript. Text extracted: quick start uses `docker run` with `SEMAPHORE_DB_DIALECT=sqlite`, `SEMAPHORE_ADMIN=admin`, `SEMAPHORE_ADMIN_PASSWORD=changeme`, `SEMAPHORE_ADMIN_NAME`, `SEMAPHORE_ADMIN_EMAIL`, volume `/var/lib/semaphore`, port 3000.
- Installation details (Docker Compose, Kubernetes) are on sub-pages not fetched (budget).

## Gotchas
- Docs say the data volume is `/var/lib/semaphore`; the chart mounts `/data` and `/etc/semaphore`.
