# moodtracker/models.py
from __future__ import annotations

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class Session(BaseModel):
    """
    A single mood-tracking entry.
    """

    timestamp: datetime = Field(default_factory=datetime.utcnow)
    mood: int = Field(..., ge=1, le=10, description="Mood from 1 to 10")
    energy: Optional[int] = Field(
        None, ge=1, le=10, description="Energy from 1 to 10"
    )
    note: Optional[str] = Field(
        None, max_length=500, description="Short note about your day"
    )
    tags: List[str] = Field(
        default_factory=list, description="Simple free-form tags"
    )
