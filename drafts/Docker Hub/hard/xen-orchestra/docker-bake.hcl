target "docker-metadata-action" {}

variable "APP" {
  default = "xen-orchestra"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ronivay/xen-orchestra versioning=loose
  default = "5.214.1"
}

// Commit of vatesfr/xen-orchestra that matches VERSION. UNVERIFIED: e9760747 is the master HEAD seen in the plan, which reports xo-server 5.214.0.
// Renovate does not bump this. Update it by hand with VERSION.
variable "XO_REF" {
  default = "e9760747f90b96c56e3d5fc1534ff3cd5a6d3ee6"
}

// UNVERIFIED: copied from apps/valkey, not checked against ubuntu 26.04 for this image.
variable "VALKEY_PACKAGE_VERSION" {
  default = "9.0.4-0ubuntu0.2"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/vatesfr/xen-orchestra/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    XO_REF = "${XO_REF}"
    VALKEY_PACKAGE_VERSION = "${VALKEY_PACKAGE_VERSION}"
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
