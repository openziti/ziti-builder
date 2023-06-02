# this is the x86 container image used by GitHub Actions and developers to
# cross-compile Ziti projects that use CMake

# pin the cmake version to ensure repeatable builds
ARG CMAKE_VERSION="3.26.3"

# Ubuntu Bionic 18.04 LTS has GLIBC 2.27
FROM ubuntu:bionic

ARG CMAKE_VERSION
ARG XDG_CONFIG_HOME

LABEL org.opencontainers.image.authors="support@netfoundry.io"

ENV DEBIAN_FRONTEND=noninteractive
ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1
ENV TZ=UTC

USER root

ENV PATH="/usr/local/:${PATH}"
# used by git to find global config in container that is writeable by the
# developer's UID
ENV GIT_CONFIG_GLOBAL="/tmp/ziti-builder-gitconfig"
# used by build scripts to detect running in docker
ENV BUILD_ENVIRONMENT="ziti-builder-docker"

RUN apt-get update \
    && apt-get -y install \
        build-essential \
        crossbuild-essential-armhf \
        crossbuild-essential-arm64 \
        curl zip unzip tar \
        doxygen \
        git \
        graphviz \
        libsystemd-dev \
        pkg-config \
        python3 \
        zlib1g-dev \
        libssl-dev \
        ninja-build \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSfL https://cmake.org/files/v${CMAKE_VERSION%.*}/cmake-${CMAKE_VERSION}-linux-$(uname -m).sh -o cmake.sh \
    && (bash cmake.sh --skip-license --prefix=/usr/local) \
    && rm cmake.sh

# configure Debian Multi-Arch to allow cross-compiling
RUN dpkg --add-architecture armhf
RUN dpkg --add-architecture arm64
COPY ./crossbuild.list /etc/apt/sources.list.d/crossbuild.list
RUN sed -Ei 's/^deb/deb [arch=amd64]/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install \
    zlib1g-dev:armhf \
    zlib1g-dev:arm64 \
    libssl-dev:armhf \
    libssl-dev:arm64

ENV VCPKG_ROOT=/usr/local/vcpkg
# this must be set on arm. see https://learn.microsoft.com/en-us/vcpkg/users/config-environment#vcpkg_force_system_binaries
ENV VCPKG_FORCE_SYSTEM_BINARIES=yes

# VCPKG_ROOT is set to filemode 0777 to allow the developer's UID to write the
# lockfile at build time
RUN cd /usr/local \
    && git config --global advice.detachedHead false \
    && git clone --branch 2023.04.15 https://github.com/microsoft/vcpkg \
    && ./vcpkg/bootstrap-vcpkg.sh -disableMetrics \
    && chmod -R ugo+rwX /usr/local/vcpkg

# this is set to document the expectation of a predictable workdir in build
# scripts used by CI and developers building locally, but GitHub Actions will
# always override with WORKDIR=/github/workspace when running the job container
WORKDIR /github/workspace
