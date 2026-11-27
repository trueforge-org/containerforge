target "docker-metadata-action" {}

variable "APP" {
  default = "teamspeak3"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/teamspeak versioning=semver
  default = "3.13.9"
}

// Proprietary TeamSpeak license (no SPDX id).
variable "LICENSE" {
  default = "LicenseRef-TeamSpeak-EULA"
}

variable "SOURCE" {
  default = "https://www.teamspeak.com/en/downloads/"
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

// amd64 only: no arm64 server build is published by the vendor.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
