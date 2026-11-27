target "docker-metadata-action" {}

variable "APP" {
  default = "opengl-desktop-g3"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=VirtualGL/virtualgl versioning=semver
  default = "3.1.5"
}

// UNVERIFIED: the VirtualGL license (believed wxWindows 3.1). Confirm from the package copyright file.
variable "LICENSE" {
  default = "wxWindows"
}

variable "SOURCE" {
  default = "https://github.com/accetto/headless-drawing-g3"
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
