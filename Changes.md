3.0.0ax
=======

- Dockerfile : Removed `cuda-nsight-compute-11-8.x86_64`, `libcublas-devel-11-8-11.11.3.6-1.x86_64`, `sonar-scanner-4.8.0.2856-linux`, and various intermediate installation files to reduce container size.
- CI :
  - Container image is now built with `podman` rather than `docker`.
  - Container image is built with `--squash-all` in order to reduce overall container size.

3.0.0a5
=======

- Dockerfile : Set `OPTIX_ROOT_DIR` environment variable.

3.0.0a4
=======

- Dockerfile :
  - Fixed `sphinx` incompatibility with automatically installed dependencies by installing specific versions of `sphinxcontrib` packages.

3.0.0a3
=======

- Dockerfile :
  - Added `GAFFER_BUILD_ENVIRONMENT="gcc11"` environment variable.

3.0.0a2
=======

- Dockerfile :
  - Set `WORKDIR` to `/`.

3.0.0a1
=======

- Dockerfile :
  - Changed base image to `aswf/ci-base:2023.2`, changes from this image include :
    - Builds are now performed on Rocky 8.8 with glibc 2.28.
    - Updated GCC to 11.2.1.
    - Updated Python to 3.10.11.
  - Removed installation of the following packages as they are provided by the `ci-base` image :
    - `cmake3`, `git`, `patch`, `doxygen`.
    - `bzip2-devel`, `zlib-devel`.
    - `libX11-devel`, `mesa-libGL-devel`, `mesa-libGLU-devel`, `libXmu-devel`, `libXi-devel`.
    - `flex`, `bison`.
    - `xkeyboard-config`, `fontconfig-devel`, `libxkbcommon-x11-devel`.
    - `xcb-util-renderutil-devel`, `xcb-util-wm-devel`, `xcb-util-devel`, `xcb-util-image-devel`, `xcb-util-keysyms-devel`.
    - `xorg-x11-server-Xvfb`.
  - Removed installation of `nasm` as `yasm` is provided by the `ci-base` image.
  - Removed installation of `lz4` and `lz4-devel` as we no longer build Appleseed.
  - Updated `inkscape` to 1.3.2.
  - Updated `scons` to 4.6.0.

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
