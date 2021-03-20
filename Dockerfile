FROM nvidia/cuda:11.2.1-base-ubuntu20.04
#RUN echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/nvidia-ml.list
    
# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    dumb-init \
    htop \
    sudo \
    curl \
    git \
    bzip2 \
    libx11-6 \
    locales \
    man \
    git \
    procps \
    openssh-client \
    lsb-release \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG C.UTF-8

# Create project directory
RUN mkdir /projects

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

# Install fixuid

RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml
 
# Install code-server
WORKDIR /tmp
RUN CODE_SERVER_VERSION=3.9.1 && \
    ARCH="$(dpkg --print-architecture)" && \
    curl -fOL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_${ARCH}.deb \
    dpkg -i ./code-server_${CODE_SERVER_VERSION}_${ARCH}.deb && rm ./code-server_${CODE_SERVER_VERSION}_${ARCH}.deb
  
# Copy entry point

COPY ./entrypoint.sh /usr/bin/entrypoint.sh

EXPOSE 8080
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
USER 1000
ENV USER=coder
WORKDIR /home/coder

# Install conda
RUN curl -o ~/miniconda.sh -O  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b && \
    rm ~/miniconda.sh && \
    /home/coder/miniconda3/bin/conda install conda-build

ENV PATH=$PATH:/home/coder/miniconda3/bin/

# Create environment
COPY environment.yaml /home/coder/environment.yaml
RUN conda env update -n base --file environment.yaml

# Activate Source
CMD source activate scm
CMD source ~/.bashrc

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]
