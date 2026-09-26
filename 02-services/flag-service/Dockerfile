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
EXPOSE 8002
CMD ["gunicorn", "--workers", "1", "--threads", "2", "--bind", "0.0.0.0:8002", "app:app"]

#limpar e executar teste do zero
#docker builder prune -af
#docker build --no-cache -t flag-service-test ./flag-service-main

#build sem cache anterior
#docker build --no-cache -t flag-service-test ./flag-service-main



