"""
API-Routen für GPT-Services: Aufgaben-Generierung und Antwort-Check.
"""

from fastapi import APIRouter, HTTPException, Request, Depends
from app.services.gpt_tasks import generate_tasks
from app.limiter import limiter  # Importiere globalen Limiter
from app.models.request_models import TaskRequest
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.result import Result
import traceback
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/generate_tasks")
@limiter.limit("10/minute")
async def generate_tasks_endpoint(request: Request, request_data: TaskRequest):
    """
    Erwartet ein JSON mit subject, topic, level, testMode, usedQuestions, classTopics.
    Gibt eine Liste von Aufgaben mit Antworten zurück.
    """
    try:
        tasks = generate_tasks(request_data)
        return {"tasks": tasks}
    except Exception as e:
        logger.error(f"Fehler bei der Aufgabengenerierung: {str(e)}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/ping")
@limiter.limit("1/minute")
async def ping(request: Request):
    """
    Gesundheitscheck-Endpunkt.
    Gibt 'pong' zurück, um die Erreichbarkeit des Backends zu prüfen.
    """
    return {"status": "pong"}

@router.get("/debug/database")
async def debug_database(db: Session = Depends(get_db)):
    """
    Debug-Endpunkt zum Testen der Datenbankverbindung und zum Anzeigen der Tabellen.
    """
    try:
        # Teste die Datenbankverbindung
        result = db.execute("SELECT 1").scalar()
        
        # Hole Anzahl der Einträge in der Ergebnistabelle
        result_count = db.query(Result).count()
        
        # Hole die neuesten Einträge
        latest_entries = db.query(Result).order_by(Result.id.desc()).limit(5).all()
        
        latest_entries_info = []
        for entry in latest_entries:
            latest_entries_info.append({
                "id": entry.id,
                "user_id": entry.user_id,
                "subject": entry.subject,
                "topic": entry.topic,
                "timestamp": entry.timestamp
            })
        
        return {
            "database_connected": result == 1,
            "total_results": result_count,
            "latest_entries": latest_entries_info
        }
    except Exception as e:
        logger.error(f"Debug-Datenbankfehler: {str(e)}")
        logger.error(traceback.format_exc())
        return {"error": str(e), "stacktrace": traceback.format_exc()}
