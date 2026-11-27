import os

# Read at import time from the environment; nothing is written to disk.
server = os.environ.get("UPS_HOST", "127.0.0.1")
# UNVERIFIED: nut2-notl may expect port as int or str; check during the run step.
port = int(os.environ.get("UPS_PORT", "3493"))
username = os.environ.get("UPS_USER") or None
password = os.environ.get("UPS_PASSWORD") or None
