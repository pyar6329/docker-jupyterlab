FROM continuumio/miniconda3:4.7.12-alpine

ARG MINICONDA_PATH=/opt/conda
ARG USER_HOME=/home/anaconda
ARG TENSORFLOW_VERSION="2.0.0"
ARG PYTORCH_VERSION="1.3.1"
ARG TORCHVISION_VERSION="0.4.2"

ENV PATH=${MINICONDA_PATH}/bin:${PATH} \
  LD_LIBRARY_PATH=/usr/lib:/usr/lib64:${LD_LIBRARY_PATH} \
  NVIDIA_VISIBLE_DEVICES=all \
  NVIDIA_DRIVER_CAPABILITIES=utility,compute \
  NVIDIA_REQUIRE_CUDA="cuda>=10.2 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411 brand=tesla,driver>=418,driver<419"

USER root
RUN set -x && \
  apk add --no-cache --virtual .build-dependencies nodejs yarn npm && \
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
  mkdir -p ${USER_HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension && \
  echo '{"theme": "JupyterLab Dark"}' > ${USER_HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings && \
  find ${MINICONDA_PATH} -follow -type f -name '*.a' -delete && \
  find ${MINICONDA_PATH} -follow -type f -name '*.js.map' -delete && \
  conda clean -afy && \
  chown -R anaconda:anaconda /opt ${USER_HOME} && \
  apk del .build-dependencies && \
  find ${MINICONDA_PATH} -name __pycache__ | xargs rm -rf && \
  rm -rf ${USER_HOME}/.[apw]* ${MINICONDA_PATH}/pkgs/*

USER anaconda
CMD ["/opt/conda/bin/jupyter-lab", "--no-browser", "--port=9000", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
