# libsass (PyPI)

Source URL(s) + fetch date:
- https://pypi.org/project/libsass/
- Fetched 2026-11-26

## Version
- Latest: libsass 0.23.0, released Jan 6, 2024.
- Requires-Python: `>=3.8` in metadata. Description text says "CPython 3.7+, and PyPy 3" (inconsistent with metadata).

## Wheels
Five prebuilt wheels, all `cp38-abi3`:
- `libsass-0.23.0-cp38-abi3-win_amd64.whl`
- `libsass-0.23.0-cp38-abi3-win32.whl`
- `libsass-0.23.0-cp38-abi3-manylinux_2_5_x86_64.manylinux1_x86_64.whl` (Linux glibc x86-64 only)
- `libsass-0.23.0-cp38-abi3-macosx_14_0_arm64.whl`
- `libsass-0.23.0-cp38-abi3-macosx_11_0_x86_64.whl`
- Source distribution `libsass-0.23.0.tar.gz` (316.1 kB).
- No Linux aarch64 wheel is listed. On linux/arm64 pip would need the sdist and a C++ compiler (page note: "needs a C++ compiler supporting features from the recent C++ standard").

## Classifiers
Python 3, Python 3 Only, CPython and PyPy implementations, Stackless. No minor-version classifiers listed. No Ruby or Node.js needed.

## Relevance
Kitana pins `libsass==0.21.0`. Plan section 1 says 0.21.0 fails to build on Python 3.15.2 locally and proposes unpinning to 0.23.0. Plan's "UNVERIFIED for aarch64" is consistent with this page: no aarch64 Linux wheel, so arm64 builds fall back to compiling the sdist.
