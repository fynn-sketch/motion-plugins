#!/usr/bin/env bash
# dispatch.sh — run one ExtendScript op in After Effects headless, poll its /tmp log.
# Usage: AE_APP="Adobe After Effects 2026" ./dispatch.sh /path/to/op.jsx [/tmp/ae_log.txt] [timeout_sec]
set -euo pipefail

AE_APP="${AE_APP:-Adobe After Effects 2026}"
JSX="${1:?need a .jsx path}"
LOG="${2:-/tmp/ae_log.txt}"
TIMEOUT="${3:-120}"

[ -f "$JSX" ] || { echo "jsx not found: $JSX" >&2; exit 1; }

# Confirm AE is running (osascript can't launch+script reliably; a Timeout -1712 otherwise looks like a hang).
if ! pgrep -f "$AE_APP" >/dev/null 2>&1; then
  echo "After Effects ('$AE_APP') does not appear to be running. Open it first." >&2
  exit 1
fi

# Fresh log so we only read this run's output.
: > "$LOG"

# Dispatch. AppleEvent may return Timeout (-1712) while the script keeps running — that's expected; we poll the log.
osascript -e "tell application \"$AE_APP\" to DoScript \"\$.evalFile(File(\\\"$JSX\\\"))\"" >/dev/null 2>&1 || true

# Poll the log for the DONE marker written by skeleton.jsx.
elapsed=0
while [ "$elapsed" -lt "$TIMEOUT" ]; do
  if grep -q "=== AE_DONE ===" "$LOG" 2>/dev/null; then
    cat "$LOG"; exit 0
  fi
  sleep 2; elapsed=$((elapsed + 2))
done

echo "--- log so far ---"; cat "$LOG"
echo "TIMEOUT after ${TIMEOUT}s (no AE_DONE marker). If a modal dialog is open, clear it via computer-use, then re-run." >&2
exit 2
