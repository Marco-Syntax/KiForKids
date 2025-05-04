# Basis-Image
FROM python:3.10-slim-bullseye
# Arbeitsverzeichnis
WORKDIR /app

# Abhängigkeiten kopieren
COPY requirements.txt .

# Abhängigkeiten installieren
RUN pip install --no-cache-dir -r requirements.txt

# App-Code kopieren
COPY . .

# Exposed Port (FastAPI läuft standardmäßig auf 8000)
EXPOSE 8000

# Startbefehl (kannst auch gunicorn nehmen später)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]