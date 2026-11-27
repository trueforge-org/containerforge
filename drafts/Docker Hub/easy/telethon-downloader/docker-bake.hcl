target "docker-metadata-action" {}

variable "APP" {
  default = "telethon-downloader"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/jsavargas/telethon_downloader versioning=semver
  default = "4.0.15"
}

// UNVERIFIED: GPL-3.0-only vs GPL-3.0-or-later. Confirm against the source file notices.
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/jsavargas/telethon_downloader"
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
