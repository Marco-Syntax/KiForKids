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
