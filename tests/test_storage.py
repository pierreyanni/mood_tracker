# tests/test_storage.py
from pathlib import Path
from tempfile import TemporaryDirectory

from moodtracker.models import Session
from moodtracker.storage import save_session, load_sessions_df
from moodtracker import config as config_module


def test_save_and_load_monkeypatched(tmp_path, monkeypatch):
    # Monkeypatch get_sessions_path to use tmp dir
    def fake_get_sessions_path() -> Path:
        return tmp_path / "sessions.parquet"

    monkeypatch.setattr(config_module, "get_sessions_path", fake_get_sessions_path)

    s1 = Session(mood=6)
    save_session(s1)

    df = load_sessions_df()
    assert df.height == 1
    assert "mood" in df.columns
    assert df["mood"][0] == 6
