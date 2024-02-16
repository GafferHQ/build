# We start with CentOS 7, because it is commonly used in production, and meets
# the glibc requirements of VFXPlatform 2022 (2.17 or lower).

FROM centos:7.9.2009

# Identify the build environment. This can be used by build processes for
# environment specific behaviour such as naming artifacts built from this
# container.
ENV GAFFER_BUILD_ENVIRONMENT="gcc9"

# As we don't want to inadvertently grab newer versions of our yum-installed
# packages, we use yum-versionlock to keep them pinned. We track the list of
# image packages here, then compare after our install steps to see what was
# added, and only lock those. This saves us storing redundant entires for
# packages installed in the base image.

# To unlock versions, just make sure yum-versionlock.list is empty in the repo
COPY versionlock.sh ./
COPY yum-versionlock.list /etc/yum/pluginconf.d/versionlock.list

RUN yum install -y yum-versionlock && \
	./versionlock.sh list-installed /tmp/packages && \
#
#
# NOTE: If you add a new yum package here, make sure you update the version
# lock files as follows and commit the changes to yum-versionlock.list:
#
#   ./build-docker.py --update-version-locks --new-only
#
# We have to install scl as a separate yum command for some reason
# otherwise we get `scl not found` errors...
#
	yum install -y centos-release-scl && \
	yum install -y devtoolset-9 && \
#
#	Install Python 3, and enable it so that `pip install` installs modules for
#	it rather than the system Python (which is stuck at the unsupported 2.7).
	yum install -y rh-python38 && \
	source /opt/rh/rh-python38/enable && \
#
#	Install CMake, SCons, and other miscellaneous build tools.
#	We install SCons via `pip install --egg` rather than by
#	`yum install` because this prevents a Cortex build failure
#	caused by SCons picking up the wrong Python version and being
#	unable to find its own modules.
#
	yum install -y epel-release && \
#
	curl -L "https://github.com/Kitware/CMake/releases/download/v3.27.2/cmake-3.27.2-Linux-x86_64.sh" -o /tmp/cmake-3.27.2-Linux-x86_64.sh && \
	sh /tmp/cmake-3.27.2-Linux-x86_64.sh --skip-license --prefix=/usr/local --exclude-subdir && \
	rm /tmp/cmake-3.27.2-Linux-x86_64.sh && \
#
	pip install scons==4.6.0 && \
#
	yum install -y \
		git \
		patch \
		doxygen && \
#
#	Install boost dependencies (needed by boost::iostreams)
#
	yum install -y bzip2-devel && \
#
#	Install JPEG dependencies
#
	yum install -y nasm && \
#
#	Install PNG dependencies && \
#
	yum install -y zlib-devel && \
#
#	Install GLEW dependencies
#
	yum install -y \
		libX11-devel \
		mesa-libGL-devel \
		mesa-libGLU-devel \
		libXmu-devel \
		libXi-devel && \
#
#	Install OSL dependencies
#
	yum install -y \
		flex \
		bison && \
#
#	Install Qt dependencies
#
	yum install -y \
		xkeyboard-config.noarch \
		fontconfig-devel.x86_64 \
		libxkbcommon-x11-devel.x86_64 \
		xcb-util-renderutil-devel \
		xcb-util-wm-devel \
		xcb-util-devel \
		xcb-util-image-devel \
		xcb-util-keysyms-devel && \
#
#	Install Appleseed dependencies
#
	yum install -y \
		lz4 lz4-devel && \
#
#	Install Python dependencies (needed for Python ssl and sqlite3 modules)
#
	yum install -y \
		openssl11-devel \
		sqlite-devel && \
#
#	Symlink openssl11 libs and headers to a location where Python's `configure` script can find them
#
	mkdir /usr/local/ssl && \
	ln -s /usr/lib64/openssl11 /usr/local/ssl/lib && \
	ln -s /usr/include/openssl11 /usr/local/ssl/include && \
#
# Install packages needed to generate the
# Gaffer documentation.
#
	yum install -y \
		xorg-x11-server-Xvfb \
		mesa-dri-drivers.x86_64 \
		metacity \
		gnome-themes-standard && \
# Note: When updating these, also update the MacOS setup in .github/workflows/main.yaml
# (in GafferHQ/gaffer).
	pip install \
		urllib3==1.26.18 \
		sphinx==4.3.1 \
		sphinx_rtd_theme==1.0.0 \
		myst-parser==0.15.2 \
		docutils==0.17.1 && \
#
	yum install -y inkscape && \
#
# Now we've installed all our packages, update yum-versionlock for all the
# new packages so we can copy the versionlock.list out of the container when we
# want to update the build env.
# If there were already locks in the list from the source checkout then the
# correct version will already be installed and we just ignore this...
	./versionlock.sh lock-new /tmp/packages

# Enable the software collections we want by default, no matter how we enter the
# container. For details, see :
#
# https://austindewey.com/2019/03/26/enabling-software-collections-binaries-on-a-docker-image/

RUN printf "unset BASH_ENV PROMPT_COMMAND ENV\nsource scl_source enable devtoolset-9 rh-python38\n" > /usr/bin/scl_enable

ENV BASH_ENV="/usr/bin/scl_enable" \
	ENV="/usr/bin/scl_enable" \
	PROMPT_COMMAND=". /usr/bin/scl_enable"
