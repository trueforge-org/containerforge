target "docker-metadata-action" {}

variable "APP" {
  default = "fivem"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource for the rolling Cfx runtime (master tree, no LATEST file).
  // 38781 is the highest Linux build number on the Cfx docs page. It is a label only, see plan section 10.
  default = "38781"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION for citizenfx/fivem. Set the real license after reading the runtime terms.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/citizenfx/fivem"
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
  // amd64 only: the Cfx runtime has no arm64 build
  platforms = [
    "linux/amd64"
  ]
}
