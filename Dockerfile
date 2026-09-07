FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/HumanSignal/label-studio-ml-backend.git \
    /app/label-studio-ml-backend

WORKDIR /app/label-studio-ml-backend/label_studio_ml/examples/yolo

# Label Studio ML backend
RUN pip install --no-cache-dir -r requirements-base.txt

# Remove packages that can cause NumPy / Torch conflicts
RUN pip uninstall -y \
    numpy \
    torch \
    torchvision \
    opencv-python \
    opencv-python-headless \
    opencv-contrib-python \
    opencv-contrib-python-headless || true

# Stable NumPy
RUN pip install --no-cache-dir numpy==1.25.2

# Stable CPU PyTorch combination
RUN pip install --no-cache-dir \
    torch==2.1.2 \
    torchvision==0.16.2 \
    --index-url https://download.pytorch.org/whl/cpu

# OpenCV compatible with NumPy 1.x
RUN pip install --no-cache-dir \
    opencv-python-headless==4.9.0.80

# YOLO requirements
RUN pip install --no-cache-dir -r requirements.txt

# Force our stable versions again after YOLO requirements
RUN pip install --no-cache-dir --force-reinstall \
    numpy==1.25.2

RUN pip install --no-cache-dir --force-reinstall \
    torch==2.1.2 \
    torchvision==0.16.2 \
    --index-url https://download.pytorch.org/whl/cpu

RUN pip uninstall -y opencv-python opencv-contrib-python || true

RUN pip install --no-cache-dir --force-reinstall \
    --no-deps \
    opencv-python-headless==4.9.0.80

# IMPORTANT: test NumPy -> PyTorch conversion during build
RUN python -c "import numpy as np, torch; a=np.array([1,2,3],dtype=np.float32); print('NUMPY:',np._version); print('TORCH:',torch.version_); print('TEST:',torch.from_numpy(a))"

ENV PORT=8080

CMD ["sh", "-c", "label-studio-ml start . --port ${PORT} --host 0.0.0.0"]
