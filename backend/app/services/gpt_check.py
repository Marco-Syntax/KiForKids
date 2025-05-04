"""
Service-Modul für die KI-basierte Antwortprüfung mittels OpenAI GPT.
Lädt den API-Key aus der .env-Datei und stellt eine asynchrone Funktion bereit,
die Schülerantworten zu Aufgaben prüft und Feedback gibt.
"""

import os
from typing import List
from dotenv import load_dotenv
import openai
from ..models.request_models import AnswerCheckRequest

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

def check_answers(data: AnswerCheckRequest) -> List[str]:
    """
    Prüft Antworten mit GPT für das gegebene Daten-Dictionary.
    Erwartet Felder: subject, topic, level, questions, answers.
    Gibt eine Liste von Feedback-Strings zurück.
    """
    subject = data.subject
    topic = data.topic
    level = data.level
    questions = data.questions
    answers = data.answers

    prompt = (
        "Du bist ein herausragender, empathischer KI-Lehrer und kontrollierst die Antworten von Schülern. "
        "Jede Aufgabe ist eine Ja/Nein-Frage und kann eindeutig mit 'richtig' oder 'falsch' beantwortet werden. "
        "Vergleiche die Schülerantworten mit der korrekten Lösung. "
        "Beurteile jede Antwort als 'richtig' oder 'falsch' und gib, falls falsch, die richtige Lösung an. "
        "Antworte als nummerierte Liste, jede Zeile im Format: 'richtig' oder 'falsch (richtige Lösung: ... )'. "
        "Groß- und Kleinschreibung sowie Leerzeichen sollen ignoriert werden.\n"
    )
    for i, (q, a) in enumerate(zip(questions, answers)):
        prompt += f"{i+1}. Aufgabe: {q}\n   Schülerantwort: {a}\n"

    system_prompt = (
        "Du bist ein KI-Lehrer, der Ja/Nein-Aufgaben freundlich, motivierend und fachlich korrekt kontrolliert. "
        "Du gibst für jede Aufgabe eine Rückmeldung, ob die Antwort richtig oder falsch ist, und falls falsch, die richtige Lösung ('richtig' oder 'falsch'). "
        "Groß- und Kleinschreibung soll bei der Bewertung ignoriert werden."
    )

    response = openai.chat.completions.create(
        model="gpt-4.1-nano",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        max_tokens=512,
        temperature=0.3,
    )

    content = response.choices[0].message.content
    lines = [line.strip() for line in content.split('\n') if line.strip() and line.strip()[0].isdigit()]
    feedback = []
    for line in lines:
        idx = line.find(' ')
        feedback.append(line[idx+1:].strip() if idx > 0 else line)
    if not feedback:
        feedback = [l for l in content.split('\n') if l.strip()]
    return feedback
