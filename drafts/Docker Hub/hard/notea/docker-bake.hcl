target "docker-metadata-action" {}

variable "APP" {
  default = "notea"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=QingWei-Li/notea extractVersion=^v(?<version>.+)$ versioning=loose
  default = "0.4.0-alpha"
}

variable "MINIO_VERSION" {
  // renovate: datasource=github-tags depName=minio/minio versioning=loose
  default = "RELEASE.2025-10-15T17-29-55Z"
}

// UNVERIFIED: MinIO is AGPL-3.0 per its README; confirm the exact identifier from the license header.
variable "LICENSE" {
  default = "MIT AND AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/QingWei-Li/notea"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MINIO_VERSION = "${MINIO_VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
