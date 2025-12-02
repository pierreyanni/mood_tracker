# moodtracker/questions.py
from __future__ import annotations

from typing import List, Literal, Optional

import yaml
from pydantic import BaseModel, Field

from config import get_builtin_questions_path


# Restrict question definitions to these allowed string types for validation.
QuestionType = Literal["int", "text"]


class Question(BaseModel):
    id: str
    field: str  # field name in Session model ("mood", "note", etc.)
    text: str
    type: QuestionType
    required: bool = True

    # Optional numeric constraints
    min: Optional[int] = None
    max: Optional[int] = None

    # Optional text constraint
    min_length: Optional[int] = None


def load_questions() -> List[Question]:
    """
    Load question specs from questions.yml and parse them as Question models.
    """
    path = get_builtin_questions_path()
    data = yaml.safe_load(path.read_text(encoding="utf-8"))

    return [Question(**q) for q in data]


def parse_answer(q: Question, raw: str) -> object:
    """
    Very small interpreter for question definitions.
    Returns a Python object suitable to feed into Session(**answers).
    """
    if not raw and not q.required:  # only satisfied if nothing and not required -> None
        return None

    if q.type == "int":
        try:
            value = int(raw)
        except ValueError:
            raise ValueError("Must be an integer")
        if q.min is not None and value < q.min:
            raise ValueError(f"Must be >= {q.min}")
        if q.max is not None and value > q.max:
            raise ValueError(f"Must be <= {q.max}")
        return value

    if q.type == "text":
        value = raw.strip()
        if q.min_length is not None and len(value) < q.min_length:
            raise ValueError(f"Must be at least {q.min_length} characters")
        return value or None

    # Should never happen if QuestionType is respected
    return raw
