# Seeded to /config/lemur.conf.py by start.sh only when that file is missing or empty.
# All values come from the environment at each start, so changing them needs no file edit.
# UNVERIFIED: key names and the LEMUR_CONF variable must be checked against Lemur 1.9.3.
import os

SQLALCHEMY_DATABASE_URI = os.environ.get("LEMUR_DATABASE_URI", "")
SECRET_KEY = os.environ.get("LEMUR_SECRET_KEY", "")
LEMUR_TOKEN_SECRET = os.environ.get("LEMUR_TOKEN_SECRET", "")
LEMUR_ENCRYPTION_KEYS = os.environ.get("LEMUR_ENCRYPTION_KEYS", "")
