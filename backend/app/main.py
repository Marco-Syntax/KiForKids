"""
Backend-API für die Speicherung und Abfrage von Ergebnis-Übersichten pro Nutzer/Fach.
Speichert persistent als JSON-Datei (pro User/Fach).
Verwendet FastAPI.
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import json
import os
from fastapi.middleware.cors import CORSMiddleware
import logging
from .models.result_entry import ResultEntry, update_results_for_all_subjects

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Für Entwicklung, in Produktion anpassen!
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_DIR = os.path.join(os.path.dirname(__file__), "results_data")
os.makedirs(DATA_DIR, exist_ok=True)

class ResultEntry(BaseModel):
    fach: str
    topic: str
    questions: List[str]
    userAnswers: List[str]
    feedback: List[str]
    timestamp: str  # ISO-Format

# Speichern der Ergebnisse (POST)
@app.post("/save_results/{user_id}")
def save_results(user_id: str, entry: ResultEntry):
    # Nutze die Hilfsfunktion aus result_entry.py
    update_results_for_all_subjects(user_id, entry, DATA_DIR)
    return {"status": "ok"}

# Abrufen der Ergebnisse (GET)
@app.get("/get_results/{user_id}/{fach}")
def get_results(user_id: str, fach: str):
    # Dateinamen normalisieren (z.B. Leerzeichen durch Unterstrich, alles klein)
    safe_fach = fach.replace(" ", "_")
    file_path = os.path.join(DATA_DIR, f"{user_id}_{safe_fach}.json")
    logging.info(f"Suche Datei: {file_path}")
    if not os.path.exists(file_path):
        logging.warning(f"Datei nicht gefunden: {file_path}")
        return []
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read().strip()
        if not content:
            return []
        data = json.loads(content)
    return data
