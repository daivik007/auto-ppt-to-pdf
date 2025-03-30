FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    libreoffice \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY monitor.py dashboard.py /app/

RUN pip install --no-cache-dir watchdog fastapi uvicorn python-multipart

EXPOSE 8000

CMD ["sh", "-c", "uvicorn dashboard:app --host 0.0.0.0 --port 8000 & python3 /app/monitor.py"]
