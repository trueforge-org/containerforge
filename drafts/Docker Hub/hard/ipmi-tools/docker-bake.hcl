target "docker-metadata-action" {}

variable "APP" {
  default = "ipmi-tools"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=EdwardChamberlain/IPMI-Fan-Controller packageName=https://github.com/EdwardChamberlain/IPMI-Fan-Controller currentDigest=d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246
  default = "d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246"
}

variable "LICENSE" {
  // BLOCKER: the upstream repo has no licence. This placeholder is not a real licence.
  // Do not merge until the upstream author grants one or maintainers decide otherwise.
  default = "LicenseRef-None-Specified"
}

variable "SOURCE" {
  default = "https://github.com/EdwardChamberlain/IPMI-Fan-Controller"
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
