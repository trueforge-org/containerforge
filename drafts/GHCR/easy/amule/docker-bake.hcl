target "docker-metadata-action" {}

variable "APP" {
  default = "amule"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=amule-org/amule versioning=semver
  default = "3.2.0"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION; the project home page states GPL-2.0. Confirm against COPYING.
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/amule-org/amule"
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
