# Copilot Instructions — mobile-forge

> You are working in `TylrDn/mobile-forge`. This repo is governed by [TylrDn/CODE](https://github.com/TylrDn/CODE).

---

## Account Context

- **Central governance repo**: [TylrDn/CODE](https://github.com/TylrDn/CODE) — repo-index, session-log, agent workflow docs
- **This repo**: `TylrDn/mobile-forge` — canonical React Native / Expo scaffold template
- All changes go through Pull Requests — no direct push to `main`

---

## Stack

| Layer | Choice |
|---|---|
| Language | TypeScript (strict mode) |
| Framework | React Native + Expo SDK 52+ |
| Navigation | Expo Router v4 (file-based) |
| State | Zustand v5 |
| Data fetching | TanStack Query v5 |
| Styling | NativeWind v4 (Tailwind v3) |
| Package manager | Bun |
| Lint + format | Biome (replaces ESLint + Prettier) |
| CI/CD | GitHub Actions + EAS Build |

---

## Conventions

### Commits
All commits follow [Conventional Commits](https://www.conventionalcommits.org/):
```
<type>(<optional scope>): <short description>
```
Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`, `style`, `perf`, `revert`

See full rules: [agent/commit-conventions.md](https://github.com/TylrDn/CODE/blob/main/agent/commit-conventions.md)

### Branches
```
main        — production-ready, protected
develop     — integration branch
feature/*   — new features (branch from develop)
fix/*       — bug fixes (branch from develop)
hotfix/*    — emergency production patches (branch from main)
release/*   — release prep (branch from develop)
chore/*     — maintenance / tooling
```

### Pull Requests
- Title must follow Conventional Commits format
- All PRs require CI to pass (lint + typecheck + test)
- No direct pushes to `main` or `develop`
- Run through the review checklist: [agent/review-protocol.md](https://github.com/TylrDn/CODE/blob/main/agent/review-protocol.md)

---

## Before Making Changes

1. Read `docs/` for stack and branching decisions
2. Check `session-log/` for recent agent context
3. Follow commit and branch naming conventions above
4. After any agent session, create a log entry in `session-log/YYYY-MM-DD-slug.md`

---

## Key Files

| Path | Purpose |
|---|---|
| `docs/stack.md` | Technology decisions and rationale |
| `docs/branching.md` | Branch model, commit format, release process |
| `docs/release-checklist.md` | Pre-release and post-release checklist |
| `docs/hotfix-runbook.md` | Emergency production fix process |
| `scripts/bootstrap.sh` | One-command dev environment setup |
| `scripts/env-check.sh` | Verify required CLI tools are present |
| `.github/workflows/ci.yml` | Lint + typecheck + test on every PR |
| `.github/workflows/release.yml` | Expo build + deploy on semver tag push |
| `.github/workflows/eas-build.yml` | EAS build on push to develop/main |

---

## CI/CD

- **PR**: `ci.yml` runs lint (Biome), typecheck (tsc --noEmit), and tests (bun test)
- **Push to develop**: `eas-build.yml` triggers EAS preview build
- **Push to main**: `eas-build.yml` triggers EAS production build + submit
- **Semver tag** (`v*.*.*`): `release.yml` triggers EAS production build + submit

---

## Security Rules

- No hardcoded secrets, tokens, or credentials — use GitHub Secrets
- Required secrets: `EXPO_TOKEN`, `APP_STORE_CONNECT_API_KEY`, `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `GOOGLE_SERVICE_ACCOUNT_JSON`
- No `console.log` in production paths
- All new dependencies must be vetted for known CVEs
