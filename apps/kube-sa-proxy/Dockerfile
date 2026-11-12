# Stage 1 - Build the Go application
FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:fcdf7c94e1041f7787254a74113fcb5aeb3b543e6c138524ae796127e95c4404 AS builder

USER root

# Install necessary build dependencies
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        git \
    ; \
    rm -rf /var/lib/apt/lists/*

# Copy Go project files
COPY --chmod=0755 . /

# Create necessary directories
RUN mkdir -p /build /output && ls -la /build

# Set the working directory
WORKDIR /build

# Download Go dependencies
RUN go mod download

# Build the Go application
RUN go build -ldflags "-w -s" -o /output/my-proxy-service .


# Stage 2 - Create the final image
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f5810a8898e3c4010e9609799c2cc0ef871d42a7637fbdd77f2c62c1e67b495c

# Set working directory
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /output/my-proxy-service .

# Provide the default token file expected by the app's API_FILE default.
RUN touch /app/file_to_watch.txt

# Set environment variables
ENV PORT=3000

# Expose the port
EXPOSE $PORT

# Set default command to run the binary
CMD ["./my-proxy-service"]
