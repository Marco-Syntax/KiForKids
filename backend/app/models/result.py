from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.ext.declarative import declarative_base
import json
from app.database import Base

class Result(Base):
    __tablename__ = 'results'
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(String(255), index=True, nullable=False)  # Nutzer-ID sollte nicht null sein
    subject = Column(String(255), nullable=False)  # Fach
    topic = Column(String(255), nullable=False)    # Thema
    questions = Column(Text)  # JSON als String
    user_answers = Column(Text)  # JSON als String
    feedback = Column(Text)      # JSON als String
    timestamp = Column(String(30), nullable=False)  # ISO-Zeitstempel als String
    
    def __repr__(self):
        return f"<Result(id={self.id}, user_id='{self.user_id}', subject='{self.subject}')>"
    
    @property
    def questions_list(self):
        """Konvertiert den gespeicherten JSON-String in eine Python-Liste"""
        if not self.questions:
            return []
        try:
            return json.loads(self.questions)
        except json.JSONDecodeError:
            return []
    
    @property
    def user_answers_list(self):
        """Konvertiert den gespeicherten JSON-String in eine Python-Liste"""
        if not self.user_answers:
            return []
        try:
            return json.loads(self.user_answers)
        except json.JSONDecodeError:
            return []
    
    @property
    def feedback_list(self):
        """Konvertiert den gespeicherten JSON-String in eine Python-Liste"""
        if not self.feedback:
            return []
        try:
            return json.loads(self.feedback)
        except json.JSONDecodeError:
            return []