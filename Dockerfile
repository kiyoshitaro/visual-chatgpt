# ARG PYTORCH_VERSION=22.04
# FROM nvcr.io/nvidia/pytorch:${PYTORCH_VERSION}-py3
ARG CUDA_VERSION=11.7.1
ARG PYTHON_VERSION=3.8
ARG CONDA_ENV_NAME=conda-pytorch

FROM nvidia/cuda:$CUDA_VERSION-base-ubuntu22.04
# Install ubuntu packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && apt-get install -y --no-install-recommends \
  libgl1 \
  libglib2.0-0 \
  wget \
  # python3-pip \
  # python-is-python3 \
  curl \
  libsm6 \
  libxext6 \
  libxrender-dev \
  ssh \
  sudo \
  unzip \
  vim 
RUN rm -rf /var/lib/apt/lists/*

# Create an user for the app.
ARG USER=kiyoshitaro
ENV HOME /home/$USER
RUN adduser --disabled-password --gecos '' $USER
RUN mkdir /content && chown -R $USER:$USER /content
WORKDIR /content
USER $USER

# Install miniconda (python)
RUN curl -o $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  chmod +x $HOME/miniconda.sh && \
  $HOME/miniconda.sh -b -p $HOME/conda && \
  rm $HOME/miniconda.sh &&\
  $HOME/conda/bin/conda install -y python=$PYTHON_VERSION jupyter jupyterlab

# Create the conda environment
ENV PATH $HOME/conda/bin:$PATH
RUN touch $HOME/.bashrc && \
  echo "export PATH=${HOME}/conda/bin:$PATH" >> $HOME/.bashrc
RUN conda create -n $CONDA_ENV_NAME python=$PYTHON_VERSION
RUN echo "source activate $CONDA_ENV_NAME" >> ~/.bashrc
RUN . activate $CONDA_ENV_NAME
RUN conda install -c conda-forge jupyter jupyterlab && \
  conda install -y pytorch torchvision torchaudio torchtext "pytorch-cuda=$(echo $CUDA_VERSION | cut -d'.' -f 1-2)" && \
  conda clean -ya





#######################
# APP SPECIFIC COMMANDS
#######################
ARG OPENAI_API_KEY=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
# COPY --chown=$USER:$USER . .
# RUN pip install -r requirement.txt
# RUN ./download.sh
# RUN mkdir ./image
EXPOSE 7860
# CMD python visual_chatgpt.py
