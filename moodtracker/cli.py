# moodtracker/cli.py
from __future__ import annotations

import typer
from pydantic import ValidationError

from models import Session
from questions import load_questions, parse_answer
from analysis import daily_mood_stats, add_rolling_avg
from storage import save_session, load_sessions_df

app = typer.Typer(help="Mood tracker CLI (Typer + Pydantic + Polars)")


@app.command()
def ask():
    """
    Ask the questions defined in questions.yml and save a new session.
    """
    questions = load_questions()
    answers: dict[str, object] = {}

    typer.echo("Answer the following questions. Ctrl+C to cancel.\n")

    for q in questions:
        while True:
            raw = typer.prompt(q.text, default="" if not q.required else None)
            try:
                value = parse_answer(q, raw)
            except ValueError as e:
                typer.echo(f"❌ Invalid input: {e}")
                continue
            answers[q.field] = value
            break

    # Build Session model with Pydantic validation
    try:
        session = Session(**answers)
    except ValidationError as e:
        typer.echo("❌ Could not create session, validation errors:")
        typer.echo(e)
        raise typer.Exit(code=1)

    save_session(session)
    typer.echo("✅ Session saved.")


@app.command()
def show(last: int = typer.Option(10, help="Number of recent entries to print")):
    """
    Show the last N entries in raw form.
    """
    df = load_sessions_df()
    if df.is_empty():
        typer.echo("No entries yet. Run `mood ask` first.")
        raise typer.Exit(code=0)

    df_sorted = df.sort("timestamp", descending=True).head(last)
    typer.echo(df_sorted.to_pandas().to_string(index=False))


@app.command()
def analyze(window: int = typer.Option(7, help="Rolling window (days)")):
    """
    Show simple mood stats by day, with a rolling average.
    """
    df = load_sessions_df()
    if df.is_empty():
        typer.echo("No entries yet. Run `mood ask` first.")
        raise typer.Exit(code=0)

    daily = daily_mood_stats(df)
    daily = add_rolling_avg(daily, window=window)

    typer.echo(daily.to_pandas().tail(20).to_string(index=False))


def main():
    app()


if __name__ == "__main__":
    main()
