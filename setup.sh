#!/usr/bin/env bash
set -euo pipefail

# dotclaude — Claude Code environment setup
# Usage: ./setup.sh [--dry-run] [--skip-skills] [--restore]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CONFIG_DIR="$SCRIPT_DIR/config"

# --- Options ---
DRY_RUN=false
SKIP_SKILLS=false
RESTORE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)      DRY_RUN=true; shift ;;
        --skip-skills)  SKIP_SKILLS=true; shift ;;
        --restore)      RESTORE=true; shift ;;
        -h|--help)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Setup Claude Code environment from dotclaude config.

Options:
  --dry-run       Show what would be done without making changes
  --skip-skills   Skip cloning and installing skills
  --restore       Restore backup (undo setup)
  -h, --help      Show this help
EOF
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
err()   { echo -e "${RED}[error]${NC} $*"; }

# --- Skills repo config ---
SKILLS_REPO="https://github.com/luoli523/my_claude_skills.git"
SKILLS_DIR="$SCRIPT_DIR/my_claude_skills"

# Files to symlink: source (relative to config/) -> target (relative to ~/.claude/)
SYMLINK_FILES=(
    "settings.json"
    "settings.local.json"
    "statusline-command.sh"
)

# ============================================================
# Restore mode
# ============================================================
if $RESTORE; then
    # Find latest backup
    BACKUP_BASE="$CLAUDE_DIR/backups"
    LATEST=$(ls -dt "$BACKUP_BASE"/dotclaude-* 2>/dev/null | head -1)
    if [[ -z "$LATEST" ]]; then
        err "No dotclaude backup found in $BACKUP_BASE"
        exit 1
    fi
    info "Restoring from: $LATEST"

    for file in "${SYMLINK_FILES[@]}"; do
        target="$CLAUDE_DIR/$file"
        backup="$LATEST/$file"
        if [[ -f "$backup" ]]; then
            if $DRY_RUN; then
                info "Would restore $file"
            else
                rm -f "$target"
                cp "$backup" "$target"
                ok "Restored $file"
            fi
        fi
    done

    # Restore config.json
    if [[ -f "$LATEST/config.json" ]]; then
        if $DRY_RUN; then
            info "Would restore config.json"
        else
            cp "$LATEST/config.json" "$CLAUDE_DIR/config.json"
            ok "Restored config.json"
        fi
    fi

    ok "Restore complete from $LATEST"
    exit 0
fi

# ============================================================
# Setup mode
# ============================================================
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   dotclaude — Environment Setup      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo

# --- Step 0: Ensure ~/.claude exists ---
mkdir -p "$CLAUDE_DIR"

# --- Step 1: Backup existing config ---
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$CLAUDE_DIR/backups/dotclaude-$TIMESTAMP"

info "Step 1: Backing up existing config..."

needs_backup=false
for file in "${SYMLINK_FILES[@]}" config.json; do
    target="$CLAUDE_DIR/$file"
    if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
        needs_backup=true
        break
    fi
done

if $needs_backup; then
    if ! $DRY_RUN; then
        mkdir -p "$BACKUP_DIR"
    fi
    for file in "${SYMLINK_FILES[@]}" config.json; do
        target="$CLAUDE_DIR/$file"
        if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
            if $DRY_RUN; then
                info "  Would backup $file"
            else
                cp "$target" "$BACKUP_DIR/$file"
                ok "  Backed up $file"
            fi
        fi
    done
else
    info "  No files need backup (all are symlinks or missing)"
fi

# --- Step 2: Create symlinks ---
info "Step 2: Symlinking config files..."

for file in "${SYMLINK_FILES[@]}"; do
    source="$CONFIG_DIR/$file"
    target="$CLAUDE_DIR/$file"

    if [[ ! -f "$source" ]]; then
        warn "  Source not found: $source — skipping"
        continue
    fi

    if [[ -L "$target" ]]; then
        current=$(readlink "$target")
        if [[ "$current" == "$source" ]]; then
            info "  $file — already linked"
            continue
        fi
        # Different symlink, update it
        if $DRY_RUN; then
            info "  Would update symlink: $file"
        else
            rm "$target"
            ln -s "$source" "$target"
            ok "  Updated symlink: $file -> $source"
        fi
    elif [[ -f "$target" ]]; then
        # Regular file, replace with symlink
        if $DRY_RUN; then
            info "  Would replace $file with symlink"
        else
            rm "$target"
            ln -s "$source" "$target"
            ok "  Replaced with symlink: $file -> $source"
        fi
    else
        # Does not exist, create
        if $DRY_RUN; then
            info "  Would create symlink: $file"
        else
            ln -s "$source" "$target"
            ok "  Created symlink: $file -> $source"
        fi
    fi
done

# --- Step 3: Render config.json from template ---
info "Step 3: Rendering config.json from template..."

TMPL="$CONFIG_DIR/config.json.tmpl"
TARGET_CONFIG="$CLAUDE_DIR/config.json"

if [[ -f "$TMPL" ]]; then
    rendered=$(sed "s|{{HOME}}|$HOME|g" "$TMPL")
    if [[ -f "$TARGET_CONFIG" ]] && [[ "$(cat "$TARGET_CONFIG")" == "$rendered" ]]; then
        info "  config.json — already up to date"
    else
        if $DRY_RUN; then
            info "  Would render config.json (HOME=$HOME)"
        else
            echo "$rendered" > "$TARGET_CONFIG"
            ok "  Rendered config.json"
        fi
    fi
else
    warn "  Template not found: $TMPL"
fi

# --- Step 4: Install skills ---
if ! $SKIP_SKILLS; then
    info "Step 4: Installing skills from my_claude_skills..."

    if [[ -d "$SKILLS_DIR/.git" ]]; then
        info "  Updating existing clone..."
        if ! $DRY_RUN; then
            git -C "$SKILLS_DIR" pull --quiet
        fi
    else
        info "  Cloning $SKILLS_REPO..."
        if ! $DRY_RUN; then
            git clone "$SKILLS_REPO" "$SKILLS_DIR"
        fi
    fi

    if ! $DRY_RUN; then
        if [[ -x "$SKILLS_DIR/install.sh" ]]; then
            info "  Running skills install.sh..."
            (cd "$SKILLS_DIR" && ./install.sh)
        else
            warn "  install.sh not found or not executable in $SKILLS_DIR"
        fi
    else
        info "  Would run: cd $SKILLS_DIR && ./install.sh"
    fi
else
    info "Step 4: Skipped (--skip-skills)"
fi

# --- Step 5: Install plugins ---
info "Step 5: Checking plugins..."
PLUGINS_DIR="$CLAUDE_DIR/plugins"
if [[ -f "$CONFIG_DIR/installed_plugins.json" ]]; then
    mkdir -p "$PLUGINS_DIR"
    if $DRY_RUN; then
        info "  Would copy installed_plugins.json"
    else
        cp "$CONFIG_DIR/installed_plugins.json" "$PLUGINS_DIR/installed_plugins.json"
        ok "  Copied installed_plugins.json"
    fi
    info "  Note: Plugin binaries will be fetched by Claude Code on first launch"
else
    info "  No plugins config found — skipping"
fi

# --- Done ---
echo
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Setup complete!                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo
info "Config:  symlinked from $CONFIG_DIR"
info "Skills:  managed by $SKILLS_DIR"
info "Backup:  ${BACKUP_DIR:-'(none needed)'}"
echo
info "To undo: ./setup.sh --restore"
$DRY_RUN && warn "(dry-run mode — no changes were made)"
