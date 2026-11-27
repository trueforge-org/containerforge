target "docker-metadata-action" {}

variable "APP" {
  default = "ollama"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=open-webui versioning=pep440
  default = "0.13.5"
}

variable "LICENSE" {
  default = "Open WebUI License"
}

variable "SOURCE" {
  default = "https://github.com/open-webui/open-webui"
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
