# Stage 1 - Build the Go application
FROM ghcr.io/trueforge-org/golang:1.27.3@sha256:fb2c2aa3f0b6207f76d92b80fd5c343d714bd0b33af15b68bd05a66cb8e2d3f9 AS builder

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
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1

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
