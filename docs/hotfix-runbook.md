# Hotfix Runbook

Hotfixes are for production incidents that cannot wait for the normal release cycle. Follow this runbook step by step without deviation.

---

## When to Use This Runbook

Use the hotfix process when **all three** of the following are true:

1. A bug exists on `main` (i.e., it is in production or in a recent release)
2. The bug causes a user-facing crash, data loss, or security issue
3. The fix cannot wait for the next scheduled release cycle

For non-urgent bugs, open a normal `fix/*` branch against `develop` instead.

---

## Step-by-Step Process

### 1. Branch from `main`

Always branch from `main`, not `develop`. This ensures only the fix — and none of the unreleased work on `develop` — ships in the hotfix.

```bash
git checkout main
git pull origin main
git checkout -b hotfix/<short-description>
# Example: git checkout -b hotfix/payment-crash
```

### 2. Apply the Fix

Make the smallest possible change that resolves the incident. Resist the urge to clean up surrounding code — scope creep in a hotfix is dangerous.

Commit using Conventional Commits:

```bash
git commit -m "fix(<scope>): <concise description of the fix>"
# Example: git commit -m "fix(payments): handle null receipt on iOS 17"
```

### 3. Open a PR Targeting `main`

- Title: `fix(<scope>): <description>` (Conventional Commits format)
- Description: explain what broke, what caused it, and what the fix does
- Link to any relevant incident report, Sentry issue, or crash log
- **Requires 1 approval**
- **CI must pass** (lint + typecheck + test)
- Merge using a **merge commit** (not squash)

### 4. Tag the Release After Merging

After the PR merges to `main`, tag the commit immediately:

```bash
git checkout main
git pull origin main
git tag v<version>           # e.g. git tag v1.2.1
git push origin v<version>   # triggers release.yml → EAS production build + submit
```

Increment the **patch** segment for hotfixes: `v1.2.0` → `v1.2.1`.

### 5. Back-Merge to `develop`

Immediately sync the fix to `develop` so future releases include it:

```bash
git checkout develop
git pull origin develop
git merge --no-ff origin/main -m "chore: merge hotfix/<description> back to develop"
git push origin develop
```

Do not use squash merge for the back-merge — preserve the commit history.

### 6. Clean Up

```bash
git push origin --delete hotfix/<short-description>
```

Delete the hotfix branch after the back-merge is complete.

---

## Communication During an Incident

| Phase | Action |
|---|---|
| Incident detected | Post in team Slack channel: branch name, nature of the bug, severity |
| Fix merged to `main` | Share the PR link and tag pushed |
| Build complete | Share EAS build link; confirm production deployment |
| Post-incident | Write a short incident report: what broke, root cause, fix applied, prevention |

---

## EAS Build Status

The `release.yml` workflow triggers automatically on the tag push. Monitor the build at [expo.dev/builds](https://expo.dev/builds).

If the EAS build fails:
1. Check the build logs on expo.dev
2. Fix the build issue on the hotfix branch
3. Push a new commit (CI must re-pass)
4. After merging the fix, push the tag again (delete and recreate if needed)

---

## Rollback (Last Resort)

If the hotfix makes things worse and a rollback is needed:

```bash
# Revert the merge commit on main
git checkout main
git pull origin main
git revert -m 1 <merge-commit-sha>
git push origin main
```

Then open a PR with the revert commit. Do not force-push `main`.

For OTA updates (JS-only changes), an Expo OTA rollback is faster than a store resubmission:

```bash
eas update --branch production --message "rollback: revert <description>"
```

---

## Reference

- Branching model: `docs/branching.md`
- Release process: `docs/release-checklist.md`
- CI/CD pipeline: `docs/ci-cd.md`
