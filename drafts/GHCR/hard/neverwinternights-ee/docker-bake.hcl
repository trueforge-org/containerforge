target "docker-metadata-action" {}

variable "APP" {
  default = "neverwinternights-ee"
}

variable "VERSION" {
  // BLOCKER: no pinned upstream release or renovate datasource identified (plan section 1 and 10). Do not guess a version.
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // BLOCKER: no open-source license; the game is proprietary. Maintainers must settle the value (plan section 10).
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/704450/"
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
  // amd64 only (plan section 9).
  platforms = [
    "linux/amd64"
  ]
}
