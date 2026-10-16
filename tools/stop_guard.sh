#!/usr/bin/env bash
# Claude Code "Stop" hook (CI only). The agent sometimes ends its session after one task,
# even with hours left. While more than 45 min remain, this hook refuses the stop and tells
# the agent to continue. Locally (no AGENT_DEADLINE) it never blocks.
cat > /dev/null   # hook input JSON, not needed
[[ -z "${AGENT_DEADLINE:-}" ]] && exit 0
left=$(( (AGENT_DEADLINE - $(date +%s)) / 60 ))
(( left < 45 )) && exit 0
counter="${CLAUDE_PROJECT_DIR:-.}/out/.stop_blocks"
mkdir -p "$(dirname "$counter")"
n=$(( $(cat "$counter" 2>/dev/null || echo 0) + 1 ))
echo "$n" > "$counter"
(( n > 40 )) && exit 0   # safety valve: never loop forever
cat <<JSON
{"decision":"block","reason":"Do not stop yet: ${left} minutes are left in this session (stop #${n}). Follow .github/agent/nightly-prompt.md step 5: commit what you have, then take the next unchecked task of the CURRENT milestone (or the next milestone if DoD passed). If you are blocked, FIRST ask the architect subagent (Opus) with the exact errors and what you tried, and implement its plan. Only if that also fails, write a BLOCKED entry in STATUS.md and switch to another task, or do useful analysis/preparation for the next task (read the Vulkan/Metal backend, write an ADR draft, ask the architect subagent). Only finish when tools/time_left.sh shows < 40 min, after the wrap-up from step 7."}
JSON
