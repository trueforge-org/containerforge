# hauxir/imgpush: app/entrypoint.sh (master)
Source URL: https://raw.githubusercontent.com/hauxir/imgpush/master/app/entrypoint.sh (fetched 2026-11-26)
- WORKERS default = getconf _NPROCESSORS_ONLN
- Exports single-thread vars: OMP_NUM_THREADS, OPENBLAS_NUM_THREADS, MKL_NUM_THREADS, VECLIB_MAXIMUM_THREADS, NUMEXPR_NUM_THREADS = 1
- MALLOC_MMAP_THRESHOLD_=65536, MALLOC_TRIM_THRESHOLD_=131072
- Runs `nginx` (daemon) then `uvicorn app:app --uds imgpush.sock --access-log --workers "$WORKERS" --limit-max-requests 200` (socket is relative to /app)
