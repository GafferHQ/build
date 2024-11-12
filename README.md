Overview
--------

This project provides a consistent build environment used for all releases
of GafferHQ/gaffer and GafferHQ/dependencies. It is not necessary to use this
environment to make your own builds, but it may be useful as a reference.

Prerequisites
-------------

- ARNOLD_ROOT environment variable pointing to installation of Arnold 7.1 or later
- DELIGHT environment variable pointing to installation of 3delight NSI 2.x
- Docker 17.05 or later

Usage
-----

Build and upload a gaffer release :

`./build.py --version 1.4.0.0 --upload 1`

Build and upload a dependencies release :

`./build.py --project dependencies --version 8.0.0 --upload 1`

Make a Linux release using a container on a Mac :

`./build.py --container 1 --arnoldRoot /path/to/linux/arnoldRoot --delightRoot /path/to/linux/delightRoot --version 1.4.0.0 --upload 1`

Docker Cheatsheet
-----------------

Remove stopped containers and dangling images :

`docker system prune`

Remove all images, not just temporary container images :

`docker system prune -a`

Debug a stopped build container :

```
# Find the container of interest
docker ps -a
# Make a new image from container
docker commit <containerID> <imageName>
# Run interactive session in new image
docker run -it <imageName> /bin/bash
```

Building the build environment
------------------------------

Gaffer and Dependency builds are made using pre-published Docker images. These
images are built from the Dockerfile in this repository. The `build-docker.py`
script aids the building of the images. For example :

 `./build-docker.py --tag 1.1.0`

> NOTE: The `build-docker.py` uses the simpler flag syntax for most of it options,
> this means its a little different to `build.py`, we aim to update that over
> time to match.

In order to produce this image, we make heavy use of `yum` to install the
packages required to build Gaffer and it's dependencies. As we don't manually
specify every version of every package we risk a non-deterministic build
environment. To get around this, we make use of `yum versionlock`. The
`yum-versionlock.list` file in the repository is copied into the base Centos
image such that when `yum` runs, it will repeatably install the expected
versions. In order to help manage this, the `build.py` script has a few options
to aid updating of the lock list when new packages are added or updates are required.

 - `--update-version-locks` When set this will ignore all version locks and
   update `yum-versionlock.list` to the 'current' version of all packages
   installed during docker's build. The revised file can then be committed and tagged,
   and a new docker image released.

 - `--new-only` When set the existing version lock list will not be cleared.
   This allows the versions to be locked for any new packages installed by
   changes to the `Dockerfile` without affecting the versions of existing
   packages.

### Cheat sheet

Added a new package to the image, installed with yum in the Dockerfile:

`./build-docker.py --update-version-locks --new-only --tag x.x.x`

Update all packages to latest:

`./build-docker.py --update-version-locks --tag x.x.x`

### Releasing a new version of the build environment

Docker images are automatically published to the GitHub Container Registry
whenever a new release is made via https://github.com/GafferHQ/build/releases.
This is performed by the `.github/workflows/dockerImagePublish.yml` workflow.
Once published, the images can be used by `./build.py` and by the CI process
for `GafferHQ/gaffer`.

### A note on Docker's caching mechanism

Docker caches layers based on the `RUN` command string. As such, it does not
known when the version lock file changes. the `--update-version-locks` command
will always run with `--no-cache` set, but if you've just pulled some updates
from upstream, and are re-building on your machine, you may find docker will
be using an out-of-date cache of one or more of the layers.

As such, its recommended to use `--no-cache` whenever performing release
builds.

