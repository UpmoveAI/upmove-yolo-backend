FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ffmpeg \
    libsm6 \
    libxext6 \
    libffi-dev \
    python3-dev \
    python3-pip \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/HumanSignal/label-studio-ml-backend.git \
    /app/label-studio-ml-backend

WORKDIR /app/label-studio-ml-backend/label_studio_ml/examples/yolo

RUN pip install --no-cache-dir -r requirements-base.txt

RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8080
ENV WORKERS=1
ENV THREADS=4

CMD ["sh", "-c", "label-studio-ml start . --port ${PORT} --host 0.0.0.0"]
