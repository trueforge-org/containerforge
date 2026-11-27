# GitHub: krateng/maloja requirements.txt

Source URL(s), fetched 2026-11-27:
- https://github.com/krateng/maloja/blob/HEAD/requirements.txt

## Pinned requirement lines (as written)
- bottle==0.13.*
- waitress==3.0.*
- doreah==2.0.*
- nimrodel==0.8.*
- setproctitle==1.3.*
- jinja2==3.1.*
- lru-dict==1.3.*
- psutil==5.9.*
- sqlalchemy==2.0
- python-datauri==3.0.*
- python-magic==0.4.*
- requests==2.32.*
- toml==0.10.*
- PyYAML==6.0.*

## Notes
- No Python version comment in the file.
- python-magic needs libmagic at runtime (Containerfile installs libmagic).
- PyYAML and lxml-related native deps: see Containerfile (build-deps for libxml2/libxslt/libffi).
