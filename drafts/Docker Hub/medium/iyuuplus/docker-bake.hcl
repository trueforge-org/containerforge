target "docker-metadata-action" {}

variable "APP" {
  default = "iyuuplus"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ledccn/iyuuplus-dev currentValue=master
  default = "6610e577604eecdd5d6bc15af6c5087045eb800c"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ledccn/iyuuplus-dev"
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
