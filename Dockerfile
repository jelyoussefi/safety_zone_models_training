# Use NVIDIA PyTorch base image with CUDA support
FROM intel/oneapi-basekit

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

#================================================================================
# Install Intel Graphics Drivers
#================================================================================
RUN add-apt-repository -y ppa:kobuk-team/intel-graphics && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libze-intel-gpu1 \
        libze1 \
        intel-metrics-discovery \
        intel-opencl-icd \
        clinfo \
        intel-gsc \
        intel-media-va-driver-non-free \
        libmfx-gen1 \
        libvpl2 \
        libvpl-tools \
        libva-glx2 \
        va-driver-all \
        vainfo \
        libze-dev \
        intel-ocloc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN apt-get update && apt-get install -y python3-pip

RUN pip install --break-system-packages \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu

RUN pip install --break-system-packages \
    ultralytics 

