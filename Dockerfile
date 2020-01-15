FROM pyar6329/alpine-glibc:3.11

ARG MINICONDA_PATH=/opt/conda
ARG TENSORFLOW_VERSION="2.0.0"
ARG PYTORCH_VERSION="1.3.1"
ARG TORCHVISION_VERSION="0.4.2"
ARG USERID=1000
ARG GROUPID=1000
ARG USERNAME=anaconda

ENV PATH=${MINICONDA_PATH}/bin:${PATH} \
  LD_LIBRARY_PATH=/usr/lib:/usr/lib64:${LD_LIBRARY_PATH} \
  NVIDIA_VISIBLE_DEVICES=all \
  NVIDIA_DRIVER_CAPABILITIES=utility,compute \
  NVIDIA_REQUIRE_CUDA="cuda>=10.2 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411 brand=tesla,driver>=418,driver<419"

RUN set -x && \
  addgroup -S ${USERNAME} -g ${GROUPID} && \
  adduser -D -u ${USERID} ${USERNAME} -G ${USERNAME} && \
  mkdir /workspace && \
  apk add --no-cache --virtual .build-dependencies ca-certificates wget bash nodejs yarn npm && \
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  bash Miniconda3-latest-Linux-x86_64.sh -b -p ${MINICONDA_PATH} && \
  ln -s ${MINICONDA_PATH}/bin/* /usr/local/bin/ && \
  conda update -y --all && \
  conda install -y \
    scikit-learn \
    pandas \
    tensorflow-gpu=${TENSORFLOW_VERSION} \
    pytorch-gpu=${PYTORCH_VERSION} \
    torchvision=${TORCHVISION_VERSION} \
    cupy \
    boto3 \
    psycopg2 \
    jupyterlab && \
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
  chown -R ${USERNAME}:${USERNAME} /opt /workspace && \
  rm -rf /root/.[apw]* Miniconda3-latest-Linux-x86_64.sh

USER anaconda
WORKDIR /workspace
EXPOSE 9000

CMD ["/opt/conda/bin/jupyter-lab", "--no-browser", "--port=9000", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
