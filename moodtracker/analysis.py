# moodtracker/analysis.py
from __future__ import annotations

import polars as pl


def daily_mood_stats(df: pl.DataFrame) -> pl.DataFrame:
    """
    Compute average mood per day and number of entries.
    Expects columns: "timestamp", "mood".
    """
    if df.is_empty():
        return df

    return (
        df
        .with_columns(
            pl.col("timestamp").dt.date().alias("date")
        )
        .groupby("date")
        .agg(
            pl.col("mood").mean().alias("avg_mood"),
            pl.len().alias("n_entries"),
        )
        .sort("date")
    )


def add_rolling_avg(
    df_daily: pl.DataFrame, window: int = 7
) -> pl.DataFrame:
    """
    Add a rolling mean column of avg_mood over `window` days.
    """
    if df_daily.is_empty():
        return df_daily

    return df_daily.with_columns(
        pl.col("avg_mood")
        .rolling_mean(window_size=window)
        .alias(f"avg_mood_{window}d")
    )
