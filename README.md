# Builder container for Ziti projects

This container image has CMake and other utilities and libraries installed for
natively and cross-compiling Ziti projects. The image is automatically
published to Docker Hub as
[openziti/ziti-builder](https://hub.docker.com/r/openziti/ziti-builder) (and `:main`) when
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

## GLIBC Compatibility

Ziti projects that build with this image will produce artifacts that require a GLIBC version greater than or equal to the version of GLIBC installed in the image.

| ziti-builder Version | Ubuntu Release | GLIBC Version       | libssl Version                   |
|---------------------|---------------|---------------------|----------------------------------|
| v1                  | bionic        | 2.27-3ubuntu1.6     | 1.1.1-1ubuntu2.1~18.04.23        |
| v2                  | focal         | 2.31-0ubuntu9.17    | 1.1.1f-1ubuntu2.24               |
| v3                  | jammy         | 2.35-0ubuntu3.9     | 3.0.2-0ubuntu1.19                |
| v4 (future)         | noble         | 2.39-0ubuntu8.4     | 3.0.13-0ubuntu3.5                |



