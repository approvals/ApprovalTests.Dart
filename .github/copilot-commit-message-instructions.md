<copilot.commitMessage>
USE ARLO'S COMMIT FORMAT: `[Risk][Action] message`

### RISK SYMBOLS ###
- `.`: Provable — change easy to verify
- `-`: Tested — verified by tests
- `!`: Single — atomic, one-step change
- `@`: Other — misc or mixed changes

### ACTION SYMBOLS ###
- `r`: Refactor — code-only cleanup
- `e`: Env — infra, build, config
- `d`: Docs — comments, README, etc.
- `t`: Test — tests only
- `F`: Feature — new logic/feature
- `B`: Bugfix — fixing issues

### EXAMPLES ###
- `.r rename var`
- `-e update CI script`
- `!B fix null check`
- `@d update README`

### RULES ###
- ALWAYS start with risk+action symbol (e.g., `.r`, `!F`)
- MESSAGE must be clear & concise (what changed)
- DO NOT skip symbols
- DO NOT mix actions unless using `@`
- DO NOT use vague messages like "fix code"

FOLLOW THIS FORMAT FOR EVERY COMMIT.
</copilot.commitMessage>
