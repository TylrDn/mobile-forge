#!/bin/bash
# bootstrap.sh — Set up a new development environment for this project.
# Safe to run multiple times (idempotent).
set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${BOLD}[bootstrap]${RESET} $*"; }
success() { echo -e "${GREEN}[bootstrap] ✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}[bootstrap] ⚠${RESET} $*"; }
error()   { echo -e "${RED}[bootstrap] ✗${RESET} $*" >&2; exit 1; }

echo ""
echo -e "${BOLD}📱 mobile-forge — bootstrap${RESET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. Check required tools ──────────────────────────────────────────────────

info "Checking required tools..."

# git
if ! command -v git > /dev/null 2>&1; then
  error "git is not installed. Install it from https://git-scm.com and re-run."
fi
success "git $(git --version | awk '{print $3}')"

# node (>=20)
if ! command -v node > /dev/null 2>&1; then
  error "node is not installed. Install Node.js 20+ from https://nodejs.org and re-run."
fi
NODE_VERSION=$(node --version | sed 's/v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 20 ]; then
  error "Node.js 20+ is required. Current version: v${NODE_VERSION}. Upgrade at https://nodejs.org."
fi
success "node v${NODE_VERSION}"

# bun
if ! command -v bun > /dev/null 2>&1; then
  warn "bun is not installed. Installing via the official install script..."
  curl -fsSL https://bun.sh/install | bash
  # Add bun to PATH for the remainder of this script
  export PATH="$HOME/.bun/bin:$PATH"
  if ! command -v bun > /dev/null 2>&1; then
    error "bun installation failed. Install manually: https://bun.sh/docs/installation"
  fi
fi
success "bun $(bun --version)"

# eas-cli (optional but recommended)
if ! command -v eas > /dev/null 2>&1; then
  warn "eas-cli is not installed. Installing globally..."
  bun install -g eas-cli
fi
EAS_VERSION=$(eas --version 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$EAS_VERSION" ]; then
  success "eas ${EAS_VERSION}"
else
  success "eas installed (run 'eas --version' to verify)"
fi

echo ""

# ── 2. Install dependencies ──────────────────────────────────────────────────

info "Installing dependencies (bun install)..."
bun install
success "Dependencies installed."

echo ""

# ── 3. Copy .env.example → .env ─────────────────────────────────────────────

if [ -f ".env.example" ]; then
  if [ ! -f ".env" ]; then
    cp .env.example .env
    success ".env created from .env.example — fill in the values before running the app."
  else
    warn ".env already exists — skipping copy. Check .env.example for any new variables."
  fi
else
  warn ".env.example not found — skipping .env setup."
fi

echo ""

# ── 4. Sync Expo SDK dependencies ────────────────────────────────────────────

info "Syncing Expo SDK dependencies (bun expo install)..."
bun expo install
success "Expo SDK dependencies synced."

echo ""

# ── Done ─────────────────────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}${BOLD}✅ Bootstrap complete!${RESET}"
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit ${BOLD}.env${RESET} with your local environment values"
echo "  2. Log in to EAS:         ${BOLD}eas login${RESET}"
echo "  3. Start the dev server:  ${BOLD}bun start${RESET}"
echo "  4. Run on iOS:            ${BOLD}bun ios${RESET}"
echo "  5. Run on Android:        ${BOLD}bun android${RESET}"
echo ""
