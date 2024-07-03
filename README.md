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
docker build . --tag ziti-builder-test
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
