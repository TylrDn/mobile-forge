#!/bin/bash
# release.sh — Bump the app version, commit, and tag.
# Usage: bash scripts/release.sh <semver>
# Example: bash scripts/release.sh 1.2.0
set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${BOLD}[release]${RESET} $*"; }
success() { echo -e "${GREEN}[release] ✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}[release] ⚠${RESET} $*"; }
error()   { echo -e "${RED}[release] ✗${RESET} $*" >&2; exit 1; }

# ── 1. Validate argument ─────────────────────────────────────────────────────

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  error "Version argument required. Usage: bash scripts/release.sh <semver>\n         Example: bash scripts/release.sh 1.2.0"
fi

# Validate semver format: MAJOR.MINOR.PATCH (all numeric)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  error "Invalid version: '${VERSION}'. Must be in semver format MAJOR.MINOR.PATCH (e.g. 1.2.0)."
fi

TAG="v${VERSION}"

echo ""
echo -e "${BOLD}📦 mobile-forge — release ${TAG}${RESET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 2. Check working directory ───────────────────────────────────────────────

if [ ! -f "app.json" ]; then
  error "app.json not found. Run this script from the project root."
fi

# Warn if there are uncommitted changes (but do not block)
if ! git diff --quiet || ! git diff --cached --quiet; then
  warn "Uncommitted changes detected. Commit or stash them before releasing."
fi

# ── 3. Derive build numbers ──────────────────────────────────────────────────

# iOS build number: MAJOR * 10000 + MINOR * 100 + PATCH  (e.g. 1.2.0 → 10200)
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
PATCH=$(echo "$VERSION" | cut -d. -f3)

IOS_BUILD_NUMBER=$(( MAJOR * 10000 + MINOR * 100 + PATCH ))
ANDROID_VERSION_CODE=$IOS_BUILD_NUMBER

info "Version:             ${VERSION}"
info "iOS buildNumber:     ${IOS_BUILD_NUMBER}"
info "Android versionCode: ${ANDROID_VERSION_CODE}"
echo ""

# ── 4. Update app.json ───────────────────────────────────────────────────────

info "Updating app.json..."

# Requires node — used for reliable JSON editing without external tools
node - <<EOF
const fs = require('fs');
const path = 'app.json';

let raw;
try {
  raw = fs.readFileSync(path, 'utf8');
} catch (e) {
  console.error('Failed to read app.json: ' + e.message);
  process.exit(1);
}

let config;
try {
  config = JSON.parse(raw);
} catch (e) {
  console.error('Failed to parse app.json: ' + e.message);
  process.exit(1);
}

const expo = config.expo || config;

expo.version = '${VERSION}';

if (!expo.ios) expo.ios = {};
expo.ios.buildNumber = '${IOS_BUILD_NUMBER}';

if (!expo.android) expo.android = {};
expo.android.versionCode = ${ANDROID_VERSION_CODE};

fs.writeFileSync(path, JSON.stringify(config, null, 2) + '\n');
console.log('app.json updated.');
EOF

success "app.json updated."

# ── 5. Commit the version bump ───────────────────────────────────────────────

info "Staging app.json and creating commit..."

git add app.json
git commit -m "chore: bump version to ${TAG}"

success "Commit created: chore: bump version to ${TAG}"

# ── 6. Create the git tag ────────────────────────────────────────────────────

if git rev-parse "$TAG" > /dev/null 2>&1; then
  error "Tag '${TAG}' already exists. Delete it first with: git tag -d ${TAG}"
fi

git tag -a "$TAG" -m "Release ${TAG}"
success "Tag created: ${TAG}"

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}${BOLD}✅ Release ${TAG} prepared!${RESET}"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review the commit:    ${BOLD}git show HEAD${RESET}"
echo "  2. Push the branch:      ${BOLD}git push origin \$(git branch --show-current)${RESET}"
echo "  3. Open the release PR targeting main."
echo "  4. After merging to main, push the tag:"
echo "                           ${BOLD}git push origin ${TAG}${RESET}"
echo ""
