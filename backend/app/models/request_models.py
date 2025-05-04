from pydantic import BaseModel
from typing import List, Optional

class TaskRequest(BaseModel):
    subject: str
    topic: str
    level: Optional[str] = "leicht"
    testMode: Optional[bool] = False
    usedQuestions: Optional[List[str]] = []
    classTopics: Optional[List[str]] = []
    
class AnswerCheckRequest(BaseModel):
    subject: str
    topic: str
    level: Optional[str] = "leicht"
    questions: List[str]
    answers: List[str]