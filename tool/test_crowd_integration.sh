#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" && -x /opt/homebrew/opt/openjdk@21/bin/java ]]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk@21
  export PATH="$JAVA_HOME/bin:$PATH"
fi
if [[ "$(uname -s)" == "Darwin" && -x /opt/homebrew/opt/node@22/bin/node ]]; then
  export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
fi

cd "$PROJECT_ROOT"
export FIREBASE_CLI_DISABLE_UPDATE_CHECK=1
firebase emulators:exec --only firestore,functions 'cd functions && node --test test/crowd.integration.js'
