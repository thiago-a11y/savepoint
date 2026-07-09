#!/bin/bash
# savepoint — SessionStart hook
# Carrega o handoff da branch atual no contexto ao abrir a sessão.
# Regra: main/master → HANDOFF.md; outras branches → HANDOFF-<branch>.md
# (com fallback para HANDOFF.md se o da branch não existir).
# Silencioso fora de repos git ou sem handoff — nunca atrapalha.

command -v jq >/dev/null 2>&1 || exit 0

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
BRANCH=$(git branch --show-current 2>/dev/null)
[ -z "$BRANCH" ] && BRANCH="main"

FILE="$ROOT/HANDOFF.md"
if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  CANDIDATE="$ROOT/HANDOFF-$(echo "$BRANCH" | tr '/' '-').md"
  [ -f "$CANDIDATE" ] && FILE="$CANDIDATE"
fi

[ -f "$FILE" ] || exit 0

jq -n --rawfile h "$FILE" --arg f "$(basename "$FILE")" --arg b "$BRANCH" \
  '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":("[savepoint] " + $f + " encontrado (branch " + $b + ") — estado onde a ultima sessao parou:\n\n" + $h + "\n\n(Use como contexto de retomada; nao execute nada automaticamente.)")}}'
