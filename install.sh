#!/usr/bin/env bash
set -euo pipefail

REPO="Jinbro98/openclaw-personal-claw"
INSTALL_DIR="${OPENCLAW_PERSONAL_CLAW_DIR:-$HOME/.openclaw/extensions/openclaw-personal-claw}"

echo "🦞 personal-claw installer"
echo ""

# Check prerequisites
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found. Install Node.js >= 22.0.0 first."; exit 1; }
command -v openclaw >/dev/null 2>&1 || { echo "❌ OpenClaw not found. Install OpenClaw first: https://docs.openclaw.ai"; exit 1; }

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
  echo "❌ Node.js >= 22 required (found v${NODE_VERSION})"
  exit 1
fi

echo "✅ Node.js $(node -v)"
echo "✅ OpenClaw $(openclaw --version 2>/dev/null | head -1)"
echo ""

# Clone
echo "📥 Cloning to ${INSTALL_DIR}..."
if [ -d "$INSTALL_DIR" ]; then
  echo "   Directory exists, pulling latest..."
  cd "$INSTALL_DIR"
  git pull --quiet
else
  git clone --quiet "https://github.com/${REPO}.git" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# Install & build
echo "📦 Installing dependencies..."
npm install --silent

echo "🔨 Building..."
npm run build --silent

# Run tests
echo "🧪 Running tests..."
npm test --silent 2>/dev/null && echo "   ✅ All tests passed" || echo "   ⚠️  Tests had issues (continuing anyway)"

# Install plugin
echo "🔌 Registering plugin..."
openclaw plugins install "$INSTALL_DIR"

# Restart gateway
echo "🔄 Restarting gateway..."
openclaw gateway restart

echo ""
echo "✅ personal-claw installed and running!"
echo ""
echo "Commands:"
echo "  personal-claw-status  — check learning progress"
echo "  personal-claw-reset   — start fresh"
echo "  personal-claw-export  — backup profile"
echo ""
echo "Start chatting — it learns automatically."
