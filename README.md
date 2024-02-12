# ndunnett/python
Docker image based on the official Ubuntu image with Python compiled from source. The purpose of this image is to be a more performant, lower footprint alternative to the official Python image. Python is compiled using `clang-18` with all optimisation options enabled, and the final image is flattened to reduce the image size before being pushed to the [Docker Hub repository](https://hub.docker.com/r/ndunnett/python).

## Tag convention
The tag convention is as follows:

```{Ubuntu}-{Python}[-unflattened]```

- `Ubuntu` - this is the code name for the Ubuntu release
- `Python` - this is the major version of Python compiled

The `unflattened` variants are identical to the regular variants, except they have not been flattened and so retain their build layers. The `latest` tag is aliased to the image built with the newest available stable release for both Ubuntu and Python.

## Performance
See [BENCHMARK.md](/BENCHMARK.md) for performance comparison to the official Python image.
