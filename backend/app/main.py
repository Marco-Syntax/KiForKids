"""
Backend-API für die Speicherung und Abfrage von Ergebnis-Übersichten pro Nutzer/Fach.
Speichert persistent als JSON-Datei (pro User/Fach).
Verwendet FastAPI.
"""

from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from typing import List, Dict, Any
import json
import os
from fastapi.middleware.cors import CORSMiddleware
import logging
from slowapi import _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from .models.result_entry import ResultEntry
from app.services.result_service import update_results_for_all_subjects
from app.api.routes import router
from app.limiter import limiter

app = FastAPI()
app.include_router(router)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://kiforkids.de"  
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

DATA_DIR = os.path.join(os.path.dirname(__file__), "results_data")
os.makedirs(DATA_DIR, exist_ok=True)

# Speichern der Ergebnisse (POST)
@app.post("/save_results/{user_id}")
@limiter.limit("10/minute")
async def save_results(user_id: str, request: Request):
    # Nutze die Hilfsfunktion aus result_entry.py
    update_results_for_all_subjects(user_id, request)
    return {"status": "ok"}

# Abrufen der Ergebnisse (GET)
@app.get("/get_results/{user_id}/{fach}")
@limiter.limit("20/minute")
async def get_results(user_id: str, fach: str, request: Request):
    # Dateinamen normalisieren (z.B. Leerzeichen durch Unterstrich, alles klein)
    safe_fach = fach.replace(" ", "_")
    file_path = os.path.join(DATA_DIR, f"{user_id}_{safe_fach}.json")
    logging.info(f"Suche Datei: {file_path}")
    if not os.path.exists(file_path) or not os.path.getsize(file_path):
        logging.warning(f"Datei nicht gefunden oder leer: {file_path}")
        return []
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data
