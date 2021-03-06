FROM pyar6329/alpine-glibc:3.11

# TensorFlow support version is here: https://www.tensorflow.org/install/source#common_installation_problems
# PyTorch support version is here: https://pytorch.org/get-started/previous-versions
# Arch Linux driver install command (Linux Kernel 5.4): sudo pacman -S linux54-nvidia-435xx nvidia-435xx-utils
ARG MINICONDA_PATH=/opt/conda
ARG CUDA_VERSION="10.1"
ARG CUDNN_VERSION="7.6"
ARG TENSORFLOW_VERSION="2.1.0"
ARG PYTORCH_VERSION="1.4.0"
ARG TORCHVISION_VERSION="0.5.0"
ARG USERID=1000
ARG GROUPID=1000
ARG USERNAME=anaconda

ENV PATH=${MINICONDA_PATH}/bin:${PATH} \
  LD_LIBRARY_PATH=/usr/lib:/usr/lib64:${LD_LIBRARY_PATH} \
  NVIDIA_VISIBLE_DEVICES=all \
  NVIDIA_DRIVER_CAPABILITIES=utility,compute \
  NVIDIA_REQUIRE_CUDA="cuda>=10.1 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411"

RUN set -x && \
  addgroup -S ${USERNAME} -g ${GROUPID} && \
  adduser -D -u ${USERID} ${USERNAME} -G ${USERNAME} && \
  mkdir /workspace && \
  apk add --no-cache nodejs && \
  apk add --no-cache --virtual .build-dependencies ca-certificates wget bash yarn npm && \
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  bash Miniconda3-latest-Linux-x86_64.sh -b -p ${MINICONDA_PATH} && \
  ln -s ${MINICONDA_PATH}/bin/* /usr/local/bin/ && \
  conda update -y --all && \
  conda install -y -c anaconda \
    cudatoolkit=${CUDA_VERSION} \
    cudnn=${CUDNN_VERSION} \
    tensorflow-gpu=${TENSORFLOW_VERSION} && \
  conda install -y -c pytorch \
    pytorch=${PYTORCH_VERSION} \
    torchvision=${TORCHVISION_VERSION} && \
  conda install -y -c anaconda \
    scikit-learn \
    pandas \
    cupy \
    boto3 \
    psycopg2 \
    matplotlib \
    jupyterlab && \
  conda install -y -c conda-forge \
    kaggle && \
  jupyter lab clean && \
  NODE_OPTIONS="--max_old_space_size=2048" jupyter labextension install -y \
    @jupyterlab/toc \
    jupyterlab_vim && \
  mkdir -p /root/.jupyter/lab/user-settings/@jupyterlab/apputils-extension /home/${USERNAME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension && \
  echo '{"theme": "JupyterLab Dark"}' > /root/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings && \
  echo '{"theme": "JupyterLab Dark"}' > /home/${USERNAME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings && \
  find ${MINICONDA_PATH} -follow -type f -name '*.a' -delete && \
  find ${MINICONDA_PATH} -follow -type f -name '*.js.map' -delete && \
  conda clean -afy && \
  apk del .build-dependencies && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/* && \
  chown -R ${USERNAME}:${USERNAME} /opt /workspace /home/${USERNAME}/.jupyter && \
  rm -rf /root/.[apw]* Miniconda3-latest-Linux-x86_64.sh

USER anaconda
WORKDIR /workspace
EXPOSE 9000

CMD ["/opt/conda/bin/jupyter-lab", "--no-browser", "--port=9000", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
