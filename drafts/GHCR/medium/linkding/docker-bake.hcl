target "docker-metadata-action" {}

variable "APP" {
  default = "linkding"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sissbruecker/linkding versioning=semver
  default = "1.47.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/sissbruecker/linkding"
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
