# dotclaude

我的 Claude Code 环境配置。在任何新机器上 clone 此仓库并运行 `setup.sh`，即可恢复完整的 Claude Code 偏好设置。

## Quick Start

```bash
git clone https://github.com/luoli523/dotclaude.git ~/dev/git/dotclaude
cd ~/dev/git/dotclaude
./setup.sh
```

首次运行会自动完成以下操作：

1. **备份** 已有的 `~/.claude/` 配置文件和目录
2. **Symlink 文件** — `settings.json`、`settings.local.json`、`statusline-command.sh`、`CLAUDE.md` → `~/.claude/`
3. **Symlink 目录** — `commands/`、`rules/`、`agents/` → `~/.claude/`
4. **渲染** `config.json` — 从模板替换 `{{HOME}}` 为实际路径
5. **安装 Skills** — 自动 clone [my_claude_skills](https://github.com/luoli523/my_claude_skills) 并执行其 `install.sh`
6. **同步 Plugins** — 复制插件注册表，Claude Code 首次启动时自动拉取插件

## setup.sh 用法

```bash
./setup.sh                 # 完整安装
./setup.sh --dry-run       # 预览变更，不实际执行
./setup.sh --skip-skills   # 跳过 skills 安装（仅配置文件）
./setup.sh --restore       # 从最近的备份还原（撤销 setup）
```

### 备份与还原

每次 `setup.sh` 执行前，会将被替换的原始文件备份到 `~/.claude/backups/dotclaude-<timestamp>/`。还原时自动使用最新备份：

```bash
./setup.sh --restore              # 还原到上次 setup 前的状态
./setup.sh --restore --dry-run    # 预览还原操作
```

---

## init-project.sh — 项目脚手架

为任意项目初始化 Claude Code 最佳实践目录结构：

```bash
./init-project.sh /path/to/your-project
./init-project.sh .    # 当前目录
```

生成的结构：

```
your-project/
├── CLAUDE.md                  # 团队共享指令（提交到 git）
├── CLAUDE.local.md            # 个人覆盖（已自动加入 .gitignore）
└── .claude/
    ├── settings.json          # 项目权限配置
    ├── settings.local.json    # 个人权限覆盖（gitignored）
    ├── commands/_example.md   # Slash 命令模板
    ├── rules/_example.md      # 规则模板
    ├── skills/_example-skill/ # Skill 模板
    └── agents/_example.md     # Agent 模板
```

每个目录下的 `_example` 文件都是带有详细注释的模板。创建自己的 command/rule/skill/agent 时，复制模板并改名即可。用完后可删除 `_example` 文件。

---

## 仓库结构

```
dotclaude/
├── setup.sh                     # 全局环境安装脚本
├── init-project.sh              # 项目脚手架生成器
├── config/                      # → symlink 到 ~/.claude/
│   ├── settings.json            # 全局设置
│   ├── settings.local.json      # 权限白名单
│   ├── config.json.tmpl         # MCP servers 配置模板
│   ├── statusline-command.sh    # 自定义状态栏脚本
│   ├── installed_plugins.json   # 插件注册表
│   ├── CLAUDE.md                # 全局个人指令
│   ├── commands/                # 个人 slash 命令
│   ├── rules/                   # 全局规则
│   ├── agents/                  # 个人 agents
│   └── skills/                  # 个人 skills 模板
├── project-template/            # init-project.sh 使用的模板
├── my_claude_skills/            # setup 时自动 clone（.gitignored）
└── README.md
```

---

## 各组件说明

### config/settings.json — 全局设置

控制 Claude Code 的全局行为，当前配置：

| 配置项 | 值 | 说明 |
|--------|------|------|
| `model` | `opus` | 默认使用 Opus 模型 |
| `effortLevel` | `high` | 高推理深度 |
| `statusLine` | command | 自定义状态栏脚本 |
| `enabledPlugins` | `frontend-design` | 已启用的插件 |
| `env.GITHUB_USERNAME` | `luoli523@gmail.com` | 环境变量 |

修改后无需重新运行 setup（symlink 自动生效）。

### config/settings.local.json — 权限白名单

预授权的工具调用，免去每次确认：

```json
{
  "permissions": {
    "allow": [
      "Bash(echo $SHELL)",
      "Bash(git config:*)",
      "Bash(gh auth:*)"
    ]
  }
}
```

添加新权限：编辑此文件，格式为 `Tool(pattern)`，支持 `*` 通配符。

### config/config.json.tmpl — MCP Servers 配置

使用 `{{HOME}}` 占位符适配不同机器的路径：

```json
{
  "primaryApiKey": "any",
  "mcpServers": {
    "weixin-reader": {
      "command": "python",
      "args": ["{{HOME}}/.claude/skills/anything-to-notebooklm/wexin-read-mcp/src/server.py"]
    }
  }
}
```

添加新 MCP server：编辑此模板文件，然后重新运行 `./setup.sh --skip-skills`。

### config/statusline-command.sh — 自定义状态栏

两行式状态栏，显示：
- **第一行**：模型 │ 上下文使用率（进度条） │ 费用 │ 5h/7d 用量
- **第二行**：目录 │ Git 分支/状态 │ Python venv │ Vim 模式

自动检测深色/浅色主题，支持 `STATUSLINE_THEME=dark|light|auto` 环境变量覆盖。

### config/CLAUDE.md — 全局指令

每个 Claude Code 会话都会加载此文件，当前配置了：
- 语言跟随（中文问中文答，英文问英文答）
- 编码风格偏好（简洁、避免过度工程化）
- 沟通风格（直接、不做多余总结）

### commands/ — 自定义 Slash 命令

| 位置 | 调用方式 |
|------|----------|
| `~/.claude/commands/<name>.md` | `/user:<name>` |
| `.claude/commands/<name>.md`（项目级） | `/project:<name>` |

命令文件就是 Markdown prompt，用 `$ARGUMENTS` 接收用户输入参数。

**创建新命令**：

```bash
cp config/commands/_example.md config/commands/review.md
# 编辑 review.md，写入你的 prompt
# 即可在任何项目中使用 /user:review
```

### rules/ — 自动加载规则

规则文件会在**每次对话**中自动加载（无需手动调用），适合放编码规范、约定和约束条件。

| 位置 | 生效范围 |
|------|----------|
| `~/.claude/rules/<name>.md` | 所有项目 |
| `.claude/rules/<name>.md`（项目级） | 当前项目 |

**创建新规则**：

```bash
cp config/rules/_example.md config/rules/code-style.md
# 编辑规则内容
```

### agents/ — 自定义子代理

Agent 是可被 Claude 调用的专用子代理，通过 YAML frontmatter 定义模型、可用工具和描述。

**Frontmatter 字段**：

```yaml
---
model: sonnet          # 可选：sonnet, opus, haiku
tools:                 # 该 agent 可使用的工具列表
  - Read
  - Grep
  - Bash
description: 一句话描述  # Claude 据此判断何时调用此 agent
---
```

**创建新 agent**：

```bash
cp config/agents/_example.md config/agents/code-reviewer.md
# 编辑 agent 定义
```

### skills/ — 自动触发工作流

Skills 是 Claude 根据用户意图**自动识别并调用**的工作流。每个 skill 是一个目录，内含 `SKILL.md` 和可选的辅助文件。

```
skills/
└── my-skill/
    ├── SKILL.md          # 必须：定义 description 和 instructions
    ├── reference.md      # 可选：参考文档
    └── template.txt      # 可选：输出模板
```

`SKILL.md` 的 `description` 字段决定了 Claude 何时触发此 skill，需要写得具体（包含关键词）。

> **注意**：大量 skills 通过 [my_claude_skills](https://github.com/luoli523/my_claude_skills) 管理，此处仅存放模板和不属于那个仓库的个人 skills。

---

## 日常工作流

### 改了配置

```bash
cd ~/dev/git/dotclaude
# 编辑 config/ 下的文件
git add -A && git commit -m "update xxx" && git push
```

Symlink 文件（settings.json 等）改完即生效。`config.json.tmpl` 改了需要在目标机器重新运行：

```bash
./setup.sh --skip-skills
```

### 另一台机器同步

```bash
cd ~/dev/git/dotclaude
git pull
# symlink 文件自动生效
# 如果 config.json.tmpl 有变动：
./setup.sh --skip-skills
```

### 添加新的 command/rule/agent/skill

```bash
# Slash 命令
cp config/commands/_example.md config/commands/my-command.md

# 规则
cp config/rules/_example.md config/rules/my-rule.md

# Agent
cp config/agents/_example.md config/agents/my-agent.md

# Skill
mkdir config/skills/my-skill
cp config/skills/_example-skill/SKILL.md config/skills/my-skill/SKILL.md

# 编辑后提交
git add -A && git commit -m "add xxx" && git push
```

### 给新项目初始化 Claude 配置

```bash
cd ~/dev/git/dotclaude
./init-project.sh ~/dev/git/my-new-project
```

然后编辑项目中的 `CLAUDE.md` 描述项目信息，按需创建 commands/rules/skills/agents。

---

## 全局 vs 项目级配置对照

| 类型 | 全局 (`~/.claude/`) | 项目级 (`.claude/`) |
|------|---------------------|---------------------|
| 指令文件 | `~/.claude/CLAUDE.md` | `CLAUDE.md`（项目根目录） |
| 个人覆盖 | — | `CLAUDE.local.md`（gitignored） |
| 设置 | `settings.json` | `.claude/settings.json` |
| 权限覆盖 | `settings.local.json` | `.claude/settings.local.json`（gitignored） |
| 命令 | `commands/` → `/user:<name>` | `.claude/commands/` → `/project:<name>` |
| 规则 | `rules/` → 所有项目生效 | `.claude/rules/` → 仅当前项目 |
| Skills | `skills/` → 所有项目可用 | `.claude/skills/` → 仅当前项目 |
| Agents | `agents/` → 所有项目可用 | `.claude/agents/` → 仅当前项目 |

**加载顺序**：全局配置先加载，项目级配置后加载并可覆盖。`*.local.*` 文件优先级最高。
