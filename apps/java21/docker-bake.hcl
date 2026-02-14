target "docker-metadata-action" {}

variable "APP" {
  default = "java17"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=adoptium/temurin21-binaries
  default = "21.0.8+9"
}

variable "MAJOR" {
  default = "21"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/adoptium/temurin21"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MAJOR = "${MAJOR}"
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
