#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The macOS host previously selected an Intel Java 17 runtime, which prevented
# the ARM Firestore emulator from starting. Prefer the native Homebrew JDK 21.
if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" && -x /opt/homebrew/opt/openjdk@21/bin/java ]]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk@21
  export PATH="$JAVA_HOME/bin:$PATH"
fi
if [[ "$(uname -s)" == "Darwin" && -x /opt/homebrew/opt/node@22/bin/node ]]; then
  export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
fi

JAVA_VERSION="$(java -version 2>&1 | awk -F '"' '/version/ {print $2; exit}')"
JAVA_MAJOR="${JAVA_VERSION%%.*}"
if [[ "$JAVA_MAJOR" -lt 21 ]]; then
  echo "Firestore emulator requires Java 21 or newer; found $JAVA_VERSION." >&2
  exit 1
fi

cd "$PROJECT_ROOT"
export FIREBASE_CLI_DISABLE_UPDATE_CHECK=1
firebase emulators:exec --only firestore 'cd functions && node --test test/firestore.rules.js'
