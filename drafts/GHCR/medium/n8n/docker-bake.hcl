target "docker-metadata-action" {}

variable "APP" {
  default = "n8n"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=n8n-io/n8n versioning=loose extractVersion=^n8n@(?<version>.+)$
  // UNVERIFIED: confirm renovate strips the n8n@ tag prefix. Plan said 2.49.6; 2.49.8 seen as latest on 2026-11-27.
  default = "2.49.8"
}

variable "LICENSE" {
  // Sustainable Use License 1.0 (not SPDX). Distribution needs maintainer sign-off before merge.
  default = "Sustainable Use License 1.0"
}

variable "SOURCE" {
  default = "https://github.com/n8n-io/n8n"
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
