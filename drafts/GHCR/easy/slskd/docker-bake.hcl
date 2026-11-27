target "docker-metadata-action" {}

variable "APP" {
  default = "slskd"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=slskd/slskd versioning=semver
  default = "0.26.2"
}

// UNVERIFIED: computed locally from the release zip, not published upstream. Empty until computed.
variable "SHA256_X64" {
  default = ""
}

// UNVERIFIED: computed locally from the release zip, not published upstream. Empty until computed.
variable "SHA256_ARM64" {
  default = ""
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/slskd/slskd"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SHA256_X64 = "${SHA256_X64}"
    SHA256_ARM64 = "${SHA256_ARM64}"
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
