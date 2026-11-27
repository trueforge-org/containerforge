target "docker-metadata-action" {}

variable "APP" {
  default = "trango"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=trango-io/trango-self-hosted packageName=https://github.com/trango-io/trango-self-hosted
  // The upstream repo has no releases or tags, so VERSION is a commit SHA.
  default = "4ba53cf75f9b2eb7bc2cdfaefaca29fd35ed11a8"
}

variable "LICENSE" {
  // UNVERIFIED: README says GPL-2.0. The "or later" clause was not checked.
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/trango-io/trango-self-hosted"
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
