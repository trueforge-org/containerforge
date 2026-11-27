# CTFd 3.8.9 requirements.txt (key pins)

## Source URL(s) + date
- https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/requirements.txt (fetched 2026-11-27; pip-compile output with `-r requirements.in`)

## Key pins
| Package | Pin | Note |
| --- | --- | --- |
| flask | 2.1.3 | |
| gunicorn | 23.0.0 | WSGI server |
| gevent | 25.5.1 | default gunicorn worker class |
| sqlalchemy | 1.4.54 | |
| flask-sqlalchemy | 2.5.1 | |
| flask-migrate | 2.5.3 | `flask db upgrade` |
| alembic | 1.16.4 | |
| pymysql | 1.1.1 | MySQL driver (`pymysql[rsa]`) |
| redis | 4.5.5 | cache client |
| flask-caching | 2.3.1 | |
| cryptography | 45.0.6 | |
| pillow | 12.2.0 | |
| cmarkgfm | 2024.11.20 | markdown |
| nh3 | 0.3.0 | HTML sanitiser |
| bcrypt | 4.0.1 | |
| boto3 | 1.35.27 | S3 upload provider |
| pydantic | 1.6.2 | |
| werkzeug | 2.2.3 | |
| jinja2 | 3.1.6 | |
| python-geoacumen-city | 2023.4.15 | GeoIP data |
| maxminddb | 1.5.4 | |
| requests | 2.32.4 | |

## Build notes
- Full file has about 100 pins (flask-restx 1.3.0, marshmallow 2.20.2, dataset 1.6.2, passlib 1.7.4, wtforms 2.3.1, flask-babel 2.0.0, tenacity 9.1.2, and others).
- Ends with `# setuptools` as an unsafe-in-requirements note.
- Plugins add their own requirements via the Dockerfile loop.
