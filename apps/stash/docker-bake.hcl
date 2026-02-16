target "docker-metadata-action" {}

variable "APP" {
  default = "stash"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=stashapp/stash
  default = "0.30.1"

}


variable "INTEL_CR_VERSION" {
  // renovate: datasource=github-releases depName=intel/compute-runtime versioning=loose
  default = "26.05.37020.3"

}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/stashapp/stash"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    INTEL_CR_VERSION = "${INTEL_CR_VERSION}"
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
