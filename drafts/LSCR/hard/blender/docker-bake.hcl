target "docker-metadata-action" {}

variable "APP" {
  default = "blender"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=blender/blender versioning=semver-coerced
  default = "5.0.1"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-2.0-or-later vs GPL-3.0-or-later; confirm from the repo before merging
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/blender/blender"
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
