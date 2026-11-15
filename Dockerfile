# HealthMate AI: one container serves the API and the built React app.

# ---- stage 1: build the frontend ----
FROM node:22-alpine AS web
WORKDIR /web
COPY frontend/package.json ./
RUN npm install --no-audit --no-fund
COPY frontend/ ./
RUN npm run build

# ---- stage 2: Python runtime ----
FROM python:3.12-slim
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 DATA_DIR=/app/backend/data
WORKDIR /app
COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt
COPY backend backend
COPY --from=web /web/dist frontend/dist
# run as an unprivileged user
RUN useradd -m appuser && mkdir -p /app/backend/data && chown -R appuser /app/backend/data
USER appuser
WORKDIR /app/backend
EXPOSE 8000
# Hosts such as Render / Railway inject $PORT; default to 8000 locally.
CMD ["sh", "-c", "python -m uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000} --proxy-headers --forwarded-allow-ips='*'"]
