#!/usr/bin/env bash
# Read-only: print a fact bundle for health audits. Does not cat secrets.
set -euo pipefail
ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"

echo "health_collect: repo_root=$ROOT"
echo "health_collect: date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

have_git=false
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  have_git=true
fi

echo "## vcs"
echo "git_repo=$have_git"
if $have_git; then
  echo "git_branch=$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
  echo "git_status_short:"
  git -C "$ROOT" status -sb 2>/dev/null | head -n 20 || true
fi

echo "## paths_present"
for p in \
  README.md \
  AGENTS.md \
  CLAUDE.md \
  .cursor/mcp.json \
  .cursor/hooks.json \
  .claude/settings.local.json \
  renovate.json; do
  if [[ -e "$ROOT/$p" ]]; then
    echo "yes $p"
  else
    echo "no $p"
  fi
done

if [[ -d "$ROOT/.cursor/rules" ]]; then
  nrules=$(find "$ROOT/.cursor/rules" -type f \( -name '*.md' -o -name '*.mdc' \) 2>/dev/null | wc -l | tr -d ' ')
  echo "cursor_rules_files=$nrules"
else
  echo "cursor_rules_dir=no"
fi

if [[ -d "$ROOT/.claude/rules" ]]; then
  ncr=$(find "$ROOT/.claude/rules" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo "claude_rules_files=$ncr"
else
  echo "claude_rules_dir=no"
fi

echo "## agent_markers (multi-platform; yes = path exists)"
agent_mark() {
  local rel="$1"
  if [[ -e "$ROOT/$rel" ]]; then
    echo "yes $rel"
  else
    echo "no $rel"
  fi
}
agent_mark ".cursor/rules"
agent_mark ".cursor/mcp.json"
agent_mark ".cursor/hooks.json"
agent_mark "CLAUDE.md"
agent_mark "AGENTS.md"
agent_mark ".claude/rules"
agent_mark ".claude/settings.local.json"
agent_mark ".windsurfrules"
agent_mark ".clinerules"
agent_mark ".roomodes"
agent_mark ".github/copilot-instructions.md"
agent_mark ".github/instructions"
agent_mark ".continue"
agent_mark ".amazonq"
agent_mark ".aider.conf.yml"
agent_mark "CONVENTIONS.md"

echo "## ci"
if [[ -d "$ROOT/.github/workflows" ]]; then
  echo "github_workflows=yes"
else
  echo "github_workflows=no"
fi

echo "## repo_scale"
approx_files=$(find "$ROOT" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "approx_all_files_under_root=$approx_files"
if $have_git; then
  tracked=$(git -C "$ROOT" ls-files 2>/dev/null | wc -l | tr -d ' ')
  echo "git_tracked_files=$tracked"
fi

echo "## skill_md_index"
while IFS= read -r -d '' f; do
  rel=${f#"$ROOT"/}
  name_line=$(grep -m1 '^name:' "$f" 2>/dev/null || true)
  desc_line=$(grep -m1 '^description:' "$f" 2>/dev/null || true)
  echo "$rel | $name_line | ${desc_line:0:120}"
done < <(find "$ROOT" -maxdepth 3 -name SKILL.md -print0 2>/dev/null)

echo "## git_tracked_sensitive_paths (names only)"
if $have_git; then
  # Names that often imply secrets; listing path is OK, never print file contents.
  git -C "$ROOT" ls-files -z 2>/dev/null \
    | tr '\0' '\n' \
    | grep -Ei '(^|/)\.env($|[.])|settings\.local\.json|(^|/)id_(rsa|ed25519)(\.pub)?$|(^|/)[^/]+\.pem$|(^|/)\.npmrc$|(^|/)\.pypirc$|(^|/)credentials(\.json)?$|(^|/)secrets\.ya?ml$' \
    || true
else
  echo "(not a git repo — skipped)"
fi

echo "## json_sanity (cursor)"
for j in "$ROOT/.cursor/mcp.json" "$ROOT/.cursor/hooks.json"; do
  if [[ -f "$j" ]]; then
    rel=${j#"$ROOT"/}
    if command -v python3 >/dev/null 2>&1; then
      if python3 -m json.tool "$j" >/dev/null 2>&1; then
        echo "json_ok $rel"
      else
        echo "json_invalid $rel"
      fi
    elif command -v jq >/dev/null 2>&1; then
      if jq empty "$j" 2>/dev/null; then
        echo "json_ok $rel"
      else
        echo "json_invalid $rel"
      fi
    else
      echo "json_skip_no_python_jq $rel"
    fi
  fi
done

echo "## done"
