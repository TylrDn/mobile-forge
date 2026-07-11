# 2026-07-11 — Fix CI: scaffold Expo project

## Context

CI was failing on every push to `main` with:

```
error: Bun could not find a package.json file to install from
```

The repository contained only docs, scripts, and GitHub Actions workflows — no actual Expo/React Native project had been initialized.

## Root Cause

The `ci.yml` workflow runs `bun install --frozen-lockfile` as its first step. Without a `package.json` (and therefore no `bun.lock` lockfile), every job immediately failed before any real checks could run.

Two additional CI bugs were present:
- **Wrong lockfile filename**: cache key used `bun.lockb` (old binary format); bun 1.x generates `bun.lock` (text format).
- **Unstable bun version**: `bun-version: latest` risks breaking CI on a major bun release; changed to `"1.x"`.

## Changes Made

### New project files
| File | Purpose |
|---|---|
| `package.json` | Expo SDK 52 + full stack (Expo Router v4, NativeWind v4, Zustand v5, TanStack Query v5, React Hook Form, Zod, Biome, TypeScript) |
| `bun.lock` | Generated lockfile (committed for reproducible installs) |
| `tsconfig.json` | Strict TypeScript extending `expo/tsconfig.base`; includes `nativewind/types` and `bun-types` |
| `biome.json` | Lint + format config (Biome 1.x) |
| `app.json` | Expo app configuration (New Architecture enabled, iOS 16+, Android API 29+) |
| `eas.json` | EAS build profiles: development, preview, production |
| `metro.config.js` | Metro bundler config with NativeWind integration |
| `babel.config.js` | Expo babel preset with NativeWind jsxImportSource |
| `tailwind.config.js` | NativeWind/Tailwind config pointing at `app/` and `src/` |
| `global.css` | Tailwind directive entrypoint |
| `expo-env.d.ts` | Expo type declarations + CSS module type augmentation |
| `app/_layout.tsx` | Expo Router root layout with TanStack QueryClientProvider |
| `app/index.tsx` | Home screen (NativeWind styled) |
| `src/__tests__/smoke.test.ts` | Bun test smoke tests (ensures `bun test` always has at least one test file) |

### Modified workflow files
- `.github/workflows/ci.yml` — fixed lockfile hash, pinned bun to `1.x`
- `.github/workflows/eas-build.yml` — same fixes
- `.github/workflows/release.yml` — same fixes

## Verification

All three CI checks passed locally before committing:
- `bunx biome check .` → no issues
- `bunx tsc --noEmit` → no errors
- `bun test` → 2 pass, 0 fail

CodeQL + Code Review: no issues found.
