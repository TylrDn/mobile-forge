# 2026-07-11 — Initial Scaffold

**Repo:** `TylrDn/mobile-forge`
**Session type:** Agent-driven scaffold
**Date:** 2026-07-11
**Governed by:** [TylrDn/CODE](https://github.com/TylrDn/CODE)

---

## Context

`mobile-forge` is the canonical React Native / Expo scaffold template for the TylrDn account. This session completed the initial scaffold defined in `TylrDn/CODE/repo-index/mobile-forge.md`.

The repository already contained partial scaffolding (ci.yml, eas-build.yml, eas-preview.yml, docs/stack.md, docs/branching.md, docs/release-checklist.md, docs/ci-cd.md, scripts/bootstrap.sh, scripts/release.sh). This session added the missing components.

---

## Actions Taken

### Files Created

| File | Purpose |
|---|---|
| `.github/copilot-instructions.md` | Copilot/agent context: stack, conventions, key files, CI/CD overview |
| `.github/workflows/release.yml` | Triggers EAS production build + submit on semver tag push (`v*.*.*`) |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR checklist aligned with `TylrDn/CODE` review-protocol |
| `docs/hotfix-runbook.md` | Step-by-step emergency production fix process |
| `scripts/env-check.sh` | Verifies git, Node.js 20+, Bun, Expo CLI, EAS CLI, gh CLI are present |
| `session-log/.gitkeep` | Keeps the `session-log/` directory tracked by git |
| `session-log/2026-07-11-initial-scaffold.md` | This log entry |

### Files Already Present (not modified)

- `.github/workflows/ci.yml` — Lint (Biome) + typecheck + test on every PR
- `.github/workflows/eas-build.yml` — EAS build on push to develop/main
- `.github/workflows/eas-preview.yml` — EAS preview builds
- `docs/stack.md` — Full technology decision log
- `docs/branching.md` — Branch model, commit format, release and hotfix process
- `docs/release-checklist.md` — Pre/post release checklist
- `docs/ci-cd.md` — Pipeline overview and job definitions
- `scripts/bootstrap.sh` — One-command dev environment setup
- `scripts/release.sh` — Version bump and tag creation

---

## Notes

- The stack uses **Bun** as the package manager and **Biome** for lint+format (not ESLint + Prettier). This is intentional and documented in `docs/stack.md`.
- The `release.yml` workflow is separate from `eas-build.yml`: it is triggered exclusively by semver tags and is the canonical production release path. `eas-build.yml` handles CI builds on branch push.
- Branch ruleset (block direct push to main; require PR + passing CI) should be applied via GitHub repository settings → Rulesets. This is a manual step requiring repository admin access.

---

## Follow-up Tasks

- [ ] Apply branch protection ruleset to `main` in GitHub repository settings (requires admin access)
- [ ] Apply branch protection to `develop` (require CI to pass before merge)
- [ ] Add required secrets to repository: `EXPO_TOKEN`, `APP_STORE_CONNECT_API_KEY`, `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `GOOGLE_SERVICE_ACCOUNT_JSON`
- [ ] Configure EAS project (`eas.json`) with the correct Expo project slug and owner
