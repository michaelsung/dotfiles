#!/bin/bash
INPUT=$(cat)
SAFETY=$(echo "$INPUT" | npx -y cc-safety-net --statusline 2>/dev/null)
USAGE=$(echo "$INPUT" | jq -r '"Session: " + (.rate_limits.five_hour.used_percentage // 0 | floor | tostring) + "% | Ctx: " + (.context_window.used_percentage // 0 | floor | tostring) + "%"')

if [ -n "$SAFETY" ]; then
  echo "$SAFETY | $USAGE"
else
  echo "$USAGE"
fi
