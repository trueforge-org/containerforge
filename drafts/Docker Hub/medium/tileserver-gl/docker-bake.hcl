target "docker-metadata-action" {}

variable "APP" {
  default = "tileserver-gl"
}

variable "VERSION" {
  // renovate: datasource=npm depName=tileserver-gl
  default = "5.7.0"
}

variable "LICENSE" {
  // UNVERIFIED: npm metadata says BSD-2-Clause; GitHub reports NOASSERTION. Confirm the repo LICENSE file before merge.
  default = "BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/maptiler/tileserver-gl"
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
