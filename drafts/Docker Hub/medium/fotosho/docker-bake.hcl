target "docker-metadata-action" {}

variable "APP" {
  default = "fotosho"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/advplyr/fotosho currentValue=master
  // BLOCKED: placeholder until a master commit SHA is resolved (no tags or releases upstream)
  default = "UNRESOLVED_MASTER_COMMIT_SHA"
}

variable "LICENSE" {
  // BLOCKED: no license found upstream; set the SPDX id once the owner confirms it
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/advplyr/fotosho"
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
