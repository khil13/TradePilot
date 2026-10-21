#!/usr/bin/env bash
# Install and launch HKUDS/Vibe-Trading's MCP server for trader-vibe.
#
#   vibe.sh install     # venv + pinned vibe-trading-ai (once, several minutes)
#   vibe.sh mcp         # stdio MCP server; .mcp.json runs this
#
# The MCP surface is read-only by design: no order-placing tool is exposed.
set -euo pipefail

VT_VERSION="0.1.16"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${TRADER_ROOT:-$(cd "$HERE/../../.." && pwd)}"
VENV="${VIBE_TRADING_VENV:-$ROOT/.venv-vibe-trading}"

die() { echo "trader-vibe: $*" >&2; exit 1; }

case "${1:-}" in
  install)
    py="$(command -v python3.13 || command -v python3.12 || command -v python3.11 || command -v python3)"
    "$py" -c 'import sys; sys.exit(sys.version_info < (3, 11))' \
      || die "Vibe-Trading needs Python 3.11 or newer ($py is too old)"
    [ -x "$VENV/bin/python" ] || "$py" -m venv "$VENV"
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q "vibe-trading-ai==$VT_VERSION"
    echo "installed vibe-trading-ai $VT_VERSION into $VENV; restart Claude Code to load the MCP server"
    ;;
  mcp)
    [ -x "$VENV/bin/vibe-trading-mcp" ] \
      || die "not installed; run: bash .claude/skills/trader-vibe/vibe.sh install"
    # Backtest code and written files stay inside trader/vibe/.
    mkdir -p "$ROOT/trader/vibe"
    export VIBE_TRADING_ALLOWED_RUN_ROOTS="${VIBE_TRADING_ALLOWED_RUN_ROOTS:-$ROOT/trader/vibe}"
    # Some bundled loaders (tushare) print notices to stdout, which would
    # corrupt the JSON-RPC stream; pass through only JSON lines.
    "$VENV/bin/vibe-trading-mcp" | grep --line-buffered '^{'
    ;;
  *) sed -n 2,7p "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
