FROM ubuntu:18.04

# TensorFlow support version is here: https://www.tensorflow.org/install/source#common_installation_problems
# PyTorch support version is here: https://pytorch.org/get-started/previous-versions
# Arch Linux driver install command (Linux Kernel 5.4): sudo pacman -S linux54-nvidia-435xx nvidia-435xx-utils
ARG CUDA_VERSION="10.1"
ARG CUDNN_VERSION="7.6"
ARG TENSORFLOW_VERSION="2.2"
ARG PYTORCH_VERSION="1.6"
ARG TORCHVISION_VERSION="0.7"
ARG SPOTLIGHT_VERSION="0.1.6"
ARG JUPYTERLAB_VERSION="2.2.6"

# about jupyterlab-lsp version
# see: ujson, jedi: https://github.com/palantir/python-language-server/blob/develop/setup.py#L34-L42
# see: parso: https://github.com/davidhalter/jedi/blob/master/setup.py#L35
ARG JUPYTERLAB_LSP_CLIENT_VERSION="2.0.0"
ARG JUPYTERLAB_LSP_SERVER_VERSION="0.9.2"
ARG PYTHON_LANGUAGE_SERVER_VERSION="0.34.1"
ARG UJSON_VERSION="1.35"
ARG JEDI_VERSION="0.17"
ARG PARSO_VERSION="0.8.0"

ARG MINICONDA_PATH=/opt/conda
ARG USERID=1000
ARG GROUPID=1000
ARG USERNAME=anaconda

ENV PATH=${MINICONDA_PATH}/bin:${PATH} \
  LD_LIBRARY_PATH=/usr/lib:${LD_LIBRARY_PATH} \
  LANG="C.UTF-8" \
  LC_ALL="C.UTF-8" \
  DEBIAN_FRONTEND=noninteractive \
  NVIDIA_VISIBLE_DEVICES=all \
  NVIDIA_DRIVER_CAPABILITIES=utility,compute \
  NVIDIA_REQUIRE_CUDA="cuda>=10.1 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411"

# install miniconda
RUN set -x && \
  groupadd -r -g ${GROUPID} ${USERNAME} && \
  useradd -m -g ${USERNAME} -u ${USERID} -d /home/${USERNAME} -s /bin/bash ${USERNAME} && \
  mkdir /workspace && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    wget && \
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  apt-get purge --autoremove -y \
    ca-certificates \
    wget && \
  bash Miniconda3-latest-Linux-x86_64.sh -b -p ${MINICONDA_PATH} && \
  conda update -y --all && \
  conda clean -afy && \
  apt-get clean && \
  cp -rf /root/.[cjl]* /home/${USERNAME} && \
  mkdir -p /home/${USERNAME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension /home/${USERNAME}/.lsp_symlink && \
  echo '{"theme": "JupyterLab Dark"}' > /home/${USERNAME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings && \
  ln -s /home /home/${USERNAME}/.lsp_symlink/home && \
  ln -s /workspace /home/${USERNAME}/.lsp_symlink/workspace && \
  chown -R ${USERNAME}:${USERNAME} /opt /workspace /home/${USERNAME}/.jupyter && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf /var/lib/apt/lists/* ${MINICONDA_PATH}/pkgs/* /root/.[apwcjl]* Miniconda3-latest-Linux-x86_64.sh

USER ${USERNAME}

# install CUDA
RUN set -x && \
  conda install -y -c anaconda \
    cudatoolkit=${CUDA_VERSION} && \
  conda clean -afy && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/* /home/${USERNAME}/.[apw]*

# install CUDNN
RUN set -x && \
  conda install -y -c anaconda \
    cudnn=${CUDNN_VERSION} && \
  conda clean -afy && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/*

# install TensorFlow
RUN set -x && \
  conda install -y -c anaconda \
    tensorflow-gpu=${TENSORFLOW_VERSION} && \
  conda clean -afy && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/*

# install PyTorch
RUN set -x && \
  conda install -y -c pytorch \
    pytorch=${PYTORCH_VERSION} \
    torchvision=${TORCHVISION_VERSION} && \
  conda clean -afy && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/*

# install Recommender Systems using PyTorch
RUN set -x && \
  conda install -y -c conda-forge \
    git && \
  cd $HOME && \
  git clone https://github.com/maciejkula/spotlight.git -b "v${SPOTLIGHT_VERSION}" && \
  cd spotlight && \
  python setup.py build && \
  python setup.py install && \
  conda clean -afy && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/*

# install other packages from conda-forge
RUN set -x && \
  conda install -y -c conda-forge \
    pandas \
    cupy \
    psycopg2 \
    nodejs \
    scikit-learn \
    matplotlib \
    jupyterlab=${JUPYTERLAB_VERSION} \
    python-language-server=${PYTHON_LANGUAGE_SERVER_VERSION} \
    ujson=${UJSON_VERSION} \
    jedi=${JEDI_VERSION} \
    parso=${PARSO_VERSION} \
    kaggle && \
  conda clean -afy && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/*

USER root

# Prophet install
RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    g++ && \
  curl -o /usr/local/bin/su-exec.c "https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c" && \
  gcc -Wall /usr/local/bin/su-exec.c -o /usr/local/bin/su-exec && \
  chown root:root /usr/local/bin/su-exec && \
  chmod 0755 /usr/local/bin/su-exec && \
  rm /usr/local/bin/su-exec.c && \
  su-exec ${USERNAME} pip install --no-cache-dir \
    convertdate \
    lunarcalendar \
    holidays \
    pystan && \
  su-exec ${USERNAME} pip install --no-cache-dir \
    fbprophet && \
  rm -rf /usr/local/bin/su-exec && \
  apt-get purge --autoremove -y \
    ca-certificates \
    curl \
    g++ && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

# pip install plugins
RUN set -x && \
  pip install --no-cache-dir \
    akapriori \
    turicreate \
    jupyter-lsp==${JUPYTERLAB_LSP_SERVER_VERSION}

# install extensions
RUN set -x && \
  jupyter lab clean && \
  NODE_OPTIONS="--max_old_space_size=2048" jupyter labextension install -y @jupyterlab/toc && \
  NODE_OPTIONS="--max_old_space_size=2048" jupyter labextension install -y @axlair/jupyterlab_vim && \
  NODE_OPTIONS="--max_old_space_size=2048" jupyter labextension install -y @krassowski/jupyterlab-lsp@${JUPYTERLAB_LSP_CLIENT_VERSION} && \
  find ${MINICONDA_PATH} -follow -type f -name '*.a' -delete && \
  find ${MINICONDA_PATH} -follow -type f -name '*.js.map' -delete && \
  jupyter lab clean && \
  jlpm cache clean && \
  conda clean -afy && \
  npm cache clean --force && \
  find /opt -name __pycache__ | xargs rm -rf && \
  rm -rf ${MINICONDA_PATH}/pkgs/* $HOME/.node-gyp $HOME/.cache/yarn

WORKDIR /workspace
EXPOSE 9000

CMD ["/opt/conda/bin/jupyter-lab", "--no-browser", "--port=9000", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
