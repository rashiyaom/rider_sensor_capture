#!/usr/bin/env bash
#
# Launches the app with the secrets from the local `.env` file injected as
# compile-time `--dart-define` values.
#
#   ./tool/run.sh                 # debug run on the connected device
#   ./tool/run.sh --release       # release run
#   ./tool/run.sh build apk       # build a release APK
#
# `.env` is git-ignored and never committed. Use `.env.example` as a template.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

ENV_FILE=".env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "⚠️  $ENV_FILE not found — continuing without it."
  echo "   Copy .env.example to .env and add your GROQ_API_KEY."
  echo "   The app stays fully functional: the feedback analyzer falls back"
  echo "   to the offline heuristic evaluator when no key is present."
  echo
  exec flutter "$@"
fi

# Parse KEY=VALUE pairs (ignores comments, blank lines and export prefixes).
DEFINES=()
while IFS='=' read -r key value || [[ -n "${key// /}" ]]; do
  key="${key#"${key%%[![:space:]]*}"}"   # trim leading whitespace
  key="${key#export }"
  value="${value%"${value##*[![:space:]]}"}" # trim trailing whitespace
  key="${key%"${key##*[![:space:]]}"}"

  [[ -z "$key" || "$key" == \#* ]] && continue
  # Strip surrounding single/double quotes.
  value="${value%\"}"; value="${value#\"}"
  value="${value%\'}"; value="${value#\'}"

  case "$key" in
    GROQ_API_KEY|GROQ_MODEL|GROQ_BASE_URL)
      DEFINES+=("--dart-define=$key=$value")
      ;;
  esac
done < "$ENV_FILE"

if [[ ${#DEFINES[@]} -eq 0 ]]; then
  echo "⚠️  No GROQ_* entries found in $ENV_FILE — continuing without them."
  exec flutter "$@"
fi

echo "🔑 Loaded ${#DEFINES[@]} dart-define(s) from $ENV_FILE"
exec flutter "${DEFINES[@]}" "$@"
