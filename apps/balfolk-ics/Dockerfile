FROM ghcr.io/trueforge-org/python:3.13.7@sha256:eb8c395317bd3e807501ef61f4d16a9582b11db2e28c46e74d1dd6c9762002a4

USER root

# Install cron and other dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        cron \
        && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir requests beautifulsoup4 icalendar pytz

# Set working directory
WORKDIR /app

# Copy application code
COPY --chown=nobody:nogroup . /

# Create output file for serving
RUN touch /app/balfolk.ics

# Install cron jobs
RUN crontab /app/crontab.txt

# Optional: start cron in foreground when container runs
# CMD ["cron", "-f"]
