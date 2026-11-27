# TandoorRecipes/recipes requirements.txt (HEAD)
Source URL: https://raw.githubusercontent.com/TandoorRecipes/recipes/HEAD/requirements.txt (fetched 2026-11-27; raw HEAD works)

Production pins (dev section after `# Development` is stripped at build). Key ones:
| package | version |
| --- | --- |
| Django | 5.2.18 |
| djangorestframework | 3.18.3 |
| gunicorn | 26.2.0 |
| psycopg2-binary | 2.9.12 |
| Pillow | 13.0.0 |
| lxml | 6.1.3 |
| django-allauth[mfa,socialaccount] | 65.19.4 |
| python-ldap | 3.4.7 |
| django-auth-ldap | 5.3.0 |
| recipe-scrapers | 15.13.0 |
| litellm | 1.106.2 |
| django-storages | 1.14.6 |
| whitenoise | 6.12.0 |
| redis | 8.1.0 |

Also pinned: cryptography 50.0.2, drf-spectacular 0.30.0, django-oauth-toolkit 3.4.1, boto3 1.43.118, pytubefix 10.11.0, aiohttp 3.14.5, stripe 15.6.1, django-vite 3.2.0, python3-saml 1.16.0.
Dev-only (stripped): pytest*, flake8, yapf, autopep8, django-debug-toolbar 8.0.0 is in the production block.
