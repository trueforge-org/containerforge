target "docker-metadata-action" {}

variable "APP" {
  default = "sd-webui"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=AUTOMATIC1111/stable-diffusion-webui versioning=semver
  default = "1.10.1"
}

variable "LICENSE" {
  // UNVERIFIED: AGPL-3.0 per the upstream LICENSE.txt (GNU AGPL v3). Confirm -only vs -or-later.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/AUTOMATIC1111/stable-diffusion-webui"
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
