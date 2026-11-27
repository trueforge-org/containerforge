target "docker-metadata-action" {}

variable "APP" {
  default = "podgrab"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/akhilrex/podgrab currentValue=master
  default = "032248091294dbf5b6a439a5afd93788a7cc647f"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/akhilrex/podgrab"
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
