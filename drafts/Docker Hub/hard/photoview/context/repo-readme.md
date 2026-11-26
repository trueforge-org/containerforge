# photoview README (master)

Source URL: https://raw.githubusercontent.com/photoview/photoview/master/README.md (fetched)

- What: self-hosted photo gallery; scans filesystem, thumbnails, albums mirror folders; multi-user; public/password shares; RAW, EXIF, video, face recognition.
- License: LICENSE.txt linked, name not stated in README.
- Stack: API Go >=1.22, GraphQL; native libs libheif, dlib, libjpeg, libblas, liblapack, libmagic, libmagickwand. UI Node 18.
- DBs: SQLite (lowest perf), MariaDB LTS (default in examples), PostgreSQL 18 or 17.
- Docker: compose examples in "docker-compose example/" folder (docker-compose.example.yml recommended, docker-compose.minimal.example.yml). Rename to drop "example"; `make readable` or GID/UID 999 for media; `make all`; setup wizard; Scan All.
- Images: photoview/photoview on Docker Hub (new); viktorstrate/photoview (old).
- Ports: 8000 app default in compose (80 inside container).
- Hardware accel: PHOTOVIEW_VIDEO_HARDWARE_ACCELERATION (qsv, vaapi, nvenc); map /dev/dri for qsv/vaapi; nvenc needs NVIDIA toolkit.
- Postgres 18 mounts at /var/lib/postgresql (not /data).
