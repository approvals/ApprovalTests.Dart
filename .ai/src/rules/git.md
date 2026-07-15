# Git Rules

## Commits

- Follow Arlo's Commit Notation from `CONTRIBUTING.md`.
- Choose the risk prefix deliberately: `.` provable, `-` tested, `!` single action, `@` other.
- Choose the action prefix deliberately: `r`, `e`, `d`, `t`, `F`, or `B`.
- Match recent subjects in `git log --oneline -10` before composing a message.
- Keep one logical change per commit and explain the reason when the subject is insufficient.
- Keep agent/model attribution and generated-by trailers out of commits.

## Approval artifacts

- Commit reviewed `*.approved.*` files because they are test expectations.
- Keep regenerated `*.received.*` files ignored and unstaged.
- Inspect approval artifact diffs as test changes, not generic generated output.

## Safety

- Preserve unrelated user changes in a dirty worktree.
- Resolve formatter, analyzer, test, and hook failures at their source.
- Use force-push, verification bypasses, and destructive cleanup only with explicit authorization.
- Update README and CHANGELOG when a public contract or workflow changes.
