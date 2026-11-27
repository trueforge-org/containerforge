target "docker-metadata-action" {}

variable "APP" {
  default = "nocodb"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=nocodb/nocodb versioning=loose
  // Renovate may propose 2026.06.2 and later, which have no linux binary. Cap with a packageRules allowedVersions entry, and update both sha values by hand per bump.
  default = "2026.06.1"
}

// sha256 of the Noco-linux-x64 and Noco-linux-arm64 release assets (GitHub asset digests). Update by hand on every bump.
variable "NOCO_SHA256_AMD64" {
  default = "51e481c9bf84fd71d23740e321caa6d327fa54da3a570a02a733bfff4c1aa3c5"
}

variable "NOCO_SHA256_ARM64" {
  default = "0bc6c238efbf1c0b0c55af1b5dcbbb1cc749ab1ecbff95f69bc46c18cd476090"
}

// UNVERIFIED as a registered SPDX id. NocoDB uses the Sustainable Use License 1.0 (source-available, not OSI). Redistribution needs maintainer review.
variable "LICENSE" {
  default = "LicenseRef-Sustainable-Use-1.0"
}

variable "SOURCE" {
  default = "https://github.com/nocodb/nocodb"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    NOCO_SHA256_AMD64 = "${NOCO_SHA256_AMD64}"
    NOCO_SHA256_ARM64 = "${NOCO_SHA256_ARM64}"
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
