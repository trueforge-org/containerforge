target "docker-metadata-action" {}

variable "APP" {
  default = "plaxt"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/XanderStrike/goplaxt currentValue=master
  default = "1607349dea8ce7fb3b8e7ccfb0370d8103d31d61"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/XanderStrike/goplaxt"
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
