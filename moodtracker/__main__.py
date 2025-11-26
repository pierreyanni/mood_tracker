import typer

app = typer.Typer(help="Mood Tracker CLI")


@app.command()
def hello(name: str = "world"):
    """Placeholder command until real features ship."""
    typer.echo(f"Hello, {name}! Mood tracking coming soon.")


def main() -> None:
    app()


if __name__ == "__main__":
    main()
