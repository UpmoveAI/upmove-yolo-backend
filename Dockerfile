FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/HumanSignal/label-studio-ml-backend.git /app/label-studio-ml-backend

WORKDIR /app/label-studio-ml-backend/label_studio_ml/examples/yolo

RUN pip install --no-cache-dir -r requirements-base.txt

RUN pip install --no-cache-dir -r requirements.txt

# Remove potentially conflicting versions
RUN pip uninstall -y \
    numpy \
    torch \
    torchvision \
    opencv-python \
    opencv-python-headless \
    opencv-contrib-python \
    opencv-contrib-python-headless || true

# Install a clean compatible NumPy version
RUN pip install --no-cache-dir numpy==1.26.3

# Install matching CPU versions of PyTorch and TorchVision
RUN pip install --no-cache-dir \
    torch==2.5.1 \
    torchvision==0.20.1 \
    --index-url https://download.pytorch.org/whl/cpu

# Install OpenCV after NumPy
RUN pip install --no-cache-dir \
    opencv-python-headless==4.9.0.80

ENV PORT=8080

CMD ["sh", "-c", "label-studio-ml start . --port ${PORT} --host 0.0.0.0"]
