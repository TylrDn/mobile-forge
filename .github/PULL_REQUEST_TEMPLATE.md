## Summary

<!-- What changed and why? Be concise — 1-3 sentences. -->

## Changes

<!-- Bullet list of the specific changes made. -->

-

## How to Test

<!-- Steps to verify the change works as expected. -->

1.

## Checklist

<!-- Run through this before requesting review. -->

### Scope
- [ ] PR does exactly what the title says — no scope creep
- [ ] No unrelated files modified
- [ ] No commented-out or dead code added

### Commits
- [ ] All commits follow Conventional Commits format (`feat:`, `fix:`, `chore:`, `docs:`, etc.)
- [ ] No `WIP`, `temp`, or `fixup` commits in the final branch
- [ ] Commit messages are imperative and present-tense

### Code Quality
- [ ] No hardcoded secrets, tokens, or credentials
- [ ] No `console.log` / debug statements left in production paths
- [ ] Error cases are handled

### Tests & CI
- [ ] CI passes (lint + typecheck + test green)
- [ ] New functionality has corresponding tests (or note below why omitted)

### Documentation
- [ ] `docs/` updated if this affects usage or setup
- [ ] `session-log/` entry created if this is an agent-driven session

### Screenshots / Recordings

<!-- For UI changes, paste before/after screenshots or screen recordings here. -->

---

> **Merge rules:** Squash merge into `develop`. Merge commit into `main`. Delete source branch after merge.
