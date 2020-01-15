# my JupyterLab Docker image

JupyterLab small images
This is based on [alpine-glibc](https://hub.docker.com/r/pyar6329/alpine-glibc)

- Alpine Linux
- JupyterLab
  - Vim keybind
  - Table of Contents extension
- CUDA
- TensorFlow
- PyToach

## Docker Hub

- https://hub.docker.com/r/pyar6329/jupyterlab

## Usage

```bash
$ docker run --rm --gpus all -p "9000:9000" -v "$(pwd):/workspace" pyar6329/jupyterlab:1.0

# or
$ docker run --rm --gpus all -p "9000:9000" -v "$(pwd):/workspace" -w "/workspace" -u $(id -u $(whoami)):$(id -g $(whoami)) pyar6329/jupyterlab:1.0
```
