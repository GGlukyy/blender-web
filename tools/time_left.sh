#!/usr/bin/env bash
# Prints minutes left in this session. The workflow sets AGENT_DEADLINE (unix seconds).
# Locally, without AGENT_DEADLINE, it prints "unlimited".
if [[ -z "${AGENT_DEADLINE:-}" ]]; then
  echo "TIME LEFT: unlimited (local run)"
  exit 0
fi
left=$(( (AGENT_DEADLINE - $(date +%s)) / 60 ))
if (( left < 40 )); then
  echo "TIME LEFT: ${left} min — STOP CODING NOW, wrap up (CLAUDE.md §4.6)"
else
  echo "TIME LEFT: ${left} min"
fi
