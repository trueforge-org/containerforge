target "docker-metadata-action" {}

variable "APP" {
  default = "krusader"
}

variable "VERSION" {
  // UNVERIFIED: placeholder. Set to the upstream krusader version the Ubuntu 26.04 archive provides.
  // renovate: UNVERIFIED datasource and depName (no tracker confirmed for Ubuntu apt packages)
  default = "UNVERIFIED"
}

variable "PACKAGE_VERSION" {
  // UNVERIFIED: placeholder. Full apt version string, checked with apt-cache policy krusader.
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // UNVERIFIED: placeholder. Krusader is GPL upstream, not confirmed in this draft.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/KDE/krusader"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
