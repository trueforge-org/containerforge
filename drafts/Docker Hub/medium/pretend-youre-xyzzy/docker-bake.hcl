target "docker-metadata-action" {}

variable "APP" {
  default = "pretend-youre-xyzzy"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ajanata/PretendYoureXyzzy currentValue=master
  // UNVERIFIED: candidate master commit from the plan (committed 2026-10-23); confirm it is the commit to build
  default = "10525012c69c76d902148828ff946545563faf80"
}

variable "LICENSE" {
  default = "BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/ajanata/PretendYoureXyzzy"
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
