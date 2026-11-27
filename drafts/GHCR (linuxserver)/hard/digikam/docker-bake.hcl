target "docker-metadata-action" {}

variable "APP" {
  default = "digikam"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=UNVERIFIED (KDE mirror, not github-releases; plan section 1)
  default = "9.1.0"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/KDE/digikam"
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
  // amd64 only: the digiKam AppImage is x86-64 only (plan section 10, blocker 2)
  platforms = [
    "linux/amd64"
  ]
}
