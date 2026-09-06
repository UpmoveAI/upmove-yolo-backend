FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/HumanSignal/label-studio-ml-backend.git .

WORKDIR /app/label_studio_ml/examples/yolo

RUN pip install --no-cache-dir -r requirements.txt

ENV PORT=9090

CMD label-studio-ml start . --port ${PORT} --host 0.0.0.0
