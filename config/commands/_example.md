<!--
  Custom Slash Command Template

  File location:  ~/.claude/commands/<name>.md   → invoked as /user:<name>
  Project-level:  .claude/commands/<name>.md     → invoked as /project:<name>

  Use $ARGUMENTS to capture user input after the command name.
  Example: /user:review src/app.ts → $ARGUMENTS = "src/app.ts"
-->

# Example Command: Review

Review the code in $ARGUMENTS and provide:

1. **Issues** — bugs, security concerns, performance problems
2. **Suggestions** — improvements, simplifications, better patterns
3. **Summary** — one paragraph overall assessment

Keep feedback actionable and specific. Reference line numbers.
