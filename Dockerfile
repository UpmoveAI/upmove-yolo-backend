FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel

# Install one clean NumPy + PyTorch stack
RUN pip install --no-cache-dir numpy==1.26.4

RUN pip install --no-cache-dir \
    torch==2.2.2 \
    torchvision==0.17.2 \
    --index-url https://download.pytorch.org/whl/cpu

# Clone Label Studio ML backend
RUN git clone https://github.com/HumanSignal/label-studio-ml-backend.git \
    /app/label-studio-ml-backend

WORKDIR /app/label-studio-ml-backend/label_studio_ml/examples/yolo

# Install Label Studio backend
RUN pip install --no-cache-dir -r requirements-base.txt

# Keep NumPy below 2 while installing YOLO
RUN pip install --no-cache-dir \
    "numpy==1.26.4" \
    "opencv-python==4.9.0.80" \
    -r requirements.txt

# Simple build test
RUN python -c "import numpy, torch; print('NumPy', numpy._version); print('Torch', torch.version_); print(torch.from_numpy(numpy.array([1,2,3], dtype=numpy.float32)))"

ENV PORT=8080

CMD ["sh", "-c", "label-studio-ml start . --port ${PORT} --host 0.0.0.0"]
