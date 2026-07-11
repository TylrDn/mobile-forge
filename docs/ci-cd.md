# CI/CD Pipeline

This document covers the full pipeline: trigger matrix, job definitions, EAS build profiles, required secrets, and cache strategy.

---

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                         │
└────────────────────────┬────────────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                 │
   Pull Request                     Push to branch
  (any → develop,                  (develop or main)
    any → main)                          │
        │                    ┌───────────┴────────────┐
        ▼                    │                        │
  ┌──────────┐          push to develop          push to main
  │  ci.yml  │               │                        │
  ├──────────┤               ▼                        ▼
  │ 1. lint  │       ┌──────────────┐        ┌──────────────────┐
  │ 2. type  │       │eas-build.yml │        │  eas-build.yml   │
  │    check │       │(preview prof)│        │(production prof) │
  │ 3. test  │       └──────┬───────┘        └────────┬─────────┘
  └──────────┘              │                         │
                            ▼                         ▼
                     EAS Preview Build         EAS Production Build
                     (iOS + Android)           (iOS + Android)
                                                       │
                                                       ▼
                                               EAS Submit
                                            (App Store + Play Store)
```

---

## Trigger Matrix

| Event | Workflow | Jobs |
|---|---|---|
| PR opened/updated → `develop` or `main` | `ci.yml` | lint, typecheck, test |
| Push to `develop` | `eas-build.yml` | EAS build (preview profile) |
| Push to `main` | `eas-build.yml` | EAS build (production profile) + EAS submit |

All CI jobs must pass before a PR can be merged. Lint and typecheck run in parallel; tests run after both pass.

---

## Job Definitions

### ci.yml — Lint

```yaml
- name: Lint
  run: bunx biome check .
```

Biome checks all `.ts`, `.tsx`, `.js`, and `.json` files. Fails on any lint error or formatting violation. No auto-fix in CI — developers must fix locally and re-push.

### ci.yml — Typecheck

```yaml
- name: Typecheck
  run: bunx tsc --noEmit
```

Runs the TypeScript compiler in check-only mode. Uses `tsconfig.json` with `strict: true`. Fails on any type error. This job runs in parallel with lint.

### ci.yml — Test

```yaml
- name: Test
  run: bun test
```

Runs the Bun test runner. If no test files exist, the step exits cleanly. Tests run after lint and typecheck pass to avoid wasting runner time on a codebase that does not compile.

### eas-build.yml — EAS Build (Preview)

Triggered by push to `develop`. Runs `eas build --platform all --profile preview --non-interactive`. Produces unsigned `.apk` (Android) and ad-hoc `.ipa` (iOS) artifacts for internal testing.

### eas-build.yml — EAS Build (Production) + Submit

Triggered by push to `main`. Runs `eas build --platform all --profile production --non-interactive`, then `eas submit --platform all --non-interactive`. Produces signed store-ready artifacts and submits them to App Store Connect and Google Play.

---

## EAS Build Profiles

Profiles are defined in `eas.json` at the project root. The scaffold ships with three profiles:

### `development`

Used for local development with a development client. Installs the Expo Dev Client, enables remote debugging, and connects to a local Metro bundler.

```json
"development": {
  "developmentClient": true,
  "distribution": "internal"
}
```

### `preview`

Used for internal QA on real devices. Ad-hoc distribution (iOS) and APK (Android). Does not go through the App Store review process.

```json
"preview": {
  "distribution": "internal",
  "ios": {
    "simulator": false
  }
}
```

### `production`

Used for App Store and Google Play submissions. Requires valid distribution certificates and provisioning profiles. EAS manages these automatically when `EXPO_TOKEN` is present.

```json
"production": {
  "distribution": "store",
  "ios": {
    "autoIncrement": true
  },
  "android": {
    "autoIncrement": true
  }
}
```

---

## Required Secrets

Set all secrets in **GitHub → Repository Settings → Secrets and variables → Actions → Repository secrets**.

| Secret | Where to get it | Used by |
|---|---|---|
| `EXPO_TOKEN` | [expo.dev/accounts/\<user\>/settings/access-tokens](https://expo.dev/accounts) | EAS Build, EAS Submit |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect → Users and Access → Keys → Generate | EAS Submit (iOS) |
| `APP_STORE_CONNECT_API_KEY_ID` | Same page as above (10-character Key ID) | EAS Submit (iOS) |
| `APP_STORE_CONNECT_ISSUER_ID` | Same page as above (UUID shown at top) | EAS Submit (iOS) |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | Google Play Console → Setup → API access → Create service account | EAS Submit (Android) |

### How to Add a New Secret

1. Go to the repository on GitHub.
2. Click **Settings** → **Secrets and variables** → **Actions**.
3. Click **New repository secret**.
4. Enter the secret name exactly as it appears in the workflow YAML (case-sensitive).
5. Paste the secret value. Click **Add secret**.
6. To update an existing secret, click the pencil icon next to its name.

Secrets are never logged or exposed in workflow output. If a workflow step prints a secret value, GitHub automatically redacts it as `***`.

---

## Cache Strategy

### Bun Package Cache

```yaml
- name: Cache Bun dependencies
  uses: actions/cache@v4
  with:
    path: ~/.bun/install/cache
    key: ${{ runner.os }}-bun-${{ hashFiles('bun.lockb') }}
    restore-keys: |
      ${{ runner.os }}-bun-
```

The cache key is keyed on `bun.lockb`. When the lockfile changes (a dependency is added or updated), the cache is invalidated and rebuilt. The `restore-keys` fallback restores a partial cache when the exact key misses, which still speeds up `bun install` significantly.

### Expo + React Native Cache

EAS Build caches the Gradle daemon (Android) and derived data (iOS) on Expo's infrastructure automatically. No additional cache configuration is needed in the GitHub Actions workflow for the build steps themselves — only the `bun install` step needs the cache above.

---

## Local EAS Authentication

To run EAS commands locally:

```bash
# Install EAS CLI
bun install -g eas-cli

# Log in
eas login

# Verify
eas whoami

# Run a build locally (development profile)
eas build --platform ios --profile development --local
```
