# Run invoke ai with amdgpus. 
# - It hacks the invokeAI installer, so it does not need end-user input
# - It hacks the installation to push rocm 6.1 on top of it

FROM rocm/pytorch:rocm6.2_ubuntu22.04_py3.10_pytorch_release_2.3.0 AS rocm-invokeai

ARG CONTAINER_UID
ARG CONTAINER_GID

ENV CONTAINER_UID=${CONTAINER_UID:-1000}
ENV CONTAINER_GID=${CONTAINER_GID:-1000}
ENV INVOKEAI_SRC=/opt/invokeai
ENV INVOKEAI_ROOT=/invokeai
ENV INVOKEAI_HOST=0.0.0.0
ENV INVOKEAI_PORT=9090
ENV HSA_OVERRIDE_GFX_VERSION=11.0.0

WORKDIR ${INVOKEAI_SRC}

RUN mkdir -p ${INVOKEAI_SRC} && chown -R ${CONTAINER_UID}:${CONTAINER_GID} ${INVOKEAI_SRC} && \
    cd /tmp/ && \
    wget -nv "https://github.com/invoke-ai/InvokeAI/releases/download/v4.2.7post1/InvokeAI-installer-v4.2.7post1.zip" && \
    unzip -qq "InvokeAI-installer-v4.2.7post1.zip" && \
    cd "InvokeAI-Installer" && \
    sed -i 's/messages.choose_version(self.available_releases)/"stable"/g' ./lib/installer.py && \
    sed -i 's/device = select_gpu()/device = "rocm"/g' ./lib/installer.py && \
    # sed -i 's/rocm5.6/rocm6.1/g' ./lib/installer.py && \ This brings it back to torch CPU, so 5.6 is needed in current setup.....
    sed -i 's/device.value ==/device ==/g' ./lib/installer.py && \
    sed -i 's/destination = auto_dest if yes_to_all else messages.dest_path(root)/destination = Path(os.environ.get("INVOKEAI_SRC", root)).expanduser().resolve()/g' ./lib/installer.py && \
    ./install.sh && \
    rm -rf /tmp/InvokeAI-* && \
    $INVOKEAI_SRC/.venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1 && \
    $INVOKEAI_SRC/.venv/bin/pip install pypatchmatch

ENV PATH="${PATH}:$INVOKEAI_SRC/.venv/bin"
CMD ["invokeai-web"]