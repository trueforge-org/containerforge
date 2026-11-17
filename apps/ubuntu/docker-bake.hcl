target "docker-metadata-action" {}

variable "APP" {
  default = "ubuntu"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/ubuntu
  default = "26.04"
}

variable "NODE_VERSION" {
  // renovate: datasource=docker depName=docker.io/library/node
  default = "26.13.1"
}

variable "YARN_VERSION"{
  // renovate: datasource=npm depName=yarn
  default = "1.22.22"
}

variable "NEO_VER" {
  // renovate: datasource=github-releases depName=intel/compute-runtime versioning=loose
  default = "26.40.40196.8"
}

// Fixed Legacy value
variable "IGC1_LEGACY_VER" {
  default = "1.0.17537.24"
}

// Fixed Legacy value
variable "NEO_LEGACY_VER" {
  default = "24.35.30872.36"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://hub.docker.com/_/ubuntu"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    NODE_VERSION = "${NODE_VERSION}"
    YARN_VERSION = "${YARN_VERSION}"
    NEO_VER = "${NEO_VER}"
    IGC1_LEGACY_VER = "${IGC1_LEGACY_VER}"
    NEO_LEGACY_VER = "${NEO_LEGACY_VER}"
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
