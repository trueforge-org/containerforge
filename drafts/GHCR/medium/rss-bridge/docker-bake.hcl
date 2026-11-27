target "docker-metadata-action" {}

variable "APP" {
  default = "rss-bridge"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=RSS-Bridge/rss-bridge versioning=loose
  default = "2025-08-05"
}

variable "CURL_IMPERSONATE_VERSION" {
  // renovate: datasource=github-releases depName=lexiforest/curl-impersonate versioning=loose
  default = "1.0.0rc2"
}

variable "LICENSE" {
  default = "Unlicense"
}

variable "SOURCE" {
  default = "https://github.com/RSS-Bridge/rss-bridge"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CURL_IMPERSONATE_VERSION = "${CURL_IMPERSONATE_VERSION}"
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
