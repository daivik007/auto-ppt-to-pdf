FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    libreoffice \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY monitor.py /app/monitor.py

RUN pip install --no-cache-dir watchdog

RUN chmod +x /app/monitor.py

CMD ["python", "-u", "/app/monitor.py"]
