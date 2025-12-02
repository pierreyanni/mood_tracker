# moodtracker/storage.py
from __future__ import annotations

from typing import Iterable, List

import polars as pl

from config import get_sessions_path
from models import Session


def save_session(session: Session) -> None:
    """
    Append a single session to the Parquet file.

    Implementation is simple: read existing DF (if any), concat, rewrite.
    Fine for a personal tool.
    """
    path = get_sessions_path()
    new_df = pl.DataFrame([session.model_dump()])

    if path.exists():
        old_df = pl.read_parquet(path)
        df = pl.concat([old_df, new_df], how="vertical_relaxed")
    else:
        df = new_df

    df.write_parquet(path)


def load_sessions_df() -> pl.DataFrame:
    """
    Load all sessions as a Polars DataFrame. Returns empty DF if no file.
    """
    path = _sessions_path()
    if not path.exists():
        return pl.DataFrame()
    return pl.read_parquet(path)


def load_sessions() -> List[Session]:
    """
    Load all sessions as Pydantic models (if you ever need them).
    """
    df = load_sessions_df()
    if df.is_empty():
        return []
    return [Session(**row) for row in df.to_dicts()]
