<!--
  Skill Template

  File location:  ~/.claude/skills/<skill-name>/SKILL.md   → available globally
  Project-level:  .claude/skills/<skill-name>/SKILL.md      → available in that project

  Skills are auto-invoked workflows. Claude detects when a skill is relevant
  based on the description and triggers it automatically.

  Key sections:
    - Description: when this skill should activate (be specific!)
    - Instructions: step-by-step workflow
    - Supporting files: put reference docs, templates, scripts alongside SKILL.md
-->

---
description: >
  Example skill that generates a changelog from git history.
  Triggers when user asks to "generate changelog", "release notes",
  or "what changed since last release".
---

# Example Skill: Changelog Generator

## Instructions

1. Run `git log --oneline <from_tag>..HEAD` to get commits since last release
2. Group commits by type (feat, fix, docs, refactor, etc.) based on conventional commit prefixes
3. Format as markdown with sections per type
4. Output to CHANGELOG.md or display inline

## Output Format

```markdown
## [version] - YYYY-MM-DD

### Features
- description (#PR)

### Bug Fixes
- description (#PR)

### Other Changes
- description (#PR)
```
