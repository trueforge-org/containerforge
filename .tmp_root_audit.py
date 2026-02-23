import subprocess
import pathlib
import re

repo = pathlib.Path('/Users/kjeld/GIT/trueforge/containers')
cmd = "git log --since='120 days ago' --diff-filter=A --name-only --pretty=format: -- apps/*/docker-bake.hcl"
out = subprocess.check_output(cmd, shell=True, cwd=repo, text=True)
apps = sorted({line.strip().rsplit('/docker-bake.hcl', 1)[0] for line in out.splitlines() if line.strip()})

exclude = [
    re.compile(r"COPY\s+\.?/root/?\s", re.I),
    re.compile(r"commits/.*/root/"),
    re.compile(r"root/defaults"),
    re.compile(r"rootfs"),
    re.compile(r"From \./processed/.*/root/"),
]

results = []
for app in apps:
    app_path = repo / app
    for path in app_path.rglob('*'):
        if not path.is_file():
            continue
        try:
            text = path.read_text(errors='ignore')
        except Exception:
            continue
        for idx, line in enumerate(text.splitlines(), start=1):
            if '/root' not in line:
                continue
            if line.lstrip().startswith('#'):
                continue
            if any(rx.search(line) for rx in exclude):
                continue
            results.append((str(path.relative_to(repo)), idx, line.strip()))

print(f"new_apps={len(apps)}")
print(f"hits={len(results)}")
for path, line_no, line in results:
    print(f"{path}:{line_no}:{line}")
