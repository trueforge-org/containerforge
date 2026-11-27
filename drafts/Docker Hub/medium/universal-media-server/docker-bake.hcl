target "docker-metadata-action" {}

variable "APP" {
  default = "universal-media-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=UniversalMediaServer/UniversalMediaServer versioning=loose
  default = "15.9.0"
}

// UNVERIFIED: confirm GPL-2.0-only vs GPL-2.0-or-later against the LICENSE file in the repo
variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/UniversalMediaServer/UniversalMediaServer"
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
