target "docker-metadata-action" {}

variable "APP" {
  default = "chowdown"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/clarklab/chowdown currentValue=gh-pages
  default = "48d56ea7a0115f722653dac6466b861f7eed4ca3"
}

variable "LICENSE" {
  default = "Unlicense"
}

variable "SOURCE" {
  default = "https://github.com/clarklab/chowdown"
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
