# Stage 1 - Build the Go application
FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:2ba11b36bd37525691b6d9988fe84d59ef36d65a54e0f62b59272dcd67655580 AS builder

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
COPY . /

# Create necessary directories
RUN mkdir -p /build /output && ls -la /build

# Set the working directory
WORKDIR /build

# Download Go dependencies
RUN go mod download

# Build the Go application
RUN go build -ldflags "-w -s" -o /output/my-proxy-service .


# Stage 2 - Create the final image
FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:9a693d4ad7151ab7bd13b94e6c6137b90dabf6d44280a1aad6e4a65e191749d2

# Set working directory
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /output/my-proxy-service .

# Set environment variables
ENV PORT=3000

# Expose the port
EXPOSE $PORT

# Set default command to run the binary
CMD ["./my-proxy-service"]
