# ndunnett/python
Docker image based on the official Ubuntu image with Python compiled from source. The purpose of this image is to be a more performant, lower footprint alternative to the official Python image. Python is downloaded, compiled, and installed in one layer to reduce the image size before being pushed to the [Docker Hub repository](https://hub.docker.com/r/ndunnett/python).

## Tag convention
The tag convention is as follows:

```{Ubuntu}-{Python}```

- `Ubuntu` - this is the code name for the Ubuntu release
- `Python` - this is the version of Python compiled

The `latest` tag is aliased to the image built with the newest available stable release for both Ubuntu and Python.

## Performance
See [BENCHMARK.md](/BENCHMARK.md) for performance comparison to the official Python image.

## TODO:
- Support for `arm64v8` and `arm32v7`
- Reduce vulnerabilities highlighted by Docker Scout (if possible)
- Optimise image size
- Add more base images (Debian, Alpine)
- Add image size comparison to benchmarks
- Add benchmarks between Python versions
- Add benchmarks between base images
- Revisit compiling with `clang`
