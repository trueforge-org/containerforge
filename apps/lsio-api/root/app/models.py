from pydantic import BaseModel

# Increment when updating schema or forcing an update on start
IMAGES_SCHEMA_VERSION = 3
SCARF_SCHEMA_VERSION = 1


class Tag(BaseModel):
    tag: str
    desc: str

class Architecture(BaseModel):
    arch: str
    tag: str

class Changelog(BaseModel):
    date: str
    desc: str

class Volume(BaseModel):
    path: str
    host_path: str
    desc: str
    optional: bool

class Port(BaseModel):
    external: str
    internal: str
    desc: str
    optional: bool

class EnvVar(BaseModel):
    name: str
    value: str
    desc: str
    optional: bool

class EnvVar(BaseModel):
    name: str
    value: str
    desc: str
    optional: bool

class Custom(BaseModel):
    name: str
    name_compose: str
    value: str | list[str]
    desc: str
    optional: bool

class SecurityOpt(BaseModel):
    run_var: str
    compose_var: str
    desc: str
    optional: bool

class Device(BaseModel):
    path: str
    host_path: str
    desc: str
    optional: bool

class Cap(BaseModel):
    cap_add: str
    desc: str
    optional: bool

class Hostname(BaseModel):
    hostname: str
    desc: str
    optional: bool

class MacAddress(BaseModel):
    mac_address: str
    desc: str
    optional: bool

class Config(BaseModel):
    application_setup: str | None = None
    readonly_supported: bool | None = None
    nonroot_supported: bool | None = None
    privileged: bool | None = None
    networking: str | None = None
    hostname: Hostname | None = None
    mac_address: MacAddress | None = None
    env_vars: list[EnvVar] | None = None
    volumes: list[Volume] | None = None
    ports: list[Port] | None = None
    custom: list[Custom] | None = None
    security_opt: list[SecurityOpt] | None = None
    devices: list[Device] | None = None
    caps: list[Cap] | None = None

class Image(BaseModel):
    name: str
    initial_date: str | None = None
    github_url: str
    project_url: str | None = None
    project_logo: str | None = None
    description: str
    version: str
    version_timestamp: str
    category: str
    stable: bool
    deprecated: bool
    stars: int
    monthly_pulls: int | None = None
    tags: list[Tag]
    architectures: list[Architecture]
    changelog: list[Changelog] | None = None
    config: Config | None  = None

class Repository(BaseModel):
    linuxserver: list[Image]

class ImagesData(BaseModel):
    repositories: Repository

class ImagesResponse(BaseModel):
    status: str
    last_updated: str
    data: ImagesData

    def exclude_config(self):
        for image in self.data.repositories.linuxserver:
            image.config = None

    def exclude_deprecated(self):
        images = self.data.repositories.linuxserver
        self.data.repositories.linuxserver = list(filter(lambda image: not image.deprecated, images))
