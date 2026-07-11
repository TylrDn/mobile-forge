# 2026-07-11 — Pre-merge QoL polish

**Repo:** `TylrDn/mobile-forge`
**Session type:** Agent-driven quality-of-life pass
**Date:** 2026-07-11
**Governed by:** [TylrDn/CODE](https://github.com/TylrDn/CODE)

---

## Context

Final quality-of-life pass before merging the scaffold PR (`copilot/scaffold-mobile-forge`) into `main`. Addressed workflow redundancy, a double-production-build bug, missing concurrency control, and documentation gaps.

---

## Issues Found and Fixed

### 1. `eas-preview.yml` deleted — fully redundant
`eas-preview.yml` triggered on push to `develop` and ran `eas build --profile preview`. `eas-build.yml` already did exactly the same thing (also triggered on `develop`, also ran a preview build). Having both meant every push to `develop` fired two identical EAS preview builds, consuming double EAS build minutes.

**Fix:** Deleted `eas-preview.yml`.

### 2. `eas-build.yml` scoped to `develop` only — removed double production build
`eas-build.yml` triggered on push to both `develop` and `main`. On `main` it ran a production EAS build + submit. `release.yml` also runs a production EAS build + submit, triggered by a semver tag push. Per the branching model (`docs/branching.md`), the tag push (not the branch push) is the canonical production release trigger. This meant merging a release PR to `main` and then pushing the tag would fire two production builds and two App Store / Play Store submissions simultaneously.

**Fix:** Scoped `eas-build.yml` trigger to `develop` only. Simplified the job name and removed the now-dead profile-detection logic and EAS Submit step.

### 3. Concurrency cancellation added to `ci.yml`
`ci.yml` ran on `push: branches: ["**"]` AND `pull_request`. Pushing to a feature branch and then opening a PR caused CI to run twice for the same commit. Added a `concurrency` group keyed on `github.ref` with `cancel-in-progress: true` so stale runs are cancelled when a new push supersedes them.

### 4. `README.md` updated
- Added `session-log/` and `PULL_REQUEST_TEMPLATE.md` to the structure tree
- Added `Hotfix Runbook` to the docs links (was missing)
- Reordered docs links to match logical workflow order

### 5. `copilot-instructions.md` corrected
- Removed the now-incorrect "Push to main: eas-build.yml triggers EAS production build + submit" line from the CI/CD section
- Updated the Key Files table to accurately describe each workflow file's trigger

---

## Files Changed

| File | Action |
|---|---|
| `.github/workflows/eas-preview.yml` | Deleted |
| `.github/workflows/eas-build.yml` | Scoped to `develop` only; removed production logic |
| `.github/workflows/ci.yml` | Added `concurrency` block |
| `README.md` | Updated structure tree and docs links |
| `.github/copilot-instructions.md` | Corrected CI/CD section and key files table |

---

## Follow-up Tasks (unchanged from previous session)

- [ ] Apply branch protection ruleset to `main` — block direct push, require PR + passing CI (requires admin access in GitHub settings)
- [ ] Apply branch protection to `develop`
- [ ] Add required secrets: `EXPO_TOKEN`, `APP_STORE_CONNECT_API_KEY`, `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `GOOGLE_SERVICE_ACCOUNT_JSON`
- [ ] Configure `eas.json` with correct Expo project slug and owner
