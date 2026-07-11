#!/bin/bash
set -e

echo "🔧 mobile-forge bootstrap"

# Check for bun
if ! command -v bun &> /dev/null; then
  echo "Installing bun..."
  curl -fsSL https://bun.sh/install | bash
fi

# Check for EAS CLI
if ! command -v eas &> /dev/null; then
  echo "Installing EAS CLI..."
  bun install -g eas-cli
fi

# Install deps
echo "Installing dependencies..."
bun install

# Run prebuild
echo "Running Expo prebuild..."
bunx expo prebuild --clean

echo "✅ Bootstrap complete. Run: bun start"
