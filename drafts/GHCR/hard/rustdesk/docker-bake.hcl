target "docker-metadata-action" {}

variable "APP" {
  default = "rustdesk"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rustdesk/rustdesk-server versioning=semver
  default = "1.1.16"
}

// UNVERIFIED: SPDX identifier (AGPL-3.0-only vs -or-later). The LICENSE text is AGPL v3 (plan section 1).
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rustdesk/rustdesk-server"
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
