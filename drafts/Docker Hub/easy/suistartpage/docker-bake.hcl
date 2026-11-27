target "docker-metadata-action" {}

variable "APP" {
  default = "suistartpage"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/CorneliousJD/SUI-Startpage currentValue=master
  default = "fb4094a047d25cd21352c0849b5b623171e7974c"
}

variable "LICENSE" {
  default = "Unlicense"
}

variable "SOURCE" {
  default = "https://github.com/CorneliousJD/SUI-Startpage"
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
