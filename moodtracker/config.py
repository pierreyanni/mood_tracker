# moodtracker/config.py
from __future__ import annotations

from importlib.resources import files
from pathlib import Path


def get_data_dir() -> Path:
    """
    Directory where user data (sessions.parquet, etc.) is stored.
    """
    base = Path(__file__).resolve().parent / "data"
    base.mkdir(parents=True, exist_ok=True)
    return base


def get_sessions_path() -> Path:
    """
    Path to the main Parquet file used for storing sessions.
    """
    return get_data_dir() / "sessions.parquet"


def get_builtin_questions_path() -> Path:
    """
    Path to the bundled questions.yml inside the package.
    """
    return get_data_dir() / "questions.yml"
