from github import Auth
from github import Github

import os
import yaml

PAT = os.environ.get("PAT", None)
GH_AUTH = Auth.Token(PAT) if PAT else None
GH = Github(auth=GH_AUTH)


def get_repos():
    org = GH.get_organization("linuxserver")
    return org.get_repos()

def get_file(repo, branch, path, is_yaml=False):
    try:
        return repo.get_contents(path, ref=branch).decoded_content.decode("utf-8")
    except:
        return None

def get_last_stable_release(repo):
    for release in repo.get_releases():
        if release.prerelease:
            continue
        return release.tag_name, str(release.published_at)
    return "latest", str(repo.pushed_at)

def get_readme_vars(repo, project_name):
    readme_vars_str = (get_file(repo, "master", "readme-vars.yml", is_yaml=True) or
        get_file(repo, "main", "readme-vars.yml", is_yaml=True) or
        get_file(repo, "develop", "readme-vars.yml", is_yaml=True) or
        get_file(repo, "nightly", "readme-vars.yml", is_yaml=True))

    if not readme_vars_str:
        return None
    
    replace_map = {
        "[{{ project_name|capitalize }}]": project_name,
        "{{ project_name|capitalize }}": project_name,
        "[{{ project_name }}]": project_name,
        "{{ project_name }}": project_name,
        "({{ project_url }})": "",
        "{{ project_url }}": "",
        "{{ arch_x86_64 }}": "x86_64",
        "{{ arch_arm64 }}": "arm64",
    }
    for expression, value in replace_map.items():
        readme_vars_str = readme_vars_str.replace(expression, value)
    
    return yaml.load(readme_vars_str, Loader=yaml.CLoader)

def print_rate_limit():
    ratelimit = GH.get_rate_limit().core
    print(f"Github ratelimit - {ratelimit.remaining}/{ratelimit.limit} resets at {ratelimit.reset}")
