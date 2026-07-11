# Branching Strategy

This document defines the branch model, naming conventions, commit message format, PR rules, hotfix process, and release tagging used across all projects based on this scaffold.

---

## Branch Model

```
main
│   Production-ready code. Every commit on main is a released version.
│   Protected: direct pushes disabled. Merge via PR only.
│
develop
│   Integration branch. Features are merged here first.
│   CI runs on every push. EAS preview build triggers on merge.
│
├── feature/<short-description>
│       New capabilities branched from develop.
│       Merged back to develop via PR (squash merge).
│
├── fix/<short-description>
│       Non-urgent bug fixes branched from develop.
│       Merged back to develop via PR (squash merge).
│
├── release/<version>
│       Release prep branched from develop.
│       Only contains version bumps, changelog updates, and last-minute fixes.
│       Merged to main (merge commit) and back-merged to develop.
│
└── hotfix/<short-description>
        Urgent production fixes branched from main.
        Merged to main (merge commit) and back-merged to develop immediately.
```

---

## Naming Conventions

Branch names use lowercase kebab-case with a prefix that indicates intent.

| Prefix | When to use | Examples |
|---|---|---|
| `feature/` | New user-facing capability | `feature/auth-flow`, `feature/push-notifications`, `feature/onboarding-screens` |
| `fix/` | Non-urgent bug fix | `fix/crash-on-launch-ios`, `fix/avatar-upload-timeout`, `fix/dark-mode-flash` |
| `release/` | Release preparation | `release/1.2.0`, `release/2.0.0-rc1` |
| `hotfix/` | Urgent production fix | `hotfix/payment-crash`, `hotfix/token-refresh-loop` |
| `chore/` | Maintenance with no product impact | `chore/upgrade-expo-sdk-52`, `chore/update-dependencies` |

**Rules:**

- No uppercase letters, no spaces, no special characters except `-` and `/`.
- Keep descriptions short (2–4 words).
- Use the issue number as a suffix when one exists: `feature/auth-flow-42`.

---

## Commit Message Format

All commits follow [Conventional Commits](https://www.conventionalcommits.org/) v1.0.0.

```
<type>(<optional scope>): <short summary>

[optional body]

[optional footer: BREAKING CHANGE: ..., Closes #123]
```

### Types

| Type | When to use |
|---|---|
| `feat` | A new feature visible to users |
| `fix` | A bug fix |
| `chore` | Build process, dependency updates, scaffolding |
| `docs` | Documentation only |
| `refactor` | Code restructuring with no behavior change |
| `test` | Adding or updating tests |
| `ci` | CI/CD configuration changes |
| `perf` | Performance improvements |
| `style` | Formatting, whitespace (no logic change) |
| `revert` | Reverting a previous commit |

### Examples

```
feat(auth): add biometric login support
fix(android): resolve back handler crash on modal dismiss
chore: bump expo sdk to 52
docs: update branching strategy with hotfix process
refactor(api): extract request interceptor into shared module
ci: add Bun cache to EAS build workflow
feat!: replace React Navigation with Expo Router

BREAKING CHANGE: All navigation imports must be updated.
Closes #88
```

### Rules

- Summary line: 72 characters maximum, imperative mood ("add", not "adds" or "added").
- No period at the end of the summary line.
- Breaking changes must include `!` after the type and a `BREAKING CHANGE:` footer.
- Reference issues with `Closes #<number>` or `Refs #<number>` in the footer.

---

## Pull Request Rules

### Opening a PR

- Title must follow Conventional Commits format (same as commit messages).
- Description must include: what changed, why it changed, and how to test it.
- Link to the relevant issue or discussion.
- Screenshots or screen recordings for any UI changes.

### Merge Requirements

| Target branch | Approvals required | CI required | Merge strategy |
|---|---|---|---|
| `develop` | 1 | lint + typecheck + test | Squash merge |
| `main` | 1 | lint + typecheck + test | Merge commit (no squash) |

Squash merging into `develop` keeps the integration branch history linear and readable. Merge commits into `main` preserve the full commit history from the release branch, making `git log main` a reliable audit trail of what shipped in each release.

### Branch Cleanup

Delete the source branch immediately after merging. GitHub's "Delete branch" button is configured as the default post-merge action.

---

## Hotfix Process

Hotfixes are for production incidents that cannot wait for the normal release cycle.

```
1. Branch from main:
   git checkout main
   git pull origin main
   git checkout -b hotfix/payment-crash

2. Apply the fix. Commit using Conventional Commits:
   git commit -m "fix(payments): handle null receipt on iOS 17"

3. Open a PR targeting main.
   - Requires 1 approval.
   - CI must pass.
   - Merge using a merge commit (not squash).

4. After merging to main, immediately back-merge to develop:
   git checkout develop
   git pull origin develop
   git merge --no-ff origin/main -m "chore: merge hotfix/payment-crash back to develop"
   git push origin develop

5. Tag the release on main (see Tagging section below).

6. Trigger EAS production build manually or via the tag push.
```

Never open a hotfix against `develop` and promote it — that defeats the purpose. If `develop` has unreleased changes that should not ship, branching from `main` ensures only the fix is released.

---

## Release Process

```
1. Branch from develop:
   git checkout develop
   git pull origin develop
   git checkout -b release/1.2.0

2. Run the release script to bump versions:
   bash scripts/release.sh 1.2.0

3. Update CHANGELOG.md with the release notes.

4. Open a PR targeting main.
   - Title: "release: v1.2.0"
   - Requires 1 approval and passing CI.
   - Merge using a merge commit.

5. After merging to main, back-merge to develop:
   git checkout develop
   git merge --no-ff origin/main -m "chore: merge release/1.2.0 back to develop"
   git push origin develop

6. The release script already created the tag locally.
   Push it: git push origin v1.2.0
```

---

## Tag Format

All release tags follow semantic versioning:

```
v{major}.{minor}.{patch}
```

| Segment | Increment when |
|---|---|
| `major` | Breaking changes to APIs or navigation structure |
| `minor` | New features, backward-compatible |
| `patch` | Bug fixes, hotfixes |

**Examples:** `v1.0.0`, `v1.2.0`, `v2.0.0`, `v1.2.1`

Pre-release versions (release candidates): `v2.0.0-rc.1`

Tags are created by `scripts/release.sh` and pushed manually after the PR merges to `main`. The EAS production build workflow triggers on tags matching `v*.*.*`.
