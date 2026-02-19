# Sweep Status

- Timestamp (UTC): 2026-02-19T13:02:35Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 120 seconds

## Last build log tail
```
#7 66.59 Collecting sgmllib3k (from feedparser->feed2toot==0.17)
#7 66.60   Downloading sgmllib3k-1.0.0.tar.gz (5.8 kB)
#7 66.60   Installing build dependencies: started
#7 75.17   Installing build dependencies: finished with status 'done'
#7 75.17   Getting requirements to build wheel: started
#7 75.83   Getting requirements to build wheel: finished with status 'done'
#7 75.83   Preparing metadata (pyproject.toml): started
#7 76.50   Preparing metadata (pyproject.toml): finished with status 'done'
#7 76.50 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922490>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 77.01 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922710>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 78.01 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922990>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 80.01 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922c10>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 84.01 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922e90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 84.04 Collecting requests>=2.4.2 (from Mastodon.py->feed2toot==0.17)
#7 84.05   Downloading requests-2.32.5-py3-none-any.whl.metadata (4.9 kB)
#7 84.05 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0923390>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 84.55 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922fd0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 85.55 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922d50>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 87.55 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922ad0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 91.56 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0922850>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 91.57 Collecting python-dateutil (from Mastodon.py->feed2toot==0.17)
#7 91.58   Downloading python_dateutil-2.9.0.post0-py2.py3-none-any.whl.metadata (8.4 kB)
#7 91.58 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0920190>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 92.09 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0921590>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 93.09 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0921a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 95.09 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0923110>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 99.09 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c09234d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 99.10 Collecting python-magic (from Mastodon.py->feed2toot==0.17)
#7 99.11   Downloading python_magic-0.4.27-py2.py3-none-any.whl.metadata (5.8 kB)
#7 99.12 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0923890>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 99.62 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0894050>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 100.6 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c08942d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 102.6 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0894550>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 106.6 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c08947d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 106.6 Collecting decorator>=4.0.0 (from Mastodon.py->feed2toot==0.17)
#7 106.7   Downloading decorator-5.2.1-py3-none-any.whl.metadata (3.9 kB)
#7 106.7 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c09239d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 107.2 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fb6c0923610>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /ubuntu/
#7 CANCELED
ERROR: failed to solve: Canceled: context canceled
```
