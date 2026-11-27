target "docker-metadata-action" {}

variable "APP" {
  default = "teedy"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sismics/docs versioning=loose
  default = "1.12"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/sismics/docs"
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
