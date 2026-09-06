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

RUN pip uninstall -y \
    opencv-python \
    opencv-python-headless \
    opencv-contrib-python \
    opencv-contrib-python-headless || true && \
    pip install --no-cache-dir opencv-python-headless==4.9.0.80

ENV PORT=8080

CMD ["sh", "-c", "label-studio-ml start . --port ${PORT} --host 0.0.0.0"]
