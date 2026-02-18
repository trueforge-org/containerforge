FROM ghcr.io/trueforge-org/python:3.13.12@sha256:a6e9da280c86f6604e3f9174989b76d6453f6f94d249163049783eeb80118370

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
