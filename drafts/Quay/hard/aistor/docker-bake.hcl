target "docker-metadata-action" {}

variable "APP" {
  default = "aistor"
}

variable "VERSION" {
  // renovate: datasource=docker depName=quay.io/minio/aistor/minio versioning=loose
  // UNVERIFIED: this tag format and the renovate datasource are not yet tested.
  default = "RELEASE.2026-09-19T17-05-25Z"
}

variable "LICENSE" {
  // PLACEHOLDER: MinIO AIStor is proprietary. Confirm the SPDX/licence value before merge.
  default = "LicenseRef-MinIO-AIStor"
}

variable "SOURCE" {
  default = "https://min.io/product/aistor"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
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
