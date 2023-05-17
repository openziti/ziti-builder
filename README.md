# Builder container for Ziti projects that use CMake

This container image has CMake and other utilities and libraries installed for
cross-compiling Ziti projects that use CMake with GLIBC 2.27. The image is
automatically published to Docker Hub as
[openziti/ziti-cmake:latest](https://hub.docker.com/r/openziti/ziti-cmake) when
a release is created in this repository.

## Developing this container image

Building this image is not necessary for building Ziti projects that use CMake.
This section is about releasing an improvement to Docker Hub for developers to
use with all Ziti projects that employ the C-SDK.

### Build the image for local testing

```bash
# optionally substitute podman or nerdctl for docker
docker build ./docker-image/ --tag ziti-cmake-test
```

### Run the local test image to cross-compile a Ziti project

Change to the directory of the Ziti project you want to test building the
default target. Run your local test image with that project mounted in the
correct path and your UID to avoid permissions conflicts in the build output
directory.

```bash
# optionally substitute podman or nerdctl for docker
docker run \
    --rm \
    --user="${UID}" \
    --volume="${PWD}:/github/workspace" \
    ziti-cmake-test ./cmake.sh
```

### Publish the image to Docker Hub

1. Create a pull request targeting the main branch.
1. Merge the pull request to main.
1. Create a meaningful release tag in GitHub that matches the regex `v[0-9]+.[0-9]+.[0-9]+`.
1. The release will trigger a GitHub Action that builds and publishes the image to Docker Hub.

## Using this container image in a Ziti project

Each Ziti project that uses CMake has a build script named `cmake.sh`. Each
project's CI runs `cmake.sh` to build the default compilation target.

Build the default target with the published container image by running
`cmake.sh` in the Ziti project you wish to build. The script will detect it is
not running inside this container image and invoke the container image for you
with `docker`.

Change to the directory of the Ziti project you wish to build.

```bash
./cmake.sh
```

You may provide alternative `cmake` commands or an executable inside the project
directory to build a different target or customize the CMake options and
arguments. When you supply a custom command, the script will not clean the
`./build/` output directory.

```bash
# run a script by supplying a path relative to the project directory
./cmake.sh ./scripts/run-tests.sh
```

Run an arbitrary command inside the container with the current project directory
mounted on `/github/workspace` with your UID

```bash
./cmake.sh cmake --build ./build --target bundle
```
