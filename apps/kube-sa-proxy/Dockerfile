# Stage 1 - Build the Go application
FROM ghcr.io/trueforge-org/golang:1.27.1@sha256:7587f6edef7d3a31d6fd1447806a53cac8409123e462c35268f5f86c6979da18 AS builder

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
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:1888fc219883c47800b75c40a586266ebb7362f9a13f697dbe894fb777a299bf

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
