# 📱 mobile-forge

> Mobile-first project scaffold — React Native / Expo boilerplate, CI/CD templates, and release tooling.

## Structure

```
mobile-forge/
├── docs/               # Architecture decisions, runbooks, platform guides
├── scripts/            # Dev automation (bootstrap, build, release)
├── session-log/        # Agent session logs (YYYY-MM-DD-slug.md)
├── .github/
│   ├── workflows/      # CI/CD pipeline templates
│   └── PULL_REQUEST_TEMPLATE.md
└── README.md
```

## Quick Start

```bash
# Clone and bootstrap
git clone https://github.com/TylrDn/mobile-forge.git
cd mobile-forge
bash scripts/bootstrap.sh
```

## Docs

- [Stack Overview](docs/stack.md)
- [Branching Strategy](docs/branching.md)
- [CI/CD Pipeline](docs/ci-cd.md)
- [Release Checklist](docs/release-checklist.md)
- [Hotfix Runbook](docs/hotfix-runbook.md)

## Related

- [dev-kit](https://github.com/TylrDn/dev-kit) — Dev environment & tooling configs
