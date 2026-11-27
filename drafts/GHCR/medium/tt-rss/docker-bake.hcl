target "docker-metadata-action" {}

variable "APP" {
  default = "tt-rss"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/tt-rss/tt-rss currentValue=main
  default = "03628f0aa3c4a86e960ddd61b5ba372cd3a27b50"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/tt-rss/tt-rss"
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
