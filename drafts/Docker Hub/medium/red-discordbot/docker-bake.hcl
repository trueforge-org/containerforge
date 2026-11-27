target "docker-metadata-action" {}

variable "APP" {
  default = "red-discordbot"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=Red-DiscordBot versioning=pep440
  default = "3.5.24"
}

variable "LICENSE" {
  // UNVERIFIED: confirm GPL-3.0 against the LICENSE file (GitHub reports GPL-3.0)
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Cog-Creators/Red-DiscordBot"
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
