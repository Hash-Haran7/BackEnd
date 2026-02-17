#!/bin/bash
# Master Launch Script for Google ADK UI

# 1. Kill any existing processes on port 8000
echo "🧹 Cleaning up existing processes..."
fuser -k 8000/tcp 2>/dev/null || true
pkill -f "google.adk" 2>/dev/null || true

# 2. Get paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting ADK Web UI..."
echo "📂 Scanning directory: $PARENT_DIR"
echo "🤖 Agent: sakthi_R"

# 3. Run from PARENT directory so ADK finds 'sakthi_R' as an agent folder
cd "$PARENT_DIR"
"./sakthi_R/.venv/bin/adk" web .
