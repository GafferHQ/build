# We start with `nvidia/cuda` as it provides a Rocky 8 environment that meets
# the glibc requirements of VFXPlatform 2023 (2.28 or lower), with some of our
# build dependencies already pre-installed.

FROM nvidia/cuda:12.8.0-devel-rockylinux8

# Identify the build environment. This can be used by build processes for
# environment specific behaviour such as naming artifacts built from this
# container.
ENV GAFFER_BUILD_ENVIRONMENT="gcc11"

# As we don't want to inadvertently grab newer versions of our yum-installed
# packages, we use yum-versionlock to keep them pinned. We track the list of
# image packages here, then compare after our install steps to see what was
# added, and only lock those. This saves us storing redundant entries for
# packages installed in the base image.

# To unlock versions, just make sure yum-versionlock.list is empty in the repo
COPY versionlock.sh ./
COPY yum-versionlock.list /etc/yum/pluginconf.d/versionlock.list

RUN yum install -y 'dnf-command(versionlock)' && \
	./versionlock.sh list-installed /tmp/packages && \
#
#
# NOTE: If you add a new yum package here, make sure you update the version
# lock files as follows and commit the changes to yum-versionlock.list:
#
#   ./build-container.py --update-version-locks --new-only
#
# Install Python and pip.
#
	dnf install -y python3.12 && \
	alternatives --set python /usr/bin/python3 && \
	alternatives --set python3 /usr/bin/python3.12 && \
	curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
#
#	We install SCons via `pip install` rather than by
#	`yum install` because this prevents a Cortex build failure
#	caused by SCons picking up the wrong Python version and being
#	unable to find its own modules.
#
	pip install scons==4.10.1 && \
#
# Install CMake.
#
	curl -sSL "https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10-linux-x86_64.sh" -o /tmp/cmake-3.31.10-linux-x86_64.sh && \
	sh /tmp/cmake-3.31.10-linux-x86_64.sh --skip-license --prefix=/usr/local --exclude-subdir && \
	rm -f /tmp/cmake-3.31.10-linux-x86_64.sh && \
#
# Install GCC Toolset 11.
#
	dnf groupinstall -y --setopt=install_weak_deps=False "Development Tools" && \
	dnf install -y gcc-toolset-11 && \
#
# Install packages needed to build Gaffer's dependencies.
#
	dnf config-manager --set-enabled powertools && \
	dnf install -y epel-release && \
	dnf install -y \
		# Required by Boost
		bzip2-devel \
		# Required by JPEG
		yasm \
		# Required by GLEW
		libX11-devel \
		mesa-libGL-devel \
		mesa-libGLU-devel \
		libXmu-devel \
		libXi-devel \
		# Required by Qt
		fontconfig-devel.x86_64 \
		libxkbcommon-x11-devel.x86_64 \
		xcb-util-renderutil-devel \
		xcb-util-wm-devel \
		xcb-util-devel \
		xcb-util-image-devel \
		xcb-util-keysyms-devel \
		xcb-util-cursor-devel \
		# Required by Python
		openssl-devel \
		sqlite-devel \
		# Required by Cortex
		which && \
#
# Install packages needed to generate the
# Gaffer documentation.
#
	dnf install -y \
		xorg-x11-server-Xvfb \
		mesa-dri-drivers.x86_64 \
		metacity \
		gnome-themes-standard && \
# Note: When updating these, also update the MacOS setup in .github/workflows/main.yaml
# (in GafferHQ/gaffer).
	pip install \
		sphinx==4.3.1 \
		sphinxcontrib-applehelp==1.0.4 \
		sphinxcontrib-devhelp==1.0.2 \
		sphinxcontrib-htmlhelp==2.0.1 \
		sphinxcontrib-jsmath==1.0.1 \
		sphinxcontrib-serializinghtml==1.1.5 \
		sphinxcontrib-qthelp==1.0.3 \
		sphinx_rtd_theme==1.0.0 \
		myst-parser==0.15.2 \
		docutils==0.17.1 && \
#
# Install Inkscape 1.3.2
# Inkscape is distributed as an AppImage. AppImages seemingly can't be run (easily?) in a
# container as they require FUSE, so we extract the image so its contents can be run directly.
	mkdir /opt/inkscape-1.3.2 && \
	cd /opt/inkscape-1.3.2 && \
	curl -O https://media.inkscape.org/dl/resources/file/Inkscape-091e20e-x86_64.AppImage && \
	chmod a+x Inkscape-091e20e-x86_64.AppImage && \
	./Inkscape-091e20e-x86_64.AppImage --appimage-extract && \
	ln -s /opt/inkscape-1.3.2/squashfs-root/AppRun /usr/local/bin/inkscape && \
	rm -f Inkscape-091e20e-x86_64.AppImage && \
	cd - && \
#
# Install Optix headers for Cycles and OSL.
#
	mkdir /usr/local/NVIDIA-OptiX-SDK-8.0.0 && \
	cd /usr/local/NVIDIA-OptiX-SDK-8.0.0 && \
	curl -sL https://github.com/NVIDIA/optix-dev/archive/refs/tags/v8.0.0.tar.gz | tar -xz --strip-components=1 && \
	cd - && \
#
# Install meson as it is needed to build LibEpoxy if building Cycles with USD support.
#
	pip install meson && \
#
# Install ninja as it is needed to build PySide.
#
	curl -sL https://github.com/ninja-build/ninja/releases/download/v1.13.2/ninja-linux.zip -o /tmp/ninja-linux.zip && \
	unzip -n -d /usr/local/bin /tmp/ninja-linux.zip ninja && \
	rm -f /tmp/ninja-linux.zip && \
#
# Install libraries needed by RenderMan.
#
	dnf install -y ncurses-compat-libs && \
#
# Install libraries needed by PySide 6.5.
#
	dnf install -y patchelf && \
#
# Install podman. Needed to test RenderMan 27 as it can't run in this Rocky 8 container.
#
	dnf install -y podman && \
#
# Trim out a few things we don't need from `nvidia/cuda`. We run out of disk space
# on GitHub Actions if our container is too big. CUDA comes with all sorts of
# bells and whistles we don't need, and is responsible for at least 5Gb of the
# total image size.
	rm -rf /usr/local/doc && \
	rm -rf /usr/share/doc && \
	dnf remove -y \
		java-1.8.0-openjdk-headless \
		cuda-nsight-compute-12-8.x86_64 \
		libcublas-12-8 libcublas-devel-12-8 \
		libnccl libnccl-devel \
		libnpp-12-8 libnpp-devel-12-8 \
		cuda-cupti-12-8 cuda-compat-12-8 && \
#
# After trimming down CUDA, reinstall only the specific CUDA dependencies
# required for OSL Optix builds.
	dnf install -y \
		cuda-nvrtc-devel-12-8 \
		libcurand-devel-12-8 && \
#
# Now we've installed all our packages, update yum-versionlock for all the
# new packages so we can copy the versionlock.list out of the container when we
# want to update the build env.
# If there were already locks in the list from the source checkout then the
# correct version will already be installed and we just ignore this...
	./versionlock.sh lock-new /tmp/packages && \
#
# Clean the dnf caches once we're finished calling any dnf/yum commands. Updating
# the versionlock list also populates the cache, so this cleanup is best run last.
	dnf clean all && \
	rm -rf /var/cache/dnf && \
	rm -rf /var/log/*

# Inkscape 1.3.2 prints "Setting _INKSCAPE_GC=disable as a workaround for broken libgc"
# every time it is run, so we set it ourselves to silence that
ENV _INKSCAPE_GC="disable"

# Make the Optix SDK and CUDA available to builds that require them.
ENV OPTIX_ROOT_DIR=/usr/local/NVIDIA-OptiX-SDK-8.0.0
ENV CUDA_PATH=/usr/local/cuda-12.8

# Enable the software collections we want by default, no matter how we enter the
# container. For details, see :
#
# https://austindewey.com/2019/03/26/enabling-software-collections-binaries-on-a-docker-image/

RUN printf "unset BASH_ENV PROMPT_COMMAND ENV\nsource scl_source enable gcc-toolset-11\n" > /usr/bin/scl_enable

ENV BASH_ENV="/usr/bin/scl_enable" \
	ENV="/usr/bin/scl_enable" \
	PROMPT_COMMAND=". /usr/bin/scl_enable"
