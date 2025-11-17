import lsio_github as gh
from keyvaluestore import KeyValueStore, set_db_schema
from models import Architecture, Changelog, Tag, EnvVar, Volume, Port, Config
from models import Custom, SecurityOpt, Device, Cap, Hostname, MacAddress, Image
from models import Repository, ImagesData, ImagesResponse, IMAGES_SCHEMA_VERSION, SCARF_SCHEMA_VERSION

import datetime
import json
import os
import requests
import time
import traceback

CI = os.environ.get("CI", None)
INVALIDATE_HOURS = int(os.environ.get("INVALIDATE_HOURS", "24"))
SCARF_TOKEN = os.environ.get("SCARF_TOKEN", None)


def get_tags(readme_vars):
    if "development_versions_items" not in readme_vars:
        return [Tag(tag="latest", desc="Stable releases")], True
    tags = []
    stable = False
    for item in readme_vars["development_versions_items"]:
        if item["tag"] == "latest":
            stable = True
        tags.append(Tag(tag=item["tag"], desc=item["desc"]))
    return tags, stable

def get_architectures(readme_vars):
    if "available_architectures" not in readme_vars:
        return [Architecture(arch="x86_64", tag="amd64-latest")]
    archs = []
    for item in readme_vars["available_architectures"]:
        archs.append(Architecture(arch=item["arch"], tag=item["tag"]))
    return archs

def get_changelog(readme_vars):
    if "changelogs" not in readme_vars:
        return None, None
    changelog = []
    for item in readme_vars["changelogs"][0:3]:
        date = item["date"][0:-1]
        normalized_date = str(datetime.datetime.strptime(date, "%d.%m.%y").date())
        changelog.append(Changelog(date=normalized_date, desc=item["desc"]))
    first_changelog = readme_vars["changelogs"][-1]
    initial_date = first_changelog["date"][0:-1]
    normalized_initial_date = str(datetime.datetime.strptime(initial_date, "%d.%m.%y").date())
    return changelog, normalized_initial_date

def get_description(readme_vars):
    description = readme_vars.get("project_blurb", "No description")
    description = description.replace("\n", " ").strip(" \t\n\r")
    return description

def get_env_vars(readme_vars):
    env_vars = []
    if readme_vars.get("common_param_env_vars_enabled", False):
        env_vars.extend([
            EnvVar(name="PUID", value="1000", desc="User ID", optional=False),
            EnvVar(name="PGID", value="1000", desc="Group ID", optional=False),
            EnvVar(name="TZ", value="Etc/UTC", desc="Timezone", optional=False),
        ])
    if "param_env_vars" in readme_vars:
        for item in readme_vars["param_env_vars"]:
            env_vars.append(EnvVar(name=item["env_var"], value=item["env_value"], desc=item["desc"], optional=False))
    if "opt_param_env_vars" in readme_vars:
        for item in readme_vars["opt_param_env_vars"]:
            env_vars.append(EnvVar(name=item["env_var"], value=item["env_value"], desc=item["desc"], optional=True))
    return env_vars if env_vars else None

def get_volumes(readme_vars):
    volumes = []
    if "param_volumes" in readme_vars:
        for item in readme_vars["param_volumes"]:
            volumes.append(Volume(path=item["vol_path"], host_path=item["vol_host_path"], desc=item["desc"], optional=False))
    if "opt_param_volumes" in readme_vars:
        for item in readme_vars["opt_param_volumes"]:
            volumes.append(Volume(path=item["vol_path"], host_path=item["vol_host_path"], desc=item["desc"], optional=True))
    return volumes if volumes else None

def get_ports(readme_vars):
    ports = []
    if "param_ports" in readme_vars:
        for item in readme_vars["param_ports"]:
            ports.append(Port(external=item["external_port"], internal=item["internal_port"], desc=item["port_desc"], optional=False))
    if "opt_param_ports" in readme_vars:
        for item in readme_vars["opt_param_ports"]:
            ports.append(Port(external=item["external_port"], internal=item["internal_port"], desc=item["port_desc"], optional=True))
    return ports if ports else None

def get_custom(readme_vars):
    custom = []
    if "custom_params" in readme_vars:
        for item in readme_vars["custom_params"]:
            custom.append(Custom(name=item["name"], name_compose=item["name_compose"], value=item["value"], desc=item["desc"], optional=False))
    if "opt_custom_params" in readme_vars:
        for item in readme_vars["opt_custom_params"]:
            custom.append(Custom(name=item["name"], name_compose=item["name_compose"], value=item["value"], desc=item["desc"], optional=True))
    return custom if custom else None

def get_security_opt(readme_vars):
    security_opts = []
    if "security_opt_param_vars" in readme_vars:
        for item in readme_vars["security_opt_param_vars"]:
            security_opts.append(SecurityOpt(run_var=item["run_var"], compose_var=item["compose_var"], desc=item["desc"], optional=False))
    if "opt_security_opt_param_vars" in readme_vars:
        for item in readme_vars["opt_security_opt_param_vars"]:
            security_opts.append(SecurityOpt(run_var=item["run_var"], compose_var=item["compose_var"], desc=item["desc"], optional=True))
    return security_opts if security_opts else None

def get_devices(readme_vars):
    devices = []
    if "param_devices" in readme_vars:
        for item in readme_vars["param_devices"]:
            devices.append(Device(path=item["device_path"], host_path=item["device_host_path"], desc=item["desc"], optional=False))
    if "opt_param_devices" in readme_vars:
        for item in readme_vars["opt_param_devices"]:
            devices.append(Device(path=item["device_path"], host_path=item["device_host_path"], desc=item["desc"], optional=True))
    return devices if devices else None

def get_caps(readme_vars):
    caps = []
    if "cap_add_param_vars" in readme_vars:
        for item in readme_vars["cap_add_param_vars"]:
            caps.append(Cap(cap_add=item["cap_add_var"], desc=item["desc"], optional=False))
    if "opt_cap_add_param_vars" in readme_vars:
        for item in readme_vars["opt_cap_add_param_vars"]:
            caps.append(Cap(cap_add=item["cap_add_var"], desc=item["desc"], optional=True))
    return caps if caps else None

def get_hostname(readme_vars):
    include_hostname = readme_vars.get("param_usage_include_hostname", False)
    if not include_hostname:
        return None
    optional = include_hostname == "optional"
    hostname = readme_vars.get("param_hostname", False)
    return Hostname(hostname=hostname, desc=readme_vars.get("param_hostname_desc", ""), optional=optional)

def get_mac_address(readme_vars):
    include_mac_address = readme_vars.get("param_usage_include_mac_address", False)
    if not include_mac_address:
        return None
    optional = include_mac_address == "optional"
    hostname = readme_vars.get("param_mac_address", False)
    return MacAddress(mac_address=hostname, desc=readme_vars.get("param_mac_address_desc", ""), optional=optional)

def get_image(repo, scarf_data):
    print(f"Processing {repo.name}")
    if not repo.name.startswith("docker-") or repo.name.startswith("docker-baseimage-"):
        return None
    project_name = repo.name.replace("docker-", "")
    readme_vars = gh.get_readme_vars(repo, project_name)
    if not readme_vars:
        return None
    categories = readme_vars.get("project_categories", "")
    if "Internal" in categories:
        return None
    tags, stable = get_tags(readme_vars)
    deprecated = readme_vars.get("project_deprecation_status", False)
    version, version_timestamp = gh.get_last_stable_release(repo)
    application_setup = None
    if readme_vars.get("app_setup_block_enabled", False):
        application_setup = f"{repo.html_url}?tab=readme-ov-file#application-setup"
    changelog, initial_date = get_changelog(readme_vars)
    config = Config(
        application_setup=application_setup,
        readonly_supported=readme_vars.get("readonly_supported", None),
        nonroot_supported=readme_vars.get("nonroot_supported", None),
        privileged=readme_vars.get("privileged", None),
        networking=readme_vars.get("param_net", None),
        hostname=get_hostname(readme_vars),
        mac_address=get_mac_address(readme_vars),
        env_vars=get_env_vars(readme_vars),
        volumes=get_volumes(readme_vars),
        ports=get_ports(readme_vars),
        custom=get_custom(readme_vars),
        security_opt=get_security_opt(readme_vars),
        devices=get_devices(readme_vars),
        caps=get_caps(readme_vars),
    )
    return Image(
        name=project_name,
        initial_date=initial_date,
        github_url=repo.html_url,
        project_url=readme_vars.get("project_url", None),
        project_logo=readme_vars.get("project_logo", None),
        description=get_description(readme_vars),
        version=version,
        version_timestamp=version_timestamp,
        category=categories,
        stable=stable,
        deprecated=deprecated,
        stars=repo.stargazers_count,
        monthly_pulls=scarf_data.get(project_name, None),
        tags=tags,
        architectures=get_architectures(readme_vars),
        changelog=changelog,
        config=config,
    )

def update_images():
    with KeyValueStore(invalidate_hours=INVALIDATE_HOURS, readonly=False) as kv:
        is_current_schema = kv.is_current_schema("images", IMAGES_SCHEMA_VERSION)
        if ("images" in kv and is_current_schema) or CI == "1":
            print(f"{datetime.datetime.now()} - images skipped - already updated")
            return
        print(f"{datetime.datetime.now()} - updating images")
        images = []
        scarf_data = json.loads(kv["scarf"])
        repos = gh.get_repos()
        for repo in sorted(repos, key=lambda repo: repo.name):
            image = get_image(repo, scarf_data)
            if not image:
                continue
            images.append(image)
        
        data = ImagesData(repositories=Repository(linuxserver=images))
        last_updated = datetime.datetime.now(datetime.timezone.utc).isoformat(" ", "seconds")
        response = ImagesResponse(status="OK", last_updated=last_updated, data=data)
        new_state = response.model_dump_json(exclude_none=True)
        kv.set_value("images", new_state, IMAGES_SCHEMA_VERSION)
        print(f"{datetime.datetime.now()} - updated images")

def get_monthly_pulls():
    pulls_map = {}
    response = requests.get("https://api.scarf.sh/v2/packages/linuxserver-ci/overview?per_page=1000", headers={"Authorization": f"Bearer {SCARF_TOKEN}"})
    results = response.json()["results"]
    for result in results:
        name = result["package"]["name"].replace("linuxserver/", "")
        if "total_installs" not in result:
            continue
        monthly_pulls = result["total_installs"]
        pulls_map[name] = monthly_pulls
    return pulls_map

def update_scarf():
    with KeyValueStore(invalidate_hours=INVALIDATE_HOURS, readonly=False) as kv:
        is_current_schema = kv.is_current_schema("scarf", SCARF_SCHEMA_VERSION)
        if ("scarf" in kv and is_current_schema) or CI == "1":
            print(f"{datetime.datetime.now()} - scarf skipped - already updated")
            return
        print(f"{datetime.datetime.now()} - updating scarf")
        pulls_map = get_monthly_pulls()
        if not pulls_map:
            return
        new_state = json.dumps(pulls_map)
        kv.set_value("scarf", new_state, SCARF_SCHEMA_VERSION)
        print(f"{datetime.datetime.now()} - updated scarf")

def update_status(status):
    with KeyValueStore(invalidate_hours=0, readonly=False) as kv:
        print(f"{datetime.datetime.now()} - updating status")
        kv.set_value("status", status, 0)
        print(f"{datetime.datetime.now()} - updated status")

def main():
    try:
        set_db_schema()
        while True:
            gh.print_rate_limit()
            update_scarf()
            update_images()
            gh.print_rate_limit()
            update_status("Success")
            time.sleep(INVALIDATE_HOURS*60*60)
    except:
        print(traceback.format_exc())
        update_status("Failed")
        time.sleep(INVALIDATE_HOURS*60*60)

if __name__ == "__main__":
    main()
