# Run invoke ai with amdgpus. 
# - It hacks the invokeAI installer, so it does not need end-user input
# - It hacks the installation to push rocm 6.1 on top of it

FROM ubuntu:24.04

ARG ROCM_VERSION=6.2
ARG AMDGPU_VERSION=6.2

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    wget \
    gpg \
    build-essential \
    git \
    unzip \
    ca-certificates \
    software-properties-common && \
    wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/$AMDGPU_VERSION/ubuntu noble main" | tee /etc/apt/sources.list.d/amdgpu.list && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/$ROCM_VERSION noble main" | tee --append /etc/apt/sources.list.d/rocm.list && \
    add-apt-repository 'ppa:deadsnakes/ppa' -y

COPY rocm-pin-600 /etc/apt/preferences.d/rocm-pin-600

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    amdgpu-dkms \
    rocm \
    python3.11 \
    python3.11-venv && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home -G sudo,video --shell /bin/bash invoke

USER invoke
WORKDIR /home/invoke
ENV PATH="${PATH}:/opt/rocm/bin"
ENV INVOKEAI_ROOT=/home/invoke/invokeai
ENV INVOKEAI_HOST=0.0.0.0
ENV INVOKEAI_PORT=9090

RUN cd ~ && \
    mkdir $INVOKEAI_ROOT && \
    wget "https://github.com/invoke-ai/InvokeAI/releases/download/v4.2.7post1/InvokeAI-installer-v4.2.7post1.zip" && \
    unzip "InvokeAI-installer-v4.2.7post1.zip" && \
    cd "InvokeAI-Installer" && \
    sed -i 's/messages.choose_version(self.available_releases)/"stable"/g' ./lib/installer.py && \
    sed -i 's/device = select_gpu()/device = "rocm"/g' ./lib/installer.py && \
    sed -i 's/device.value ==/device ==/g' ./lib/installer.py && \
    sed -i 's/destination = auto_dest if yes_to_all else messages.dest_path(root)/destination = auto_dest/g' ./lib/installer.py && \
    ./install.sh

ENV PATH="${PATH}:$INVOKEAI_ROOT/.venv/bin"

RUN python3.11 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1 && \
    # python3.11 -m pip install pypatchmatch && \
    rm -rf ~/InvokeAI-*

CMD ["/home/invoke/invokeai/.venv/bin/invokeai-web"]