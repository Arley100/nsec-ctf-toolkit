#!/bin/bash
# ============================================================
# ctf-start.sh  —  challenge workspace initializer
# ============================================================
# Run this at the START of each challenge inside the container.
# It creates a clean folder for the challenge, records the
# start time, and opens a tmux session with two panes:
#   - Left pane:  your working terminal
#   - Right pane: notes file open in vim
#
# Usage (inside the container):
#   bash /ctf/scripts/ctf-start.sh "web" "news-of-the-seas"
#
# Arguments:
#   $1 = category  (web / crypto / forensics / re / pwn / misc)
#   $2 = challenge name
# ============================================================

CATEGORY="${1:-misc}"
CHALLENGE="${2:-unnamed}"
TIMESTAMP=$(date +"%H%M")
WORKDIR="/ctf/challenges/${CATEGORY}/${CHALLENGE}"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Create a notes file pre-filled with a template
cat > notes.md << NOTES
# Challenge: $CHALLENGE
# Category:  $CATEGORY
# Started:   $(date)
# ─────────────────────────────────────────────

## Flag format
FLAG-...

## Initial observations


## Approach / hypothesis


## Tools tried


## Dead ends (don't repeat these)


## Solution


## Flag

NOTES

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Challenge workspace created:"
echo "  $WORKDIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  notes.md ready for your observations."
echo "  Start working! Good luck."
echo ""

# If tmux is available, launch a split session
if command -v tmux &>/dev/null; then
    tmux new-session -d -s "$CHALLENGE" -c "$WORKDIR"
    tmux split-window -h -t "$CHALLENGE" "vim notes.md"
    tmux attach -t "$CHALLENGE"
fi
