target "docker-metadata-action" {}

variable "APP" {
  default = "tdarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=HaveAGitGat/Tdarr versioning=loose
  // 3.10.00 is the latest release tag per the context (plan says re-check 3.09.00 vs 3.10.00). loose, not semver, because of the leading zero.
  default = "3.10.00"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION. Read the LICENSE file before setting this.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/HaveAGitGat/Tdarr"
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
