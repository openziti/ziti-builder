# builder container for ziti-edge-tunnel

This container image builds the ziti-edge-tunnel binary from source. This container image is available from Docker Hub as [openziti/ziti-tunnel-sdk-c-builder](https://hub.docker.com/r/openziti/ziti-tunnel-sdk-c-builder).

## Build ziti-edge-tunnel

To build the ziti-edge-tunnel binary, run the following command in the root of the **ziti-tunnel-sdk-c** repository:

```bash
docker run --rm --volume "${PWD}:/github/workspace" openziti/ziti-tunnel-sdk-c-builder
```

The default build target is "bundle" which produces a ZIP archive in `./build/package`. The executable binary is also stored in `./build/programs/ziti-edge-tunnel/Release/ziti-edge-tunnel`.

## Cross-compiling

You may build the Linux binary for a different architecture by specifying a CMake prefix from `/ziti-tunnel-sdk-c/CMakePresets.json`. For example, build the Linux binary for ARM64 with the following command:

```bash
docker run --rm --volume "${PWD}:/github/workspace" openziti/ziti-tunnel-sdk-c-builder ci-linux-arm64
```
