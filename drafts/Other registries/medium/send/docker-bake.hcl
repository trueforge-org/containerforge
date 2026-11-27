target "docker-metadata-action" {}

variable "APP" {
  default = "send"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://gitlab.com/timvisee/send currentValue=master
  // UNVERIFIED: placeholder. Replace with a pinned commit SHA on master before the first build.
  // The upstream publishes no releases, so a commit SHA is the only pin available.
  default = "UNVERIFIED-COMMIT-SHA"
}

variable "LICENSE" {
  // MPL-2.0 per the upstream README. Confirm against the LICENSE file of the pinned commit.
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://gitlab.com/timvisee/send"
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
