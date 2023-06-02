# Builder container for Ziti projects

This container image has CMake and other utilities and libraries installed for
cross-compiling Ziti projects with GLIBC 2.27. The image is
automatically published to Docker Hub as
[openziti/ziti-builder:latest](https://hub.docker.com/r/openziti/ziti-builder) (and `:main`) when
merging to main.

## Developing this container image

Building this image is unnecessary for building the Ziti projects that use this
image. This section is about releasing an improvement for the image to Docker
Hub for developers and CI to use with all Ziti projects that employ this image
to build the project.

### Build the image for local testing

```bash
# optionally substitute podman or nerdctl for docker
docker build ./docker-image/ --tag ziti-builder-test
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
    ziti-builder-test ./ziti-builder.sh
```

### Publish the image to Docker Hub

1. Create a pull request targeting the `main` branch.
1. Merge the pull request to `main`.
1. Create a meaningful release tag in GitHub that matches the regex `v[0-9]+.[0-9]+.[0-9]+`.
1. The release will trigger a GitHub Action that builds and publishes the image to Docker Hub.

## Using this container image in a Ziti project

Each Ziti project that uses this container image to build the project has a build script named `ziti-builder.sh`. Each
project's CI runs `ziti-builder.sh` to build the default compilation target, e.g., "bundle."

Build the default target with the published container image by running
`ziti-builder.sh` in the Ziti project you wish to build. The script will detect it is
not running inside this container image and invoke the container image for you
with `docker run`.

Change to the directory of the Ziti project you wish to build.

```bash
./ziti-builder.sh
```

You may provide alternative `cmake` commands or an executable inside the project
directory to build a different target or customize the CMake options and
arguments. When you supply a custom command, the script will not clean the
`./build/` output directory.

```bash
# run a script by supplying a path relative to the project directory
./ziti-builder.sh ./scripts/run-tests.sh
```

Run an arbitrary command inside the container with the current project directory
mounted on `/github/workspace` with your UID

```bash
./ziti-builder.sh cmake --build ./build --target bundle
```
