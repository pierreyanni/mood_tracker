#!/usr/bin/env bash
set -euo pipefail

TOKEN="ADD TOKEN HERE"
REPO="pierreyanni/mood_tracker"
API="https://api.github.com/repos/$REPO"

if [ "$TOKEN" = "YOUR_TOKEN_HERE" ]; then
  echo ">>> Please edit this script and set TOKEN to your GitHub PAT."
  exit 1
fi

COMMON_HEADERS=(
  -H "Authorization: token $TOKEN"
  -H "Accept: application/vnd.github+json"
)

echo "Using repo: $REPO"
echo "Creating labels (if they don't already exist)..."

# --- Labels ---
curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "status: backlog",
  "color": "ededed",
  "description": "Not ready to work on yet"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "status: todo",
  "color": "1d76db",
  "description": "Ready to be picked up"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "status: polish",
  "color": "5319e7",
  "description": "Polish / refactor / docs"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "area: design",
  "color": "0052cc",
  "description": "Design & specification"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "area: infra",
  "color": "d93f0b",
  "description": "Project setup, tooling"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "area: data",
  "color": "1d76db",
  "description": "Storage, schemas, Polars"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "area: cli",
  "color": "5319e7",
  "description": "CLI & user interaction"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "area: analysis",
  "color": "fbca04",
  "description": "Analytics & plots"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "area: docs",
  "color": "0e8a16",
  "description": "Docs & README"
}' >/dev/null || true

curl -s -X POST "${COMMON_HEADERS[@]}" "$API/labels" -d '{
  "name": "area: future",
  "color": "cccccc",
  "description": "Future features (Option B/C)"
}' >/dev/null || true

echo "Labels created (or already existed)."
echo "Creating issues..."

# Helper: POST /issues
create_issue () {
  local title="$1"
  local body="$2"
  local labels_json="$3"

  curl -s -X POST "${COMMON_HEADERS[@]}" "$API/issues" -d "{
    \"title\": \"$title\",
    \"body\": \"$body\",
    \"labels\": $labels_json
  }" >/dev/null

  echo "Created issue: $title"
}

# 1) Design daily questions & data model
create_issue \
"Design daily mood questions and data model" \
"🎯 Goal\n\nDefine the set of daily questions and the corresponding data model so that:\n- It feels psychologically meaningful for you.\n- It stays simple enough to answer in < 2 minutes.\n- It maps cleanly to a Polars schema.\n\n---\n\nScope\n\n1) Scale questions (1–10): mood, energy (maybe stress, sleep quality).\n2) Free-text questions: highlight of the day, what was hard, gratitude.\n3) Optional tags: comma-separated tags like work, social, health, coding.\n4) Final Polars schema (example):\n   - date (date)\n   - time (time or datetime)\n   - mood (int 1–10)\n   - energy (int 1–10)\n   - highlight (str)\n   - lowlight (str)\n   - gratitude (str)\n   - tags (str or list[str]).\n\n💡 Example question set v0.1\n\n- Mood (1–10): \"Overall mood today, where 1 = awful and 10 = fantastic?\"\n- Energy (1–10): \"Energy level today, where 1 = exhausted and 10 = overflowing?\"\n- Highlight: \"Highlight of the day?\"\n- Lowlight: \"What was hard today?\"\n- Gratitude: \"Something you're grateful for?\"\n\n✅ Done when\n- [ ] A short list of questions is agreed for v0.1.\n- [ ] Fields and types are written down as a clear schema.\n- [ ] The schema is documented (README or docs/schema.md).\n" \
"[\"status: backlog\",\"area: design\"]"

# 2) Initialize uv project and folder structure
create_issue \
"Initialize uv project and folder structure" \
"🎯 Goal\n\nHave a clean, modern Python project using uv with a basic structure ready for the mood-tracker.\n\n---\n\nTasks\n\n1) Initialize the project with uv (if not already):\n\n   uv init mood_tracker\n\n2) Add dependencies:\n\n   uv add typer polars rich\n\n3) Create folder structure:\n\n   mood_tracker/\n     pyproject.toml\n     moodtracker/\n       __init__.py\n       cli.py\n       storage.py\n       analysis.py\n       questions.yml\n       data/\n\n4) Ensure module is runnable with uv, for example:\n\n   uv run python -m moodtracker --help\n\n✅ Done when\n- [ ] pyproject.toml exists and is managed by uv.\n- [ ] typer, polars, rich are added via uv.\n- [ ] Basic moodtracker package structure exists.\n- [ ] uv run python -m moodtracker --help runs without error (even with placeholder output).\n" \
"[\"status: todo\",\"area: infra\"]"

# 3) Implement Polars storage (append & read)
create_issue \
"Implement Polars storage (append and read entries)" \
"🎯 Goal\n\nImplement a minimal storage layer using Polars that can:\n- Append a new daily entry.\n- Read all entries into a DataFrame.\n- Handle the case where the data file does not exist yet.\n\n---\n\nTasks\n\n1) Decide on file format and location:\n   - Use Parquet, e.g. moodtracker/data/mood.parquet.\n\n2) Implement append_entry(entry: dict):\n   - Create a new Polars DataFrame from the dict.\n   - If file exists: read existing data, concat vertically, write back.\n   - If file does not exist: create parent directory and write new file.\n\n3) Implement read_all():\n   - If file does not exist: return an empty DataFrame.\n   - Else: read Parquet file into Polars.\n\n4) Handle types:\n   - Ensure date is stored as a proper date type.\n   - Ensure numeric columns (mood, energy) are ints.\n\n✅ Done when\n- [ ] append_entry creates the file if needed and appends rows correctly.\n- [ ] read_all returns a Polars DataFrame (possibly empty).\n- [ ] Manual test (Python REPL) confirms that round-trip read and write works.\n" \
"[\"status: todo\",\"area: data\"]"

# 4) Implement CLI 'log' command (Typer)
create_issue \
"Implement CLI 'log' command with Typer" \
"🎯 Goal\n\nCreate a log command using Typer to interactively record a daily mood entry and persist it via the storage layer.\n\n---\n\nTasks\n\n1) Create a Typer app in cli.py with a log command that:\n   - Asks for mood (1–10).\n   - Asks for energy (1–10).\n   - Asks for highlight, lowlight, gratitude.\n   - Uses current date and time.\n   - Calls append_entry with a dict matching the data model.\n\n2) Support running via:\n\n   uv run python -m moodtracker log\n\n3) Add basic validation:\n   - Ensure mood and energy are within 1–10.\n   - Simple error message if user types something invalid.\n\n💡 Example behavior\n\n- Prompt: \"Mood (1–10):\"\n- Prompt: \"Energy (1–10):\"\n- Prompt: \"Highlight of the day?\"\n- Prompt: \"What was hard today?\"\n- Prompt: \"Something you're grateful for?\"\n\n✅ Done when\n- [ ] uv run python -m moodtracker log asks the questions.\n- [ ] A new entry is appended to the Parquet file.\n- [ ] Obvious invalid inputs do not crash the app (basic validation only).\n" \
"[\"status: todo\",\"area: cli\",\"area: data\"]"

# 5) Add 'summary' command with Rich (last 7 days)
create_issue \
"Add 'summary' CLI command with Rich table (last 7 days)" \
"🎯 Goal\n\nDisplay a nice terminal summary of the last 7 days using Rich:\n- Date\n- Mood\n- Energy\n- Short highlight snippet\n\n---\n\nTasks\n\n1) Add Rich to the CLI (console and table).\n\n2) Implement summary command that:\n   - Reads all entries using read_all.\n   - Handles the case with no data (friendly message).\n   - Sorts by date.\n   - Selects the last N days (default 7).\n   - Prints a Rich table with date, mood, energy, trimmed highlight.\n\n3) Trim highlights to something like 40 characters with an ellipsis.\n\n✅ Done when\n- [ ] uv run python -m moodtracker summary shows a Rich table.\n- [ ] The table is correctly ordered by date.\n- [ ] The command prints a sensible message when there is no data.\n" \
"[\"status: todo\",\"area: cli\",\"area: analysis\"]"

# 6) Add basic analysis (7-day rolling averages)
create_issue \
"Add basic analysis for mood and energy (7-day rolling averages)" \
"🎯 Goal\n\nCompute simple analytics for mood and energy:\n- 7-day rolling average for mood.\n- 7-day rolling average for energy.\n\n---\n\nTasks\n\n1) Implement analysis logic in analysis.py:\n   - Read all data.\n   - Ensure date is parsed and sorted.\n   - Add rolling mean columns (e.g. mood_roll_7, energy_roll_7).\n\n2) Optionally expose via a stats command:\n   - Print last row with latest rolling averages.\n   - Maybe print min, max, average mood and energy.\n\n✅ Done when\n- [ ] A function computes and returns a DataFrame with rolling averages.\n- [ ] You can inspect trends via print or an extra CLI command.\n" \
"[\"status: backlog\",\"area: analysis\"]"

# 7) Add minimal tests for storage and CLI
create_issue \
"Add minimal tests for storage and CLI" \
"🎯 Goal\n\nCreate a small but real test suite (pytest) that ensures:\n- Storage functions work as expected.\n- CLI app responds to basic commands.\n\n---\n\nTasks\n\n1) Add pytest as a dev dependency.\n\n2) Create tests/ directory with:\n   - test_storage.py\n   - test_cli.py\n\n3) Test storage:\n   - Use a temporary path for the data file.\n   - Call append_entry with a sample entry.\n   - Verify read_all returns one row with expected values.\n\n4) Test CLI (very basic):\n   - Use Typer testing utilities.\n   - Test that app --help returns exit code 0 and prints usage.\n\n✅ Done when\n- [ ] uv run pytest passes.\n- [ ] There is at least one meaningful test for storage.\n- [ ] There is at least one test for CLI help.\n" \
"[\"status: polish\",\"area: data\",\"area: cli\"]"

# 8) Externalize questions into YAML config
create_issue \
"Load questions from YAML config (questions.yml)" \
"🎯 Goal\n\nMove question definitions out of the code into a simple questions.yml file and load them dynamically in the CLI.\n\n---\n\nTasks\n\n1) Create questions.yml with scale_questions and free_text_questions.\n2) Implement loader function that reads the YAML.\n3) Update log command to:\n   - Iterate over scale questions and prompt user.\n   - Iterate over free-text questions and prompt user.\n   - Build entry dict using question ids as keys.\n\n✅ Done when\n- [ ] Questions are no longer hard-coded in the CLI.\n- [ ] Modifying questions.yml automatically changes the prompts.\n" \
"[\"status: backlog\",\"area: design\",\"area: cli\"]"

# 9) Polish CLI UX (defaults and confirmations)
create_issue \
"Polish CLI UX (defaults, confirmations, Rich output)" \
"🎯 Goal\n\nMake the CLI pleasant to use every day:\n- Provide small UX touches like defaults.\n- Use Rich for friendly confirmation messages.\n\n---\n\nTasks\n\n1) Consider pre-filling default values (e.g. last mood) or at least display last value in the prompt.\n2) Use Rich panels for a nice confirmation after saving an entry.\n3) Handle cancel or interrupt (Ctrl+C) gracefully with a friendly message instead of a stack trace.\n\n✅ Done when\n- [ ] Prompts feel clear and not annoying.\n- [ ] A confirmation message is clearly printed after saving.\n- [ ] Cancel or interrupt does not result in an ugly stack trace.\n" \
"[\"status: polish\",\"area: cli\"]"

# 10) Write README with usage, examples, and roadmap
create_issue \
"Write README with usage, examples, and project goals" \
"🎯 Goal\n\nHave a clear README that:\n- Explains what the project does and why.\n- Explains how to install and run it with uv.\n- Documents the data model and the roadmap (Option A, B, C).\n\n---\n\nSuggested sections\n\n1) Overview: personal mood tracker, daily questions, local storage.\n2) Installation with uv: clone repo, uv sync or uv pip install -e .\n3) Usage examples: log and summary commands.\n4) Data model: list of fields and types.\n5) Roadmap: CLI (Option A), small app (Option B), more advanced features (Option C).\n\n✅ Done when\n- [ ] README renders nicely on GitHub.\n- [ ] Someone with basic Python knowledge can install and use the tool.\n- [ ] The README accurately reflects the current state of the project.\n" \
"[\"status: polish\",\"area: docs\"]"

# 11) Future: small web UI (Option B)
create_issue \
"Future: explore small web UI for daily questions (Option B)" \
"🎯 Goal\n\nCapture ideas for a future web UI that could replace or complement the CLI.\nThis is a placeholder for Option B, not part of MVP A.\n\n---\n\nIdeas\n\n- Tech options: FastAPI plus templates, Streamlit, Panel.\n- Features:\n  - Browser-based form for daily questions.\n  - Small dashboard showing mood and energy trends.\n  - Basic filtering by tags.\n\n✅ Done when\n- [ ] A rough Option B idea is documented (no code required yet).\n" \
"[\"status: backlog\",\"area: future\"]"

echo "All issues created. Go to GitHub → Issues to see them."
