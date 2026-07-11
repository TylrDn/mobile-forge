#!/bin/bash
# env-check.sh — Verify that all required CLI tools are present and meet minimum versions.
# Exits non-zero if any required tool is missing or below the minimum version.
set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}  ✓${RESET} $*"; }
warn() { echo -e "${YELLOW}  ⚠${RESET} $*"; }
fail() { echo -e "${RED}  ✗${RESET} $*"; FAILED=1; }

FAILED=0

echo ""
echo -e "${BOLD}📱 mobile-forge — environment check${RESET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── git ──────────────────────────────────────────────────────────────────────

if command -v git > /dev/null 2>&1; then
  ok "git $(git --version | sed 's/git version //')"
else
  fail "git — not found. Install from https://git-scm.com"
fi

# ── Node.js (>=20) ────────────────────────────────────────────────────────────

if command -v node > /dev/null 2>&1; then
  NODE_VERSION=$(node --version | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 20 ]; then
    ok "node v${NODE_VERSION}"
  else
    fail "node v${NODE_VERSION} — Node.js 20+ required. Upgrade at https://nodejs.org"
  fi
else
  fail "node — not found. Install Node.js 20+ from https://nodejs.org"
fi

# ── Bun ───────────────────────────────────────────────────────────────────────

if command -v bun > /dev/null 2>&1; then
  ok "bun $(bun --version)"
else
  fail "bun — not found. Install from https://bun.sh"
fi

# ── Expo CLI (via bun x expo) ─────────────────────────────────────────────────

if command -v bun > /dev/null 2>&1; then
  EXPO_VERSION=$(bun x expo --version 2>/dev/null || echo "")
  if [ -n "$EXPO_VERSION" ]; then
    ok "expo CLI ${EXPO_VERSION}"
  else
    warn "expo CLI — not reachable via 'bun x expo'. Run: bun install"
  fi
fi

# ── EAS CLI ───────────────────────────────────────────────────────────────────

if command -v eas > /dev/null 2>&1; then
  EAS_VERSION=$(eas --version 2>/dev/null | head -1 || echo "unknown")
  ok "eas ${EAS_VERSION}"
else
  warn "eas — not found (optional for local dev). Install: bun install -g eas-cli"
fi

# ── gh CLI ────────────────────────────────────────────────────────────────────

if command -v gh > /dev/null 2>&1; then
  GH_VERSION=$(gh --version | head -1 | awk '{print $3}')
  ok "gh ${GH_VERSION}"
else
  warn "gh — not found (recommended). Install from https://cli.github.com"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAILED" -ne 0 ]; then
  echo -e "${RED}${BOLD}✗ Environment check failed. Fix the errors above and re-run.${RESET}"
  echo ""
  exit 1
else
  echo -e "${GREEN}${BOLD}✓ Environment looks good.${RESET}"
  echo ""
fi
