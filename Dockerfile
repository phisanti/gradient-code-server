FROM nvidia/cuda:10.0-base-ubuntu18.04
# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8
LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         sudo \
         vim \
         ca-certificates \
         python-qt4 \
         libjpeg-dev \
         zip \
         unzip \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV PYTHON_VERSION=3.6

# Install code-server

RUN mkdir -p ~/.local/lib ~/.local/bin
RUN curl -fL https://github.com/cdr/code-server/releases/download/v3.8.0/code-server-3.8.0-linux-amd64.tar.gz \
  | tar -C ~/.local/lib -xz
RUN mv ~/.local/lib/code-server-3.8.0-linux-amd64 ~/.local/lib/code-server-3.8.0
RUN ln -s ~/.local/lib/code-server-3.8.0/bin/code-server ~/.local/bin/code-server
RUN PATH="~/.local/bin:$PATH"

# Install conda
RUN curl -o ~/miniconda.sh -O  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
    /opt/conda/bin/conda install conda-build

ENV PATH=$PATH:/opt/conda/bin/
ENV USER scm

# Expose port and entry point
COPY run.sh /run.sh
EXPOSE 8888
ENTRYPOINT ["/run.sh"]
