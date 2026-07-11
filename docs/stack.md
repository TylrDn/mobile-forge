# Stack Overview

A reference for every technology decision in this scaffold — what it is, why it was chosen, and what it replaces.

---

## Quick Reference

### Core

| Layer | Tech | Version |
|---|---|---|
| Framework | React Native + Expo SDK | SDK 52+ |
| Language | TypeScript | 5.x (strict) |
| Navigation | Expo Router | v4 (file-based) |
| State Management | Zustand | v5 |
| Data Fetching | TanStack Query | v5 |
| Styling | NativeWind | v4 (Tailwind v3) |
| Forms | React Hook Form + Zod | latest |

### Tooling

| Tool | Purpose |
|---|---|
| Bun | Package manager + runtime |
| Biome | Lint + format (replaces ESLint + Prettier) |
| EAS Build | Cloud builds — iOS + Android |
| EAS Submit | App store submissions |
| EAS Update | OTA updates |
| Maestro | E2E testing |

### Platform Targets

| Platform | Minimum Version |
|---|---|
| iOS | 16.0 |
| Android | 10 (API 29) |

---

## Decision Log

### React Native + Expo — not bare RN, not Flutter

**Expo Managed/Bare workflow** provides a curated SDK that keeps native modules in sync, a cloud build service (EAS), and an OTA update mechanism — all without requiring local Xcode or Android Studio for most CI tasks.

Bare React Native is chosen when teams need full native control and have dedicated mobile engineers maintaining custom native modules. That is not the common case here.

Flutter was evaluated and rejected for two reasons: (1) Dart is a separate language ecosystem from the TypeScript/JavaScript stack used across all other projects, and (2) code sharing with web via React Native Web is a realistic path; Dart/Flutter's web support is not mature enough for production parity.

Expo's SDK compatibility table and EAS's managed infrastructure remove the most painful parts of mobile development — local environment setup, certificate management, and native toolchain maintenance.

---

### TypeScript — strict mode

`strict: true` in `tsconfig.json` enables the full set of type-safety checks:

- `strictNullChecks` — eliminates a class of null/undefined runtime errors
- `noImplicitAny` — forces explicit types at API boundaries
- `strictFunctionTypes` — catches contravariant function signature bugs
- `strictPropertyInitialization` — prevents uninitialized class members

The initial overhead of writing stricter types pays off in refactoring confidence and eliminates entire categories of production bugs. All new projects start in strict mode; loosening it later is a one-way door.

---

### Bun — not npm or yarn

Bun is the package manager (and runtime) of choice for three reasons:

1. **Speed** — `bun install` is 10–30× faster than `npm install` on cold caches, primarily because it avoids redundant symlink resolution and uses a binary lockfile.
2. **Lockfile format** — `bun.lockb` is a binary file that is smaller and faster to parse than `package-lock.json` or `yarn.lock`. It is deterministic and human-unreadable (intentionally — you never edit it by hand).
3. **Built-in test runner** — `bun test` supports Jest-compatible APIs with no additional configuration.

Bun is not used as the runtime for the React Native app itself (Metro/Hermes handle that). It is used exclusively as the package manager and development toolchain runner.

---

### Expo Router — not React Navigation

Expo Router v4 introduces file-based routing modeled after Next.js App Router. Routes are defined by file structure under `app/`, which provides:

- **Automatic deep linking** — every route is automatically a valid deep link URL with zero additional configuration.
- **Typed routes** — route parameters are typed at the file level, surfacing navigation errors at compile time rather than runtime.
- **Shared layouts** — `_layout.tsx` files wrap nested routes with persistent UI (tab bars, stack headers) without prop drilling.
- **Web support** — the same file structure works for Expo Web, enabling a single codebase across iOS, Android, and web.

React Navigation is still the underlying primitive (Expo Router is built on it), but direct use of React Navigation APIs is avoided to preserve the file-based routing contract.

---

### NativeWind — not StyleSheet

NativeWind applies Tailwind CSS utility classes to React Native components via a Babel plugin and a runtime style resolver.

**Why it replaces `StyleSheet.create`:**

- **Co-location** — styles live on the component, not in a separate `StyleSheet` block. Reading a component tells you everything about its appearance.
- **Tailwind familiarity** — developers who know Tailwind (virtually every web engineer on the team) can contribute to mobile UI immediately, without learning the React Native style system's quirks (`flex` defaults, no `display: block`, no shorthand properties, etc.).
- **Design token parity** — a single `tailwind.config.ts` defines colors, spacing, and typography for both web and mobile, eliminating drift between platforms.
- **Dark mode** — NativeWind's `dark:` variant integrates with the system color scheme automatically.

NativeWind v4 generates static classes at build time (similar to Tailwind's JIT engine), so there is no runtime CSS parsing overhead.

---

### Biome — not ESLint + Prettier

Biome is a single Rust-based tool that handles both linting and formatting. It replaces the ESLint + Prettier combination.

**Why this matters in practice:**

- **Zero config drift** — ESLint and Prettier often fight over formatting rules (e.g., quote style, trailing commas) when configured separately. Biome owns both lint and format in a single `biome.json`, eliminating the conflict surface.
- **Speed** — Biome runs lint + format passes 10–50× faster than the equivalent ESLint + Prettier setup, primarily because it is written in Rust and parallelizes file processing.
- **Single dependency** — one `devDependency` instead of a constellation of ESLint plugins, `@typescript-eslint/*` packages, `eslint-config-*`, and `prettier` + `eslint-config-prettier`.
- **Stable defaults** — Biome's default ruleset is opinionated and stable. There is no "which ESLint preset do I extend?" decision to make.

The tradeoff is that Biome does not yet have parity with every ESLint plugin (notably `eslint-plugin-react-hooks`). The missing rules are documented in `biome.json` comments and revisited each release.

---

### EAS Build + EAS Submit

EAS (Expo Application Services) Build runs iOS and Android builds on Expo's managed cloud infrastructure.

**Why this matters:**

- **No local Xcode or Android Studio required for CI** — builds run on Expo's macOS and Linux workers. A developer on Windows or Linux can produce a valid iOS `.ipa` without owning a Mac.
- **Reproducible environments** — EAS pins the Xcode version, NDK version, and SDK version per build profile. "Works on my machine" build failures disappear.
- **Certificate management** — EAS manages provisioning profiles and signing certificates, including automatic renewal.
- **EAS Submit** integrates directly with App Store Connect and Google Play, automating the upload step after a successful build.

Build profiles (`development`, `preview`, `production`) are defined in `eas.json` and map to different signing configurations, bundle identifiers, and distribution channels.

---

### State Management — Zustand

Zustand is the preferred state management library. It was chosen over Redux Toolkit, Jotai, and MobX for the following reasons:

- **Minimal boilerplate** — a store is a single `create()` call. There are no actions, reducers, or selectors to wire up separately.
- **No Provider wrapping** — Zustand stores are module-level singletons. Components subscribe directly without a `<Provider>` in the component tree, which simplifies testing and eliminates context performance pitfalls.
- **TypeScript-first** — the `create<State>()` generic infers action types automatically.
- **Middleware ecosystem** — `persist`, `immer`, `devtools`, and `subscribeWithSelector` middleware cover the common extension points without a framework-level dependency.
- **Small bundle** — ~1 kB gzipped.

Zustand is used for client-side UI state (auth session, theme, modal state, form drafts). It is not used as a server state cache — that is TanStack Query's responsibility.

---

### Data Fetching — TanStack Query

TanStack Query (formerly React Query) manages all server state: fetching, caching, background refresh, and synchronization.

**Why it replaces ad-hoc `useEffect` fetching:**

- **Automatic caching and deduplication** — multiple components requesting the same query key share a single in-flight request and a shared cache entry.
- **Background refetch** — stale data is served immediately while fresh data is fetched in the background, eliminating loading spinners for cached screens.
- **Optimistic updates** — mutations can update the UI before the server confirms, with automatic rollback on error.
- **Offline support** — queries can be paused when the device is offline and automatically retried when connectivity resumes.
- **DevTools** — the TanStack Query DevTools panel exposes cache state, query status, and retry counts during development.

TanStack Query does not prescribe a transport layer. Fetch, Axios, or a typed API client (e.g., generated from OpenAPI) all work as the underlying fetcher.
