target "docker-metadata-action" {}

variable "APP" {
  default = "retrobot"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/rossimo/retrobot currentValue=master
  // UNVERIFIED: a short SHA from the draft (d04ddd8). Replace with the full 40-character commit SHA before building. The Dockerfile fetches this exact archive.
  default = "d04ddd8"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/rossimo/retrobot"
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
