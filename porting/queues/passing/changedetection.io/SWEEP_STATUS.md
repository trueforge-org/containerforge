# Sweep Status

- Timestamp (UTC): 2026-02-19T12:29:13Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 120 seconds

## Last build log tail
```
#7 80.55   Preparing metadata (pyproject.toml): started
#7 81.22   Preparing metadata (pyproject.toml): finished with status 'done'
#7 81.22 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969d10>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 81.73 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 82.73 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969810>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 84.73 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969590>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 88.73 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969310>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 88.75 Collecting flask_restful (from -r /app/changedetection/requirements.txt (line 9))
#7 88.78   Downloading Flask_RESTful-0.3.10-py2.py3-none-any.whl.metadata (1.0 kB)
#7 88.78 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f9687d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 89.28 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f968190>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 90.28 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052faa6210>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 92.28 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052faa5950>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 96.29 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969310>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 96.30 Collecting flask_cors (from -r /app/changedetection/requirements.txt (line 10))
#7 96.31   Downloading flask_cors-6.0.2-py3-none-any.whl.metadata (5.3 kB)
#7 96.32 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f9691d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 96.82 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 97.82 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969d10>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 99.82 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f96a490>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 103.8 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f96a5d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 103.8 Collecting janus (from -r /app/changedetection/requirements.txt (line 11))
#7 103.8   Downloading janus-2.0.0-py3-none-any.whl.metadata (5.3 kB)
#7 103.9 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052faa5810>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 104.4 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f96a5d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 105.4 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f96a490>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 107.4 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969d10>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 111.4 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 111.4 Collecting flask_wtf~=1.2 (from -r /app/changedetection/requirements.txt (line 12))
#7 111.4   Downloading flask_wtf-1.2.2-py3-none-any.whl.metadata (3.4 kB)
#7 111.4 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f969450>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 111.9 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f968410>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 112.9 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f96afd0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 114.9 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f968050>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 118.9 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f96b110>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 118.9 Collecting flask~=3.1 (from -r /app/changedetection/requirements.txt (line 13))
#7 118.9   Downloading flask-3.1.3-py3-none-any.whl.metadata (3.2 kB)
#7 118.9 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f052f96b110>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 CANCELED
ERROR: failed to solve: Canceled: context canceled
```
