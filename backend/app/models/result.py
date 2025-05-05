from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class Result(Base):
    __tablename__ = 'results'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, index=True)
    subject = Column(String)
    topic = Column(String)
    questions = Column(Text)  # JSON als String
    user_answers = Column(Text)
    feedback = Column(Text)
    timestamp = Column(DateTime, default=datetime.utcnow)