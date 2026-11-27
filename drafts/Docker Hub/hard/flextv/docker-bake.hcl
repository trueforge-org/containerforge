target "docker-metadata-action" {}

variable "APP" {
  default = "flextv"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=d8ahazard/FlexTV packageName=https://github.com/d8ahazard/FlexTV currentDigest=<sha>
  // UNVERIFIED: no releases or tags upstream. Set this to the default-branch commit SHA chosen at implementation time.
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: the repo has license.txt and gpl.txt. Read license.txt and set the SPDX id before the PR.
  default = "LicenseRef-Unknown"
}

variable "SOURCE" {
  default = "https://github.com/d8ahazard/FlexTV"
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
