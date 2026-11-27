target "docker-metadata-action" {}

variable "APP" {
  default = "memories-of-mars"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // UNVERIFIED: tracks the steamcmd base only; no game version exists (Steam content).
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: the game is proprietary Steam content; this is the license of the ContainerForge wrapper.
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  // UNVERIFIED: website from the draft, not fetched. The Steam search page is not an app page.
  default = "https://memoriesofmars.com"
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
    "linux/amd64"
  ]
}
