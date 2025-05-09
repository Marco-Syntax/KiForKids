import os
import json
import logging
from app.models.result_entry import ResultEntry

def update_results_for_all_subjects(entry: ResultEntry, data_dir: str):
    """
    Speichert das Ergebnis für das jeweilige Fach in der passenden JSON-Datei.
    Legt die Datei an, falls sie nicht existiert.
    """
    fach = entry.fach
    file_path = os.path.join(data_dir, f"results_{fach}.json")
    logging.info(f"Speichere Ergebnis in: {file_path}")
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