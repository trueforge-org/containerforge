target "docker-metadata-action" {}

variable "APP" {
  default = "webnut"
}

// VERSION is a static label: upstream has no releases or tags.
variable "VERSION" {
  default = "0.0.1"
}

variable "COMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/rshipp/webNUT currentValue=main
  default = "31f6d4a4d6f3e2db4f076924c882eaa913223a0c"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/rshipp/webNUT"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    COMMIT = "${COMMIT}"
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
