target "docker-metadata-action" {}

variable "APP" {
  default = "clickhouse"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ClickHouse/ClickHouse versioning=loose extractVersion=^v(?<version>[0-9.]+)-stable$
  default = "26.10.2.103"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/ClickHouse/ClickHouse"
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
