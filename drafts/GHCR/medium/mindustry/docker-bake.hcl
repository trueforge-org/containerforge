target "docker-metadata-action" {}

variable "APP" {
  default = "mindustry"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Anuken/Mindustry versioning=loose
  default = "160.8"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-3.0 per GitHub. Confirm -only or -or-later from the LICENSE header before committing.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Anuken/Mindustry"
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
