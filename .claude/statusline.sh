#!/bin/bash
INPUT=$(cat)
SAFETY=$(echo "$INPUT" | npx -y cc-safety-net --statusline 2>/dev/null)
RESET_AT=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.resets_at // empty')
RESET_STR=""
if [ -n "$RESET_AT" ]; then
  RESET_TIME=$(date -r "$RESET_AT" +"%H:%M" 2>/dev/null || date -d "@$RESET_AT" +"%H:%M" 2>/dev/null)
  RESET_STR=" (resets ${RESET_TIME})"
fi
SESSION_PCT=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.used_percentage // 0 | floor | tostring')
CTX_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0 | floor | tostring')
USAGE="Session: ${SESSION_PCT}%${RESET_STR} | Ctx: ${CTX_PCT}%"

if [ -n "$SAFETY" ]; then
  echo "$SAFETY | $USAGE"
else
  echo "$USAGE"
fi
