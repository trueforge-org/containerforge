target "docker-metadata-action" {}

variable "APP" {
  default = "invitarr"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/Sleepingpirates/Invitarr currentValue=master
  // Commit on master (2022-09-20). The upstream repo is archived; no updates are expected.
  default = "ce30f130dac51352fd5a1336c87c30cece79f085"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/faizyy01/Invitarr"
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
