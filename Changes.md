2.x.x
=====

- Dockerfile :
  - Removed `openssl-devel` package.
  - Symlinked `openssl11-devel` headers and libraries into `/usr/local/ssl` so they can be automatically found when building Python.

2.1.1
=====

- Dockerfile :
  - Fixed issues with `github` module on CI by installing `urllib3` 1.26.18.

2.1.0
=====

- Dockerfile :
  - Added `GAFFER_BUILD_ENVIRONMENT="gcc9"` environment variable.
  - Added `sqlite-devel` package necessary for building Python with `sqlite3` support.
  - Added `openssl-devel` and `openssl11-devel` packages necessary for building Python with support for OpenSSL 1.1.1.
  - Updated SCons to 4.6.0.
  - Updated CMake to 3.27.2.

2.0.0
=====

- Dockerfile :
  - Updated GCC to 9.3.1.
  - Updated Python to 3.8.11.
  - Replaced `recommonmark` with `myst-parser`.

1.3.0
=====

- build.py : Added `--pythonVariant` argument.
- Dockerfile :
  - Added `xcb` packages necessary for building Qt 5.15.
  - Fixed `pip` incompatibility with Python 2.

1.2.0
=====

- Dockerfile :
  - Switched SCL packages to the `7.6.1810` vault.
  - Updated sundry SCL dependency versions.
  - Added automatic `pip` upgrade to latest supported version.
  - Added `libxkb-common-x11-devel` package.
  - Updated `sphinx` to 1.8.1.

1.1.0
=====

- build.py :
  - Added support for building `GafferRenderman`.
  - Moved to GitHub Packages hosted Docker image.
- Dockerfile :
  - Added `git` to the build image.
  - Added `lz4` and `lz4-devel` to the image.
  - Updated package versions to latest.

 1.0.0
 =====

 - Initial release supporting version-locked container build with scl devtoolset-6.
