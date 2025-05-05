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
from app.database import engine, SessionLocal
from app.models.result import Base as ResultBase

app = FastAPI()
app.include_router(router)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Initialisiere die Datenbanktabellen
ResultBase.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_DIR = os.path.join(os.path.dirname(__file__), "results_data")
os.makedirs(DATA_DIR, exist_ok=True)

from app.models.result import Result
from sqlalchemy.orm import Session
from fastapi import Depends

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/save_results/{user_id}")
@limiter.limit("10/minute")
async def save_results(user_id: str, request: Request, db: Session = Depends(get_db)):
    try:
        body = await request.json()
        new_result = Result(
            user_id=user_id,
            fach=body["fach"],
            topic=body["topic"],
            questions=json.dumps(body["questions"]),
            user_answers=json.dumps(body["userAnswers"]),
            feedback=json.dumps(body["feedback"]),
            timestamp=body["timestamp"],
        )
        db.add(new_result)
        db.commit()
        return {"status": "ok"}
    except Exception as e:
        logging.error(f"Fehler beim Speichern in die DB: {e}")
        raise HTTPException(status_code=500, detail="Fehler beim Speichern")

@app.get("/get_results/{user_id}/{fach}")
@limiter.limit("20/minute")
async def get_results(user_id: str, fach: str, request: Request, db: Session = Depends(get_db)):
    try:
        results = db.query(Result).filter(Result.user_id == user_id, Result.fach == fach).all()
        return [
            {
                "fach": r.fach,
                "topic": r.topic,
                "questions": json.loads(r.questions),
                "userAnswers": json.loads(r.user_answers),
                "feedback": json.loads(r.feedback),
                "timestamp": r.timestamp
            }
            for r in results
        ]
    except Exception as e:
        logging.error(f"Fehler beim Abrufen der Ergebnisse: {e}")
        raise HTTPException(status_code=500, detail="Fehler beim Abrufen der Ergebnisse")
