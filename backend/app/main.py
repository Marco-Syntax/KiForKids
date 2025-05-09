"""
Backend-API für die Speicherung und Abfrage von Ergebnis-Übersichten pro Nutzer/Fach.
Speichert persistent in MariaDB.
Verwendet FastAPI.
"""

from fastapi import FastAPI, HTTPException, Request, Depends
from typing import List, Dict, Any, Optional
import json
import os
import traceback
from fastapi.middleware.cors import CORSMiddleware
import logging
from slowapi import _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from sqlalchemy.orm import Session
from app.models.result_entry import ResultEntry
from app.api.routes import router
from app.limiter import limiter
from app.database import get_db, init_db
from app.models.result import Result

# Verbesserte Logging-Konfiguration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()
app.include_router(router)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Initialisiere die Datenbanktabellen
try:
    logger.info("Initialisiere Datenbanktabellen...")
    init_db()
    logger.info("Datenbanktabellen erfolgreich initialisiert")
except Exception as e:
    logger.error(f"Fehler bei der Initialisierung der Datenbank: {str(e)}")
    logger.error(traceback.format_exc())
    raise

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/save_results/{user_id}")
@limiter.limit("10/minute")
async def save_results(user_id: str, request: Request, db: Session = Depends(get_db)):
    try:
        body = await request.json()
        logger.info(f"Verarbeite save_results Anfrage für user_id: {user_id}")
        
        # Detaillierte Prüfung der Eingabedaten
        required_fields = ["fach", "topic", "questions", "userAnswers", "feedback", "timestamp"]
        for field in required_fields:
            if field not in body:
                error_msg = f"Fehlende erforderliche Eigenschaft: {field}"
                logger.error(error_msg)
                raise HTTPException(status_code=400, detail=error_msg)
        
        # Zusätzliche Validierung für Listen und String-Felder
        if not isinstance(body["questions"], list):
            raise HTTPException(status_code=400, detail="'questions' muss eine Liste sein")
        if not isinstance(body["userAnswers"], list):
            raise HTTPException(status_code=400, detail="'userAnswers' muss eine Liste sein")
        if not isinstance(body["feedback"], list):
            raise HTTPException(status_code=400, detail="'feedback' muss eine Liste sein")
        
        # Validiere Timestamp-Format
        if not isinstance(body["timestamp"], str):
            logger.warning(f"timestamp ist nicht im String-Format: {body['timestamp']}")
        
        try:
            new_result = Result(
                user_id=user_id,
                subject=body["fach"],
                topic=body["topic"],
                questions=json.dumps(body["questions"]),
                user_answers=json.dumps(body["userAnswers"]),
                feedback=json.dumps(body["feedback"]),
                timestamp=body["timestamp"],
            )
            db.add(new_result)
            db.commit()
            logger.info(f"Ergebnis für user_id {user_id} erfolgreich gespeichert. ID: {new_result.id}")
            return {"status": "ok", "id": new_result.id}
        except Exception as db_error:
            db.rollback()
            logger.error(f"Datenbank-Fehler: {str(db_error)}")
            logger.error(traceback.format_exc())
            raise HTTPException(status_code=500, detail=f"Datenbank-Fehler: {str(db_error)}")
    
    except json.JSONDecodeError as e:
        error_msg = f"Ungültiges JSON Format: {str(e)}"
        logger.error(error_msg)
        raise HTTPException(status_code=400, detail=error_msg)
    except HTTPException:
        raise
    except Exception as e:
        error_msg = f"Fehler beim Speichern: {str(e)}"
        logger.error(error_msg)
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=error_msg)

@app.get("/get_results/{user_id}/{fach}")
@limiter.limit("20/minute")
async def get_results(user_id: str, fach: str, request: Request, db: Session = Depends(get_db)):
    try:
        logger.info(f"Abfrage der Ergebnisse für user_id: {user_id}, fach: {fach}")
        
        # Query für Ergebnisse mit user_id
        results = db.query(Result).filter(Result.user_id == user_id, Result.subject == fach).all()
        logger.info(f"Gefundene Ergebnisse: {len(results)}")
            
        return [
            {
                "id": r.id,
                "fach": r.subject,
                "topic": r.topic,
                "questions": json.loads(r.questions) if r.questions else [],
                "userAnswers": json.loads(r.user_answers) if r.user_answers else [],
                "feedback": json.loads(r.feedback) if r.feedback else [],
                "timestamp": r.timestamp
            }
            for r in results
        ]
    except json.JSONDecodeError as e:
        error_msg = f"Fehler beim Verarbeiten von JSON-Daten: {str(e)}"
        logger.error(error_msg)
        raise HTTPException(status_code=500, detail=error_msg)
    except Exception as e:
        error_msg = f"Fehler beim Abrufen der Ergebnisse: {str(e)}"
        logger.error(error_msg)
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=error_msg)

@app.get("/healthcheck")
async def healthcheck():
    """
    Einfacher Gesundheitscheck-Endpunkt zur Überprüfung des Backend-Status.
    """
    try:
        # Teste Datenbankverbindung
        db = next(get_db())
        result = db.execute("SELECT 1").scalar()
        return {
            "status": "healthy", 
            "database": "connected",
            "db_type": "MariaDB",
            "db_test_result": result
        }
    except Exception as e:
        logger.error(f"Gesundheitscheck fehlgeschlagen: {str(e)}")
        return {"status": "unhealthy", "error": str(e)}, 500

@app.get("/insert_test_data/{user_id}")
async def insert_test_data(user_id: str, db: Session = Depends(get_db)):
    """
    Hilfsfunktion zum Einfügen von Testdaten
    """
    try:
        # Erstelle ein Testdatensatz
        test_result = Result(
            user_id=user_id,
            subject="Mathematik",
            topic="Testthema",
            questions=json.dumps(["Was ist 2+2?", "Was ist 5*5?"]),
            user_answers=json.dumps(["4", "25"]),
            feedback=json.dumps(["richtig", "richtig"]),
            timestamp="2023-05-30T12:00:00"
        )
        db.add(test_result)
        db.commit()
        
        return {"status": "ok", "id": test_result.id, "message": "Testdaten erfolgreich eingefügt"}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
