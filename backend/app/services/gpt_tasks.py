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
import re
import time
from app.models.request_models import TaskRequest

# Logger-Konfiguration
logger = logging.getLogger("gpt_tasks")
logging.basicConfig(level=logging.INFO)

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

def generate_tasks(data: TaskRequest) -> List[dict]:
    """
    Generiert genau 3 Aufgaben mit GPT für das gegebene Daten-Dictionary.
    Erwartet Felder wie 'subject', 'topic', 'level', 'testMode', 'usedQuestions', 'classTopics'.
    Gibt eine Liste von Dicts mit 'question' und 'answer' zurück.
    """
    subject = data.subject
    topic = data.topic
    level = data.level
    test_mode = data.testMode
    used_questions = data.usedQuestions
    class_topics = data.classTopics
    count = getattr(data, "count", 3)  # Standardmäßig 3 Aufgaben, falls nicht anders angegeben
    
    # Stellen wir sicher, dass count eine sinnvolle Zahl ist
    try:
        count = int(count)
        if count < 1:
            count = 3  # Fallback auf 3, wenn eine ungültige Zahl angegeben wurde
    except (ValueError, TypeError):
        count = 3  # Fallback auf 3, wenn keine Zahl angegeben wurde

    # Testmodus-abhängiger Prompt
    if isinstance(test_mode, str):
        test_mode_str = test_mode.lower()
    else:
        test_mode_str = str(test_mode).lower()

    if test_mode_str == "bool" or test_mode is True:
        aufgaben_typ = f"Richtig/Falsch-Fragen (genau {count} Fragen, Antwort: 'richtig' oder 'falsch')"
        antwort_format = "Die Antwort ist immer 'richtig' oder 'falsch'."
        special_instructions = ("Formuliere Aussagen, bei denen eindeutig als richtig oder falsch "
                              "bewertet werden kann. Achte darauf, dass keine Interpretationsspielräume entstehen.")
        output_format = "Frage = Antwort"
    elif test_mode_str == "input":
        aufgaben_typ = f"offene Fragen (genau {count} Fragen), die mit einem Wort oder einer Zahl beantwortet werden können"
        antwort_format = "Die Antwort ist ein Wort oder eine Zahl."
        special_instructions = ("Formuliere präzise Fragen, die eindeutig mit einem Wort oder einer Zahl "
                             "beantwortet werden können. Vermeide Fragen, die mehrere korrekte Antworten haben könnten.")
        output_format = "Frage = Antwort"
    elif test_mode_str == "mc":
        aufgaben_typ = f"Multiple-Choice-Fragen (genau {count} Fragen) mit vier Antwortmöglichkeiten (A, B, C, D)"
        antwort_format = "Die Antwort ist einer der Buchstaben: A, B, C oder D."
        special_instructions = (
            "Erstelle für jede Frage genau vier unterschiedliche Antwortmöglichkeiten, wobei nur eine korrekt ist. "
            "Die Optionen müssen klar mit A, B, C, D gekennzeichnet werden und inhaltlich sinnvolle, ausformulierte Antwortmöglichkeiten sein. "
            "WICHTIG: Gib für jede Frage alle vier Optionen explizit an!"
        )
        output_format = (
            "Frage\n"
            "optionA: Erste Antwortmöglichkeit\n"
            "optionB: Zweite Antwortmöglichkeit\n"
            "optionC: Dritte Antwortmöglichkeit\n"
            "optionD: Vierte Antwortmöglichkeit\n"
            "answer: Korrekte Option (A, B, C oder D)"
        )
    else:
        aufgaben_typ = f"kurze, eindeutige Aufgaben (genau {count} Fragen)"
        antwort_format = "Die Antwort ist ein Wort oder eine Zahl."
        special_instructions = "Achte auf Eindeutigkeit und passende Schwierigkeit."
        output_format = "Frage = Antwort"

    # System-Nachricht anpassen
    system_message = (
        f"Du bist ein präziser Aufgaben-Generator für den Schulkontext. "
        f"Formuliere GENAU {count} Fragen zum angegebenen Thema. Jede Aufgabe soll eindeutig "
        f"mit genau einer korrekten Lösung sein."
    )

    prompt = (
        f"Du bist ein herausragender, empathischer KI-Lehrer für das Fach {subject} an Gymnasien in Deutschland. "
        f"Erstelle genau {count} präzise {aufgaben_typ} zum Thema '{topic}' für Schüler:innen "
        f"(Schwierigkeitsgrad: {level}). "
        f"{special_instructions} "
        f"{antwort_format} "
    )
    if class_topics:
        prompt += f"Beziehe folgende relevante Themen ein: {', '.join(class_topics)}. "
    if used_questions:
        prompt += f"Vermeide diese Aufgaben (bereits verwendet): {', '.join(used_questions)}. "
    
    # Unterschiedliches Format-Anweisungen je nach Test-Modus
    if test_mode_str == "mc":
        prompt += (
            f"Formatiere die Aufgaben im folgenden Format:\n\n"
            f"1. Frage\n"
            f"optionA: Erste Antwortmöglichkeit\n"
            f"optionB: Zweite Antwortmöglichkeit\n"
            f"optionC: Dritte Antwortmöglichkeit\n"
            f"optionD: Vierte Antwortmöglichkeit\n"
            f"answer: Korrekte Option (A, B, C oder D)\n\n"
            f"WICHTIG: Generiere genau {count} Fragen, nicht mehr und nicht weniger."
        )
    else:
        prompt += (
            f"Formatiere die Aufgaben so: Jede Aufgabe beginnt auf einer neuen Zeile mit der Frage, "
            f"gefolgt von einem Gleichheitszeichen und dann der Antwort. "
            f"Schema: Frage = Antwort\n\n"
            f"WICHTIG: Generiere genau {count} Fragen, nicht mehr und nicht weniger."
        )

    logger.info(f"Prompt an GPT: {prompt}")

    response = openai.chat.completions.create(
        model="gpt-4.1-nano",
        messages=[
            {"role": "system", "content": system_message},
            {"role": "user", "content": prompt}
        ],
        max_tokens=3000,
        temperature=0.7,
    )

    content = response.choices[0].message.content
    logger.info(f"GPT-Response: {content}")

    # Extrahiere die Aufgaben als Liste (angepasst für verschiedene Formate)
    tasks = []
    
    if test_mode_str == "mc":
        # Teile den Content in Abschnitte pro Frage auf
        # Eine MC-Frage hat das Format: "Frage\noptionA: ...\noptionB: ...\noptionC: ...\noptionD: ...\nanswer: ..."
        pattern = r'(?:\d+\.\s*|\n\d+\.\s*|\(\d+\)\s*)(.*?)(?:\n(?:\d+\.\s*|\(\d+\)\s*)|$)'
        sections = re.split(pattern, content)[1::2]  # Nur die tatsächlichen Abschnitte nehmen
        
        if not sections:
            # Alternativer Ansatz, wenn die reguläre Teilung fehlschlägt
            sections = content.split("\n\n")
        
        for section in sections:
            lines = section.strip().split('\n')
            if not lines:
                continue
                
            task = {"question": "", "optionA": "", "optionB": "", "optionC": "", "optionD": "", "answer": ""}
            
            # Erste Zeile ist die Frage
            task["question"] = lines[0].strip()
            
            # Suche nach Optionen und Antwort in den folgenden Zeilen
            for line in lines[1:]:
                line = line.strip()
                if line.lower().startswith("optiona:") or line.lower().startswith("option a:"):
                    task["optionA"] = line.split(":", 1)[1].strip()
                elif line.lower().startswith("optionb:") or line.lower().startswith("option b:"):
                    task["optionB"] = line.split(":", 1)[1].strip()
                elif line.lower().startswith("optionc:") or line.lower().startswith("option c:"):
                    task["optionC"] = line.split(":", 1)[1].strip()
                elif line.lower().startswith("optiond:") or line.lower().startswith("option d:"):
                    task["optionD"] = line.split(":", 1)[1].strip()
                elif line.lower().startswith("answer:") or line.lower().startswith("correct:"):
                    answer_text = line.split(":", 1)[1].strip()
                    # Extrahiere nur den Buchstaben (A, B, C oder D)
                    if "a" in answer_text.lower():
                        task["answer"] = "A"
                    elif "b" in answer_text.lower():
                        task["answer"] = "B"
                    elif "c" in answer_text.lower():
                        task["answer"] = "C"
                    elif "d" in answer_text.lower():
                        task["answer"] = "D"
            
            # Nur vollständige Aufgaben hinzufügen
            if task["question"] and all(task[f"option{opt}"] for opt in ["A", "B", "C", "D"]) and task["answer"]:
                tasks.append(task)
    else:
        # Standard-Verarbeitung für nicht-MC-Aufgaben
        lines = [line.strip() for line in content.split('\n') if line.strip()]
        for line in lines:
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
    
    logger.info(f"Extrahierte Aufgaben: {len(tasks)} gefunden")
    
    # Stellen wir sicher, dass wir die angeforderte Anzahl an Aufgaben haben
    if len(tasks) != count:
        logger.warning(f"Erwartete {count} Aufgaben, aber {len(tasks)} extrahiert. Passe an...")
        
        # Wenn wir zu wenig Aufgaben haben, fülle mit generischen Aufgaben auf
        if len(tasks) < count:
            for i in range(len(tasks), count):
                if test_mode_str == "mc":
                    tasks.append({
                        "question": f"Frage {i+1} zum Thema {topic}",
                        "optionA": "Erste Antwortmöglichkeit",
                        "optionB": "Zweite Antwortmöglichkeit",
                        "optionC": "Dritte Antwortmöglichkeit",
                        "optionD": "Vierte Antwortmöglichkeit",
                        "answer": "A"
                    })
                else:
                    tasks.append({
                        "question": f"Frage {i+1} zum Thema {topic}",
                        "answer": "richtig" if test_mode_str == "bool" or test_mode is True else "Keine Antwort verfügbar"
                    })
        # Wenn wir zu viele Aufgaben haben, beschränke auf die angeforderte Anzahl
        elif len(tasks) > count:
            tasks = tasks[:count]
    
    return tasks
