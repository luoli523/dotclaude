<!--
  Rule File Template

  File location:  ~/.claude/rules/<name>.md      → always loaded globally
  Project-level:  .claude/rules/<name>.md         → always loaded in that project

  Rules are automatically included in every conversation.
  Use them for coding standards, conventions, and constraints
  that should always be followed without needing to be invoked.
-->

# Example Rule: Code Style

- Use 2-space indentation for TypeScript/JavaScript, 4-space for Python.
- Prefer `const` over `let`. Never use `var`.
- Functions should do one thing. If a function needs a comment explaining what it does, it should be split.
- Error messages should be actionable: say what went wrong AND what to do about it.
