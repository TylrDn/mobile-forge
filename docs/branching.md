# Branching Strategy

## Branch Model

```
main          ← production-ready, tagged releases
develop       ← integration branch
feature/*     ← new features (branch from develop)
fix/*         ← bug fixes (branch from develop)
hotfix/*      ← urgent prod fixes (branch from main)
release/*     ← release prep (branch from develop)
```

## Rules

- `main` is protected — PRs only, require passing CI
- `develop` is the default working branch
- Feature branches: `feature/short-description`
- Hotfixes merge into both `main` and `develop`
- Delete branches after merge

## Commit Convention

Follows [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add push notification support
fix: resolve Android back handler crash
chore: bump expo sdk to 52
docs: update release checklist
```
