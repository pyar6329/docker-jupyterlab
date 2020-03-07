# my JupyterLab Docker image

JupyterLab minimum images

- JupyterLab
  - Vim keybind
  - Table of Contents extension
  - Git
- CUDA
- TensorFlow
- PyToach

## Docker Hub

- https://hub.docker.com/r/pyar6329/jupyterlab

## GitHub Package

- https://github.com/pyar6329/docker-jupyterlab/packages/146666

## Usage

### Docker Hub

```bash
$ docker run --rm --gpus all -p "9000:9000" -v "$(pwd):/workspace" pyar6329/jupyterlab:10.1.3

# or
$ docker run --rm --gpus all -p "9000:9000" -v "$(pwd):/workspace" -w "/workspace" -u $(id -u $(whoami)):$(id -g $(whoami)) pyar6329/jupyterlab:10.1.3
```

### GitHub Package

```bash
$ docker run --rm --gpus all -p "9000:9000" -v "$(pwd):/workspace" docker.pkg.github.com/pyar6329/docker-jupyterlab/jupyterlab:10.1.3

# or
$ docker run --rm --gpus all -p "9000:9000" -v "$(pwd):/workspace" -w "/workspace" -u $(id -u $(whoami)):$(id -g $(whoami)) docker.pkg.github.com/pyar6329/docker-jupyterlab/jupyterlab:10.1.3
```

and open [http://localhost:9000](http://localhost:9000)
