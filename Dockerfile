# Use RunPod's optimized PyTorch image (CUDA 12.4 for RTX 4090)
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Set working directory
WORKDIR /app

# Install system dependencies (build-essential is required for pkuseg)
RUN apt-get update && apt-get install -y \
    git wget curl ffmpeg libsndfile1 build-essential \
    && rm -rf /var/lib/apt/lists/*

# 1. Prepare environment: Install build tools first
RUN pip install --no-cache-dir setuptools wheel numpy==1.26.0

# 2. Fix the pkuseg / Chatterbox conflict
# We install pkuseg manually without build isolation to ensure it sees Numpy 1.26
RUN pip install --no-cache-dir --no-build-isolation pkuseg==0.0.25

# 3. Install Chatterbox WITHOUT dependencies to keep our controlled environment
RUN pip install --no-cache-dir --no-deps chatterbox-tts==0.1.6

# 4. Install remaining Chatterbox requirements
RUN pip install --no-cache-dir \
    conformer s3tokenizer librosa resemble-perth huggingface_hub \
    safetensors transformers diffusers einops soundfile scipy \
    omegaconf pyloudnorm runpod faster-whisper

# 5. Pre-bake the models (Crucial for 0 active workers / fast start)
# This downloads the ~2GB weights into the image during the build
RUN python3 -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='ResembleAI/chatterbox-turbo'); \
    snapshot_download(repo_id='Systran/faster-whisper-base')"

# Copy your local handler code
COPY handler.py /app/handler.py

# Start the worker
CMD ["python", "-u", "/app/handler.py"]