target "docker-metadata-action" {}

variable "APP" {
  default = "rsshub"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=DIYgod/RSSHub versioning=loose
  default = "v2026.11.28-8771.g6973206"
}

// UNVERIFIED: AGPL-3.0 per the RSSHub repository, not re-checked for this tag.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/DIYgod/RSSHub"
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
