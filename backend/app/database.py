import os
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import logging
import time
import sys

# Logging konfigurieren
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Lade Umgebungsvariablen aus .env-Datei
load_dotenv()

# Hole Datenbankverbindungsinformationen aus Umgebungsvariablen
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")
DB_NAME = os.getenv("DB_NAME", "homeschool")

# MariaDB-Verbindungsstring
SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
logger.info(f"Verwende MariaDB: {DB_HOST}:{DB_PORT}/{DB_NAME} als {DB_USER}")

# Wiederholungsversuche für die DB-Verbindung
max_retries = 5
retry_count = 0
connected = False

# Deklariere engine außerhalb der Schleife, damit sie auch bei Fehlern verfügbar ist
engine = None

while retry_count < max_retries and not connected:
    try:
        logger.info(f"Verbindungsversuch {retry_count+1} zur MariaDB...")
        engine = create_engine(SQLALCHEMY_DATABASE_URL)
        
        # Testverbindung
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            logger.info(f"Verbindungstest Ergebnis: {result.fetchone()}")
        
        connected = True
        logger.info("MariaDB-Verbindung erfolgreich hergestellt!")
    except Exception as e:
        retry_count += 1
        logger.error(f"Fehler bei der MariaDB-Verbindung: {e}")
        if retry_count < max_retries:
            wait_time = retry_count * 2  # Exponentielle Wartezeit
            logger.info(f"Warte {wait_time} Sekunden vor dem nächsten Versuch...")
            time.sleep(wait_time)
        else:
            logger.critical("Maximale Anzahl an Verbindungsversuchen erreicht!")
            logger.critical("MariaDB ist nicht erreichbar - Beende Anwendung")
            sys.exit(1)  # Beende die Anwendung, wenn keine Verbindung möglich ist

# Wenn wir hier ankommen, haben wir eine gültige Verbindung
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
Base = declarative_base()

def get_db():
    """Gibt eine Datenbankverbindung zurück und schließt sie nach Verwendung"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """Initialisiert die Datenbank und erstellt Tabellen bei Bedarf"""
    from app.models.result import Result
    
    try:
        # Überprüfe, ob die Tabelle existiert
        with engine.connect() as conn:
            result = conn.execute(text("SHOW TABLES LIKE 'results'"))
            table_exists = result.fetchone() is not None
        
        if not table_exists:
            logger.info("Die 'results' Tabelle existiert nicht. Wird erstellt...")
            Base.metadata.create_all(bind=engine)
            logger.info("Tabellen erfolgreich erstellt.")
        else:
            logger.info("Die 'results' Tabelle existiert bereits.")
    except Exception as e:
        logger.error(f"Fehler bei der DB-Initialisierung: {str(e)}")
        raise