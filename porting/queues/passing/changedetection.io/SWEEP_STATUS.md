# Sweep Status

- Timestamp (UTC): 2026-02-19T12:56:35Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 120 seconds

## Last build log tail
```
#7 77.75   Downloading flask-expects-json-1.7.0.tar.gz (6.1 kB)
#7 77.76   Installing build dependencies: started
#7 86.33   Installing build dependencies: finished with status 'done'
#7 86.33   Getting requirements to build wheel: started
#7 86.99   Getting requirements to build wheel: finished with status 'done'
#7 86.99   Preparing metadata (pyproject.toml): started
#7 87.67   Preparing metadata (pyproject.toml): finished with status 'done'
#7 87.68 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1d10>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 88.18 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 89.18 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1810>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 91.18 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1590>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 95.18 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1310>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 95.20 Collecting flask_restful (from -r /app/changedetection/requirements.txt (line 9))
#7 95.21   Downloading Flask_RESTful-0.3.10-py2.py3-none-any.whl.metadata (1.0 kB)
#7 95.21 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e07d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 95.71 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e0190>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 96.72 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8eccb1a210>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 98.72 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8eccb19950>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 102.7 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1310>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 102.7 Collecting flask_cors (from -r /app/changedetection/requirements.txt (line 10))
#7 102.7   Downloading flask_cors-6.0.2-py3-none-any.whl.metadata (5.3 kB)
#7 102.8 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e11d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 103.3 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 104.3 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1d10>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 106.3 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e2490>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 110.3 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e25d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 110.3 Collecting janus (from -r /app/changedetection/requirements.txt (line 11))
#7 110.3   Downloading janus-2.0.0-py3-none-any.whl.metadata (5.3 kB)
#7 110.3 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8eccb19810>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 110.8 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e25d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 111.8 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e2490>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 113.8 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1d10>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 117.8 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 117.8 Collecting flask_wtf~=1.2 (from -r /app/changedetection/requirements.txt (line 12))
#7 117.8   Downloading flask_wtf-1.2.2-py3-none-any.whl.metadata (3.4 kB)
#7 117.8 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e1450>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 118.3 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e0410>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 119.3 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f8ecc9e2fd0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 CANCELED
ERROR: failed to solve: Canceled: context canceled
```
