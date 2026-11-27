target "docker-metadata-action" {}

variable "APP" {
  default = "genea"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=genea-app/genea-app packageName=https://github.com/genea-app/genea-app currentDigest=<pin-commit-sha>
  // UNVERIFIED: "main" is a placeholder; replace with a full commit SHA of main before building
  default = "main"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/genea-app/genea-app"
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
