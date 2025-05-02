"""
Definiert das Datenmodell für gespeicherte Ergebnis-Einträge.
"""

from pydantic import BaseModel
from typing import List
import logging
import os
import json

class ResultEntry(BaseModel):
    fach: str
    topic: str
    questions: List[str]
    userAnswers: List[str]
    feedback: List[str]
    timestamp: str  # ISO-Format

def update_results_for_all_subjects(user_id: str, entry: ResultEntry, data_dir: str):
    """
    Speichert das Ergebnis für das jeweilige Fach des Users in der passenden JSON-Datei.
    Legt die Datei an, falls sie nicht existiert.
    """
    fach = entry.fach
    file_path = os.path.join(data_dir, f"{user_id}_{fach}.json")
    logging.info(f"Speichere Ergebnis in: {file_path}")
    # Stelle sicher, dass das Verzeichnis existiert
    os.makedirs(data_dir, exist_ok=True)
    try:
        if os.path.exists(file_path):
            with open(file_path, "r", encoding="utf-8") as f:
                try:
                    data = json.load(f)
                except Exception:
                    data = []
        else:
            data = []
        data.append(entry.dict())
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        logging.info(f"Ergebnis erfolgreich gespeichert: {file_path}")
    except Exception as e:
        logging.error(f"Fehler beim Speichern der Datei {file_path}: {e}")
