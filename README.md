# dotclaude

My Claude Code environment configuration. Clone this repo on any new machine and run `setup.sh` to restore my preferred Claude Code setup.

## Quick Start

```bash
git clone git@github.com:luoli523/dotclaude.git ~/dev/git/dotclaude
cd ~/dev/git/dotclaude
./setup.sh
```

## What it does

1. **Backs up** existing `~/.claude/` config files
2. **Symlinks** `settings.json`, `settings.local.json`, `statusline-command.sh` from this repo into `~/.claude/`
3. **Renders** `config.json` from template (replaces `{{HOME}}` with actual home path)
4. **Clones** [my_claude_skills](https://github.com/luoli523/my_claude_skills) and runs its `install.sh` to set up all skills
5. **Copies** plugin registry so Claude Code can fetch plugin binaries on first launch

## Options

```bash
./setup.sh --dry-run       # Preview changes without applying
./setup.sh --skip-skills   # Skip skills installation
./setup.sh --restore       # Undo setup, restore from backup
```

## Structure

```
dotclaude/
├── setup.sh                     # Main setup script
├── config/
│   ├── settings.json            # Global settings (model, env, plugins, etc.)
│   ├── settings.local.json      # Permission allowlist
│   ├── config.json.tmpl         # MCP servers config (template)
│   └── statusline-command.sh    # Custom status bar script
├── my_claude_skills/            # Cloned at setup time (.gitignored)
└── README.md
```

## Updating config

Edit files in `config/`, commit and push. On another machine, `git pull` — symlinked files take effect immediately. If `config.json.tmpl` changed, re-run `./setup.sh --skip-skills`.
