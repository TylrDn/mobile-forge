# CI/CD Pipeline

## Overview

All pipelines run via GitHub Actions + EAS.

| Trigger | Pipeline | Output |
|---|---|---|
| PR to `develop` | `ci.yml` | Lint + test + type check |
| Merge to `develop` | `eas-preview.yml` | EAS preview build + OTA update |
| Merge to `main` | `eas-production.yml` | EAS production build + submit |

## Secrets Required

Set in GitHub repo Settings → Secrets:

```
EXPO_TOKEN
APPLE_ID
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY
GOOGLE_SERVICE_ACCOUNT_JSON
```

## Local EAS Auth

```bash
npx eas-cli login
npx eas-cli whoami
```
