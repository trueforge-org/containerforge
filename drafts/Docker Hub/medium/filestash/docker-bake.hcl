target "docker-metadata-action" {}

variable "APP" {
  default = "filestash"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/mickael-kerjean/filestash currentValue=master
  // Pinned to a master commit (no release tags). Renovate proposes a bump on each upstream push.
  default = "331fb8be7255a0a24a16c3f7c1e6710ffec428c6"
}

variable "LICENSE" {
  // UNVERIFIED: upstream may allow "or later"; confirm against LICENSE before release.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/mickael-kerjean/filestash"
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
