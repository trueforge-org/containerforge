target "docker-metadata-action" {}

variable "APP" {
  default = "quiz-game"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ASKJR/quiz-game currentValue=master
  default = "2d9243eb1d2da4f135bfb4c08d2d0d06eb806a3b"
}

variable "LICENSE" {
  // UNVERIFIED: no LICENSE file and no license field found upstream (checked 2026-11-27). Set before the PR.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/ASKJR/quiz-game"
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
