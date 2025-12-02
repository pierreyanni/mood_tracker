# tests/test_models.py
from datetime import datetime

from moodtracker.models import Session


def test_session_basic():
    s = Session(mood=7, energy=5, note="ok", tags=["test"])
    assert s.mood == 7
    assert s.energy == 5
    assert "ok" in (s.note or "")
    assert isinstance(s.timestamp, datetime)
