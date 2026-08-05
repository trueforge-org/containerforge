FROM ghcr.io/trueforge-org/python:3.14.6@sha256:7126ada2ea0c2086b0f078af562c413bbbbb44b946aeb70c3175386647e434fe

USER root
COPY --chmod=0755 . /

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

