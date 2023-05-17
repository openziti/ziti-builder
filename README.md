# Builder container for Ziti projects that use CMake

This container image has CMake and other utilities and libraries installed for
cross-compiling Ziti projects that use CMake. It is published in Docker Hub as
[openziti/ziti-cmake](https://hub.docker.com/r/openziti/ziti-cmake).

## Using this container image

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
mounted on /github/workspace with your UID

```bash
./cmake.sh cmake --build ./build --target bundle
```

## Build the x86 image for publishing

The release CI in this repository will automatically publish a new version of
the image and, e.g., `:1.2.3` and update the `:latest` tag whenever a commit is
pushed to the `main` branch.

```bash
docker buildx build ./docker-image/ \
    --platform=linux/amd64 \
    --tag=docker.io/openziti/ziti-cmake:latest \
    --push
```

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
