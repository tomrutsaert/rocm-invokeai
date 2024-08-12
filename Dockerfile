# Run invoke ai with amdgpus. 
# - It hacks the invokeAI installer, so it does not need end-user input
# - It hacks the installation to push rocm 6.1 on top of it

FROM ghcr.io/tomrutsaert/rocm:main AS rocm-invokeai

RUN apt update -qq && DEBIAN_FRONTEND=noninteractive apt install -qq -y \
    unzip \
    software-properties-common && \
    add-apt-repository 'ppa:deadsnakes/ppa' -y && \
    apt update -qq && DEBIAN_FRONTEND=noninteractive apt install -qq -y \
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
    wget -nv "https://github.com/invoke-ai/InvokeAI/releases/download/v4.2.7post1/InvokeAI-installer-v4.2.7post1.zip" && \
    unzip -qq "InvokeAI-installer-v4.2.7post1.zip" && \
    cd "InvokeAI-Installer" && \
    sed -i 's/messages.choose_version(self.available_releases)/"stable"/g' ./lib/installer.py && \
    sed -i 's/device = select_gpu()/device = "rocm"/g' ./lib/installer.py && \
    # sed -i 's/rocm5.6/rocm6.1/g' ./lib/installer.py && \ This brings it back to torch CPU, so 5.6 is needed in current setup.....
    sed -i 's/device.value ==/device ==/g' ./lib/installer.py && \
    sed -i 's/destination = auto_dest if yes_to_all else messages.dest_path(root)/destination = auto_dest/g' ./lib/installer.py && \
    ./install.sh

ENV PATH="${PATH}:$INVOKEAI_ROOT/.venv/bin"

RUN python3.11 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1 --quiet && \
    # python3.11 -m pip install pypatchmatch && \
    rm -rf ~/InvokeAI-*

CMD ["/home/invoke/invokeai/.venv/bin/invokeai-web"]