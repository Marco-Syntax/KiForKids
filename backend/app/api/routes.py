"""
API-Routen für GPT-Services: Aufgaben-Generierung und Antwort-Check.
"""

from fastapi import APIRouter, HTTPException ,Request
from app.services.gpt_tasks import generate_tasks
from app.limiter import limiter  # Importiere globalen Limiter
from app.models.request_models import TaskRequest

router = APIRouter()

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
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/ping")
async def ping():
    """
    Gesundheitscheck-Endpunkt.
    Gibt 'pong' zurück, um die Erreichbarkeit des Backends zu prüfen.
    """
    return {"status": "pong"}
