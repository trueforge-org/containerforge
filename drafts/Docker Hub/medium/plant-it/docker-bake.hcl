target "docker-metadata-action" {}

variable "APP" {
  default = "plant-it"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MDeLuise/plant-it versioning=semver
  default = "0.10.0"
}

variable "LICENSE" {
  // UNVERIFIED: upstream LICENSE.txt does not state only/or-later; or-later used as the conservative choice
  default = "GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/MDeLuise/plant-it"
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
