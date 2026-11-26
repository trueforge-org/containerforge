# root.cern site (home + install page)

Sources: https://root.cern (home, fetched 2026-11-26) and https://root.cern/install/ (follow-up, merged).

## Releases (home page snapshot)
- Latest Releases list: 6.42.00, 6.42.00-rc1, 6.40.04, 6.40.02, 6.40.00 (no dates shown).
- Home page header: "6.40.04 Release Notes".

## Install page (/install/)
- Sections: Install via package manager (Conda, Arch Linux), LCG releases on CVMFS, Run in a Docker container.
- States "latest stable ROOT release is 6.40.04".
- Binary install steps: install system deps via package manager; download release for platform (`root_v6.40.04.Linux-<distro>-x86_64-gcc<ver>.tar.gz`); unpack; source `bin/thisroot.sh`.
- Example asset naming: `root_v6.40.04.Linux-almalinux9.8-x86_64-gcc11.5.tar.gz`.

## Gotchas
- Home page lists 6.42.00 as latest release while the install page still says 6.40.04 is latest stable. Conflict, unresolved; check GitHub release list before pinning.
