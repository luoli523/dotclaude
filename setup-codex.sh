#!/usr/bin/env bash
set -euo pipefail

# Install Codex configuration managed by dotclaude.
# Usage: ./setup-codex.sh [--dry-run] [--restore]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_DIR="$HOME/.codex"
CONFIG_DIR="$SCRIPT_DIR/config/codex"
DRY_RUN=false
RESTORE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --restore) RESTORE=true; shift ;;
        --skip-skills) shift ;;
        -h|--help)
            echo "Usage: $(basename "$0") [--dry-run] [--restore]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

info() { echo "[codex] $*"; }
ok() { echo "[codex] $*"; }

if $RESTORE; then
    backup_base="$CODEX_DIR/backups"
    latest=$(ls -dt "$backup_base"/dotclaude-* 2>/dev/null | head -1 || true)
    [[ -n "$latest" ]] || { echo "[codex] No dotclaude backup found in $backup_base" >&2; exit 1; }
    info "Restoring from: $latest"
    for file in AGENTS.md config.toml; do
        if [[ -f "$latest/$file" ]]; then
            if $DRY_RUN; then
                info "Would restore $file"
            else
                rm -f "$CODEX_DIR/$file"
                cp "$latest/$file" "$CODEX_DIR/$file"
                ok "Restored $file"
            fi
        fi
    done
    exit 0
fi

mkdir -p "$CODEX_DIR"
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$CODEX_DIR/backups/dotclaude-$timestamp"

for file in AGENTS.md config.toml; do
    target="$CODEX_DIR/$file"
    if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
        if $DRY_RUN; then
            info "Would back up $file"
        else
            mkdir -p "$backup_dir"
            cp "$target" "$backup_dir/$file"
            ok "Backed up $file"
        fi
    fi
done

source="$CONFIG_DIR/AGENTS.md"
target="$CODEX_DIR/AGENTS.md"
if $DRY_RUN; then
    info "Would symlink $target -> $source"
else
    rm -f "$target"
    ln -s "$source" "$target"
    ok "Linked AGENTS.md"
fi

template="$CONFIG_DIR/config.toml.tmpl"
target="$CODEX_DIR/config.toml"
rendered=$(sed "s|{{HOME}}|$HOME|g" "$template")
if [[ -f "$target" ]] && [[ "$(cat "$target")" == "$rendered" ]]; then
    info "config.toml — already up to date"
elif $DRY_RUN; then
    info "Would render $target (HOME=$HOME)"
else
    printf '%s\n' "$rendered" > "$target"
    ok "Rendered config.toml"
fi

info "Codex setup complete"
