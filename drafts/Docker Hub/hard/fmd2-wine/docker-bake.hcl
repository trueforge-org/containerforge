target "docker-metadata-action" {}

variable "APP" {
  default = "fmd2-wine"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=dazedcat19/FMD2 versioning=loose
  default = "2.0.34.5"
}

variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/dazedcat19/FMD2"
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
  // The FMD2 release is a Windows x86_64 build, so there is no arm64 target.
  platforms = [
    "linux/amd64"
  ]
}
