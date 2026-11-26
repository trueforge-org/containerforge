# hauxir/imgpush: nginx.conf (commit 9a44956)
Source URL: https://raw.githubusercontent.com/hauxir/imgpush/9a44956/nginx.conf (fetched 2026-11-26)
- server listen 5000; client_max_body_size 0
- location / -> proxy_pass http://unix:/app/imgpush.sock (uvicorn socket)
- location /nginx/ internal alias for X-Accel-Redirect file serving
