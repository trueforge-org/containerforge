target "docker-metadata-action" {}

variable "APP" {
  default = "reubah"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/DenDianUgerah/reubah currentValue=main
  default = "04469cf95ea7105f9d60e4906eab5533fb70ccd1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/DenDianUgerah/reubah"
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
