"""
Service-Modul für das Generieren von Aufgaben mittels OpenAI GPT.
Lädt den API-Key aus der .env-Datei und stellt eine asynchrone Funktion bereit,
die Aufgaben für ein bestimmtes Fach/Klasse/Level generiert.
"""

import os
from typing import List
from dotenv import load_dotenv
import openai
import logging
from app.models.request_models import TaskRequest
from fastapi.responses import JSONResponse

# Logger-Konfiguration
logger = logging.getLogger("gpt_tasks")
logging.basicConfig(level=logging.INFO)

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

def generate_tasks(data: TaskRequest) -> List[dict]:
    """
    Generiert Aufgaben mit GPT für das gegebene Daten-Dictionary.
    Erwartet Felder wie 'subject', 'topic', 'level', 'testMode', 'usedQuestions', 'classTopics'.
    Gibt eine Liste von Dicts mit 'question' und 'answer' zurück.
    """
    subject = data.subject
    topic = data.topic
    level = data.level
    test_mode = data.testMode
    used_questions = data.usedQuestions
    class_topics = data.classTopics

    # Testmodus-abhängiger Prompt
    if isinstance(test_mode, str):
        test_mode_str = test_mode.lower()
    else:
        test_mode_str = str(test_mode).lower()

    if test_mode_str == "bool" or test_mode is True:
        aufgaben_typ = "Richtig/Falsch-Fragen (Antwort: 'richtig' oder 'falsch')"
        antwort_format = "Die Antwort ist immer 'richtig' oder 'falsch'."
    elif test_mode_str == "input":
        aufgaben_typ = "offene Fragen, die mit einem Wort oder einer Zahl beantwortet werden können"
        antwort_format = "Die Antwort ist ein Wort oder eine Zahl."
    elif test_mode_str == "mc":
        aufgaben_typ = "Multiple-Choice-Fragen mit vier Antwortmöglichkeiten (A, B, C, D). Gib die richtige Lösung als Buchstabe an."
        antwort_format = "Die Antwort ist einer der Buchstaben: A, B, C oder D."
    else:
        aufgaben_typ = "kurze, eindeutige Aufgaben"
        antwort_format = "Die Antwort ist ein Wort oder eine Zahl."

    prompt = (
        f"Du bist ein Aufgaben-Generator für das Fach {subject}. "
        f"Erstelle 3 {aufgaben_typ} für das Thema '{topic}' "
        f"(Schwierigkeitsgrad: {level}). "
    )
    if class_topics:
        prompt += f"Folgende Themen sind für die Klasse relevant: {', '.join(class_topics)}. "
    if used_questions:
        prompt += f"Vermeide diese Aufgaben (bereits verwendet): {', '.join(used_questions)}. "
    prompt += (
        f"{antwort_format} "
        "Gib die Aufgaben als nummerierte Liste im Format 'Frage = Antwort' zurück. "
        "Beispiel: 1. Was ist 2+2? = 4"
    )

    logger.info(f"Prompt an GPT: {prompt}")

    response = openai.chat.completions.create(
        model="gpt-4.1-nano",
        messages=[
            {"role": "system", "content": "Du bist ein Aufgaben-Generator für Schüler:innen. Jede Aufgabe muss die richtige Lösung enthalten. Format: Frage = Antwort."},
            {"role": "user", "content": prompt}
        ],
        max_tokens=1000,
        temperature=0.4,
    )

    content = response.choices[0].message.content
    logger.info(f"GPT-Response: {content}")

    # Extrahiere die Aufgaben als Liste (robust für verschiedene Nummerierungsformate)
    lines = [line.strip() for line in content.split('\n') if line.strip()]
    tasks = []
    for line in lines:
        # Erkenne Zeilen wie "1. Frage = Antwort"
        if "=" in line:
            # Entferne Nummerierung am Anfang
            parts = line.split("=", 1)
            question_part = parts[0].strip()
            answer_part = parts[1].strip()
            # Entferne führende Nummerierung (z.B. "1. ", "2) ", etc.)
            q = question_part
            if q and q[0].isdigit():
                q = q.lstrip("0123456789.:-) ").strip()
            question = q.encode("utf-8").decode("utf-8")
            answer = answer_part.encode("utf-8").decode("utf-8")
            tasks.append({"question": question, "answer": answer})
    if not tasks:
        # Fallback: gib alle Zeilen als Frage ohne Antwort zurück
        tasks = [{"question": l, "answer": ""} for l in lines]
    logger.info(f"Extrahierte Aufgaben: {tasks}")
    return JSONResponse(content={"tasks": tasks}, ensure_ascii=False)
