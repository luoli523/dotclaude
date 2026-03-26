#!/usr/bin/env bash
set -euo pipefail

# Initialize a project with the Claude Code best-practice directory structure.
# Usage: ./init-project.sh [target-dir]
#   target-dir defaults to current directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/project-template"
TARGET_DIR="${1:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }

if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}[error]${NC} Directory not found: $TARGET_DIR"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
info "Initializing Claude Code structure in: $TARGET_DIR"

# Copy template files, skip existing
copy_if_missing() {
    local src="$1"
    local dst="$2"
    if [[ -e "$dst" ]]; then
        warn "  Already exists, skipping: ${dst#$TARGET_DIR/}"
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        ok "  Created: ${dst#$TARGET_DIR/}"
    fi
}

# CLAUDE.md and CLAUDE.local.md at project root
copy_if_missing "$TEMPLATE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
copy_if_missing "$TEMPLATE_DIR/CLAUDE.local.md" "$TARGET_DIR/CLAUDE.local.md"

# .claude/ structure
copy_if_missing "$TEMPLATE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
copy_if_missing "$TEMPLATE_DIR/.claude/settings.local.json" "$TARGET_DIR/.claude/settings.local.json"
copy_if_missing "$TEMPLATE_DIR/.claude/commands/_example.md" "$TARGET_DIR/.claude/commands/_example.md"
copy_if_missing "$TEMPLATE_DIR/.claude/rules/_example.md" "$TARGET_DIR/.claude/rules/_example.md"
copy_if_missing "$TEMPLATE_DIR/.claude/skills/_example-skill/SKILL.md" "$TARGET_DIR/.claude/skills/_example-skill/SKILL.md"
copy_if_missing "$TEMPLATE_DIR/.claude/agents/_example.md" "$TARGET_DIR/.claude/agents/_example.md"

# Append to .gitignore if exists
GITIGNORE="$TARGET_DIR/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
    for pattern in "CLAUDE.local.md" ".claude/settings.local.json"; do
        if ! grep -qF "$pattern" "$GITIGNORE"; then
            echo "$pattern" >> "$GITIGNORE"
            ok "  Added '$pattern' to .gitignore"
        fi
    done
else
    cat > "$GITIGNORE" <<'EOF'
CLAUDE.local.md
.claude/settings.local.json
EOF
    ok "  Created .gitignore with Claude entries"
fi

echo
echo -e "${GREEN}Done!${NC} Claude Code project structure initialized."
info "Edit CLAUDE.md to describe your project."
info "Remove _example files after creating your own commands/rules/skills/agents."
