# dotclaude

My Claude Code environment configuration. Clone this repo on any new machine and run `setup.sh` to restore my preferred Claude Code setup.

## Quick Start

```bash
git clone git@github.com:luoli523/dotclaude.git ~/dev/git/dotclaude
cd ~/dev/git/dotclaude
./setup.sh
```

## What it does

1. **Backs up** existing `~/.claude/` config files and directories
2. **Symlinks** config files (`settings.json`, `settings.local.json`, `statusline-command.sh`, `CLAUDE.md`) into `~/.claude/`
3. **Symlinks** directories (`commands/`, `rules/`, `agents/`) into `~/.claude/`
4. **Renders** `config.json` from template (replaces `{{HOME}}` with actual home path)
5. **Clones** [my_claude_skills](https://github.com/luoli523/my_claude_skills) and runs its `install.sh` to set up all skills
6. **Copies** plugin registry so Claude Code can fetch plugin binaries on first launch

## Options

```bash
./setup.sh --dry-run       # Preview changes without applying
./setup.sh --skip-skills   # Skip skills installation
./setup.sh --restore       # Undo setup, restore from backup
```

## Initialize a new project

Scaffold the Claude Code best-practice structure into any project:

```bash
./init-project.sh /path/to/your-project
```

This creates:

```
your-project/
├── CLAUDE.md                  # Team instructions (commit this)
├── CLAUDE.local.md            # Personal overrides (gitignored)
└── .claude/
    ├── settings.json          # Project permissions
    ├── settings.local.json    # Personal overrides (gitignored)
    ├── commands/_example.md   # Slash command template
    ├── rules/_example.md      # Rule template
    ├── skills/_example-skill/ # Skill template
    └── agents/_example.md     # Agent template
```

## Structure

```
dotclaude/
├── setup.sh                     # Global environment setup
├── init-project.sh              # Project scaffold initializer
├── config/                      # → symlinked to ~/.claude/
│   ├── settings.json            # Global settings (model, env, plugins)
│   ├── settings.local.json      # Permission allowlist
│   ├── config.json.tmpl         # MCP servers config (template)
│   ├── statusline-command.sh    # Custom status bar script
│   ├── installed_plugins.json   # Plugin registry
│   ├── CLAUDE.md                # Global personal instructions
│   ├── commands/                # Personal slash commands
│   │   └── _example.md
│   ├── rules/                   # Global rules
│   │   └── _example.md
│   ├── agents/                  # Personal agents
│   │   └── _example.md
│   └── skills/                  # Personal skills (templates only)
│       └── _example-skill/
├── project-template/            # Template for init-project.sh
├── my_claude_skills/            # Cloned at setup time (.gitignored)
└── README.md
```

## Updating config

Edit files in `config/`, commit and push. On another machine, `git pull` — symlinked files take effect immediately. If `config.json.tmpl` changed, re-run `./setup.sh --skip-skills`.
