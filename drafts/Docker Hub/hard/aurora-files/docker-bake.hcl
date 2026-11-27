target "docker-metadata-action" {}

variable "APP" {
  default = "aurora-files"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=afterlogic/aurora-files versioning=loose
  // NOTE: the github tags lag master (latest tag 9.3.1 vs VERSION file 9.8.7); the vendor zip is unversioned.
  default = "9.8.7"
}

variable "LICENSE" {
  // UNVERIFIED: README says AGPLv3; "or later" not confirmed.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/afterlogic/aurora-files"
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
