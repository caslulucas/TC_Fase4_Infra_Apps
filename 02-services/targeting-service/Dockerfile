FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN adduser --system --group LucasDev && \
    chown -R LucasDev:LucasDev /app
USER LucasDev
EXPOSE 8003
CMD ["gunicorn", "--workers", "1", "--threads", "2", "--bind", "0.0.0.0:8003", "app:app"]



#docker builder prune -af
#docker build --no-cache -t targeting-service-test ./targeting-service-main