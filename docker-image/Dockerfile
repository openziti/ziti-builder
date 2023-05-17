ARG CMAKE_VERSION="3.26.3"
ARG XDG_CONFIG_HOME="/tmp/home"

# Ubuntu Bionic 18.04 LTS
FROM ubuntu:bionic

ARG CMAKE_VERSION
ARG XDG_CONFIG_HOME

LABEL org.opencontainers.image.authors="support@netfoundry.io"

ENV DEBIAN_FRONTEND=noninteractive
ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1
ENV TZ=UTC

USER root

ENV PATH="/usr/local/:${PATH}"
ENV XDG_CONFIG_HOME="${XDG_CONFIG_HOME}"

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

RUN cd /usr/local \
    && git config --global advice.detachedHead false \
    && git clone --branch 2023.04.15 https://github.com/microsoft/vcpkg \
    && ./vcpkg/bootstrap-vcpkg.sh -disableMetrics \
    && chmod -R ugo+rwX /usr/local/vcpkg

# optimize for the developer's run-as UID to set --global safe.directory at
# build time
RUN [ -n ${XDG_CONFIG_HOME:-} ] \
    && mkdir -pm0777 ${XDG_CONFIG_HOME}/git \
    && touch ${XDG_CONFIG_HOME}/git/config \
    && chmod -R ugo+rwX ${XDG_CONFIG_HOME}

WORKDIR /github/workspace
