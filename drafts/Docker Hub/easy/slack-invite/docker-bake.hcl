target "docker-metadata-action" {}

variable "APP" {
  default = "slack-invite"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ninthwalker/slack-invite currentValue=master
  // UNVERIFIED: whether renovate bumps a commit SHA default this way. Upstream has no releases or tags.
  default = "5f3a5f26499974c94e83f2b6f4c5db843f3e278b"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ninthwalker/slack-invite"
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
