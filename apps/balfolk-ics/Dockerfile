FROM ghcr.io/trueforge-org/python:3.13.7@sha256:cbb27d8be6746edc1ba1b6abc502a3ce311948e4e9025c73b7dee50c6a1bbd0d

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
COPY --chown=568:568 . /

# Create output file for serving
RUN touch /app/balfolk.ics

# Install cron jobs
RUN crontab /app/crontab.txt

# Optional: start cron in foreground when container runs
# CMD ["cron", "-f"]

HEALTHCHECK CMD [ "curl", "--connect-timeout", "15", "--max-time", "100", "--silent", "--show-error", "--fail", "http://localhost:8000/" ]
