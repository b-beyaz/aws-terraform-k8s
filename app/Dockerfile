FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

ARG APP_VERSION
ENV APP_VERSION=$APP_VERSION

EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]