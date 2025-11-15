exec /app/flood \
  --rundir /config \
  --allowedpath /data \
  --host 0.0.0.0 \
  --port 3000 $@
