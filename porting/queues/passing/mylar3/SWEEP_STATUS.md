# Sweep Status

- Timestamp (UTC): 2026-02-20T13:19:47Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 300/180 seconds
- Forgetool path: /tmp/forgetool-bin/forgetool

## Last build log tail
```
#7 235.6 Collecting zc.lockfile (from CherryPy>=18.5.0->-r requirements.txt (line 11))
#7 235.6   Downloading zc_lockfile-4.0-py3-none-any.whl.metadata (6.6 kB)
#7 235.6 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac2fd0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 236.1 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac3250>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 237.1 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac34d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 239.1 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac3750>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 243.1 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac39d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 243.2 Collecting jaraco.collections (from CherryPy>=18.5.0->-r requirements.txt (line 11))
#7 243.2   Downloading jaraco_collections-5.2.1-py3-none-any.whl.metadata (3.9 kB)
#7 243.2 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac39d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 243.7 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac3750>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 244.7 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac34d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 246.7 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac3250>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 250.7 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac2fd0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 250.7 Collecting sgmllib3k (from feedparser>=5.2.1->-r requirements.txt (line 13))
#7 250.8   Downloading sgmllib3k-1.0.0.tar.gz (5.8 kB)
#7 250.8   Installing build dependencies: started
#7 259.4   Installing build dependencies: finished with status 'done'
#7 259.4   Getting requirements to build wheel: started
#7 260.1   Getting requirements to build wheel: finished with status 'done'
#7 260.1   Preparing metadata (pyproject.toml): started
#7 260.9   Preparing metadata (pyproject.toml): finished with status 'done'
#7 260.9 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac2350>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 261.4 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac0690>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 262.4 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac0910>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 264.4 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd5ec0190>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 268.4 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd5ec0410>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 268.4 Collecting MarkupSafe>=0.9.2 (from Mako>=1.1.0->-r requirements.txt (line 14))
#7 268.5   Downloading markupsafe-3.0.3-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl.metadata (2.7 kB)
#7 268.5 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec7d90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 269.0 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec47d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 270.0 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec5090>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 272.0 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec65d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 276.0 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec5e50>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 276.0 Collecting tempora>=1.8 (from portend>=2.6->-r requirements.txt (line 18))
#7 276.0   Downloading tempora-5.8.1-py3-none-any.whl.metadata (3.3 kB)
#7 276.1 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec65d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 276.6 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec47d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 277.6 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec7d90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 279.6 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac1e50>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 283.6 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac20d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 283.7 Collecting charset_normalizer<4,>=2 (from requests>=2.22.0->requests[socks]>=2.22.0->-r requirements.txt (line 23))
#7 283.7   Downloading charset_normalizer-3.4.4-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl.metadata (37 kB)
#7 283.7 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec6350>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 284.2 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ec6ad0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 285.2 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac20d0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 287.2 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac1e50>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 291.2 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac1a90>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 291.2 Collecting idna<4,>=2.5 (from requests>=2.22.0->requests[socks]>=2.22.0->-r requirements.txt (line 23))
#7 291.3   Downloading idna-3.11-py3-none-any.whl.metadata (8.4 kB)
#7 291.3 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac0690>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 291.8 WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac2350>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 292.8 WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac2ad0>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 294.8 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac3110>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 298.8 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac3390>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 298.8 Collecting certifi>=2017.4.17 (from requests>=2.22.0->requests[socks]>=2.22.0->-r requirements.txt (line 23))
#7 298.8   Downloading certifi-2026.1.4-py3-none-any.whl.metadata (2.5 kB)
#7 298.8 WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7fccd6ac3890>: Failed to establish a new connection: [Errno -5] No address associated with hostname')': /alpine-3.19/
#7 CANCELED
ERROR: failed to solve: Canceled: context canceled
```
