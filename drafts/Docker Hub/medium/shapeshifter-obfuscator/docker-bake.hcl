target "docker-metadata-action" {}

variable "APP" {
  default = "shapeshifter-obfuscator"
}

variable "VERSION" {
  // renovate: datasource=git-tags depName=https://github.com/OperatorFoundation/shapeshifter-dispatcher versioning=semver
  default = "3.0.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/OperatorFoundation/shapeshifter-dispatcher"
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
