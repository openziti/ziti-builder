# this is the x86 container image used by GitHub Actions and developers to
# cross-compile Ziti projects that use CMake

# pin the cmake version to ensure repeatable builds
ARG CMAKE_VERSION="3.26.3"
ARG VCPKG_VERSION="2024.03.25"

# Ubuntu Jammy Jellyfish has GLIBC 2.35
FROM ubuntu:jammy

ARG CMAKE_VERSION
ARG VCPKG_VERSION
ARG XDG_CONFIG_HOME
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.authors="support@netfoundry.io"

USER root

ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1
ENV TZ=UTC
ENV PATH="/usr/local/:${PATH}"
# used by git to find global config in container that is writable by the
# developer's UID
ENV GIT_CONFIG_GLOBAL="/ziti-builder-gitconfig"
# used by build scripts to detect running in docker
ENV BUILD_ENVIRONMENT="ziti-builder-docker"

RUN apt-get update \
    && apt-get --yes --quiet --no-install-recommends install \
        autoconf \
        automake \
        autopoint \
        cppcheck \
        crossbuild-essential-arm64 \
        crossbuild-essential-armhf \
        curl \
        doxygen \
        expect \
        flex \
        g++-arm-linux-gnueabihf \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnueabihf \
        gcovr \
        gpg \
        gpg-agent \
        openssh-client \
        graphviz \
        libcap-dev \
        libssl-dev \
        libsodium-dev \
        libsystemd-dev \
        libprotobuf-c-dev \
        libjson-c-dev \
        libtool \
        ninja-build \
        pkg-config \
        python3 \
        python3-pip \
        software-properties-common \
        tar \
        unzip \
        wget \
        zip \
        zlib1g-dev \
    && apt-get --yes autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN curl -sSLf https://apt.llvm.org/llvm-snapshot.gpg.key \
    | gpg --dearmor --output /usr/share/keyrings/llvm-snapshot.gpg \
    && chmod +r /usr/share/keyrings/llvm-snapshot.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/focal/ llvm-toolchain-focal-17 main" > /etc/apt/sources.list.d/llvm-snapshot.list

# re-added git ppa because cmake failed to find git version tag on focal runner
RUN add-apt-repository ppa:git-core/ppa \
    && apt-get update \
    && apt-get --yes --quiet --no-install-recommends install \
        git \
        clang-17 \
        clang-tidy-17 \
    && apt-get --yes autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*
RUN ln -sfvn /usr/bin/clang-17 /usr/bin/clang \
    && ln -sfvn /usr/bin/clang++-17 /usr/bin/clang++ \
    && ln -sfvn /usr/bin/clang-tidy-17 /usr/bin/clang-tidy

RUN curl -sSfL https://cmake.org/files/v${CMAKE_VERSION%.*}/cmake-${CMAKE_VERSION}-linux-$(uname -m).sh -o cmake.sh \
    && (bash cmake.sh --skip-license --prefix=/usr/local) \
    && rm cmake.sh

# configure Debian Multi-Arch to allow cross-compiling
RUN dpkg --add-architecture armhf
RUN dpkg --add-architecture arm64
COPY ./crossbuild.list /etc/apt/sources.list.d/crossbuild.list
RUN sed -Ei 's/^deb/deb [arch=amd64]/g' /etc/apt/sources.list
# install build-essential after adding architectures to avoid errors where cmake can not find build tools like gcc, g++
RUN apt-get update \
    && apt-get --yes --quiet --no-install-recommends install \
        build-essential \
    && apt-get --yes --quiet --no-install-recommends install \
        libcap-dev:armhf \
        libcap-dev:arm64 \
        libssl-dev:armhf \
        libssl-dev:arm64 \
        libprotobuf-c-dev:arm64 \
        libprotobuf-c-dev:armhf \
        zlib1g-dev:armhf \
        zlib1g-dev:arm64 \
        linux-libc-dev:arm64 \
        linux-libc-dev:armhf \
    && apt-get --yes autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

ENV VCPKG_ROOT=/usr/local/vcpkg
# this must be set on arm. see https://learn.microsoft.com/en-us/vcpkg/users/config-environment#vcpkg_force_system_binaries
ENV VCPKG_FORCE_SYSTEM_BINARIES=yes

# VCPKG_ROOT is set to filemode 0777 to allow the developer's UID to write the lockfile at build time; and git writes
# global config settings as root in GIT_CONFIG_GLOBAL
RUN cd /usr/local \
    && touch "${GIT_CONFIG_GLOBAL}" \
    && git config --global advice.detachedHead false \
    && git clone --branch "${VCPKG_VERSION}" https://github.com/microsoft/vcpkg \
    && ./vcpkg/bootstrap-vcpkg.sh -disableMetrics \
    && chmod -R ugo+rwX /usr/local/vcpkg

# this is set to document the expectation of a predictable workdir in build
# scripts used by CI and developers building locally, but GitHub Actions will
# always override with WORKDIR=/github/workspace when running the job container
WORKDIR /github/workspace

# trust github.com known ssh host keys
COPY --chmod=0644 ./github-known-hosts /etc/ssh/ssh_known_hosts

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
