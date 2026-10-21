#!/usr/bin/env bash
# Install and run TauricResearch/TradingAgents for trader-agents.
#
#   run.sh install                         # venv + pinned TradingAgents (once)
#   run.sh analyze TSLA [YYYY-MM-DD] [analysts]
#   run.sh backtest TSLA,NVDA START END [every_n_days]
#
# Reports land in trader/agents/. Never places an order.
set -euo pipefail

TA_REPO="https://github.com/TauricResearch/TradingAgents.git"
TA_COMMIT="e8f5503e9b86d5c2710b0c76b1f686703968c9df"   # v0.7.0

ROOT="${TRADER_ROOT:-$PWD}"
VENV="${TRADINGAGENTS_VENV:-$ROOT/.venv-tradingagents}"
OUT="$ROOT/trader/agents"

die() { echo "trader-agents: $*" >&2; exit 1; }

install() {
  local py
  py="$(command -v python3.13 || command -v python3.12 || command -v python3.11 || command -v python3)"
  "$py" -c 'import sys; sys.exit(sys.version_info < (3, 11))' \
    || die "TradingAgents needs Python 3.11 or newer ($py is too old)"
  [ -x "$VENV/bin/python" ] || "$py" -m venv "$VENV"
  "$VENV/bin/pip" install -q --upgrade pip
  "$VENV/bin/pip" install -q "git+$TA_REPO@$TA_COMMIT"
  echo "installed TradingAgents @ ${TA_COMMIT:0:7} into $VENV"
}

need_install() {
  [ -x "$VENV/bin/tradingagents" ] || die "not installed; run: $0 install"
}

# Defaults: Claude on both tiers, one debate round, English, no update pings.
# Any TRADINGAGENTS_* already set in the environment wins.
set_defaults() {
  export TRADINGAGENTS_LLM_PROVIDER="${TRADINGAGENTS_LLM_PROVIDER:-anthropic}"
  if [ "$TRADINGAGENTS_LLM_PROVIDER" = anthropic ]; then
    [ -n "${ANTHROPIC_API_KEY:-}" ] || die "set ANTHROPIC_API_KEY (or pick another TRADINGAGENTS_LLM_PROVIDER)"
    export TRADINGAGENTS_QUICK_THINK_LLM="${TRADINGAGENTS_QUICK_THINK_LLM:-claude-sonnet-5-5}"
    export TRADINGAGENTS_DEEP_THINK_LLM="${TRADINGAGENTS_DEEP_THINK_LLM:-claude-opus-5-5}"
  fi
  export TRADINGAGENTS_OUTPUT_LANGUAGE="${TRADINGAGENTS_OUTPUT_LANGUAGE:-English}"
  export TRADINGAGENTS_MAX_DEBATE_ROUNDS="${TRADINGAGENTS_MAX_DEBATE_ROUNDS:-1}"
  export TRADINGAGENTS_MAX_RISK_ROUNDS="${TRADINGAGENTS_MAX_RISK_ROUNDS:-1}"
  export TRADINGAGENTS_RESULTS_DIR="${TRADINGAGENTS_RESULTS_DIR:-$OUT}"
  export TRADINGAGENTS_NO_UPDATE_CHECK=1
  # Reuse the pack's SEC contact for TradingAgents' EDGAR calls.
  if [ -z "${SEC_EDGAR_USER_AGENT:-}" ] && [ -n "${SEC_USER_AGENT:-}" ]; then
    export SEC_EDGAR_USER_AGENT="$SEC_USER_AGENT"
  fi
  mkdir -p "$OUT"
}

cmd="${1:-}"; shift || true
case "$cmd" in
  install) install ;;
  analyze)
    need_install; set_defaults
    ticker="${1:?usage: $0 analyze TICKER [YYYY-MM-DD] [analysts]}"
    date="${2:-$(TZ=America/New_York date +%F)}"
    analysts="${3:-market,sentiment,news,fundamentals}"
    "$VENV/bin/tradingagents" --ticker "$ticker" --date "$date" \
      --analysts "$analysts" --save --no-show --html </dev/null
    echo "reports: $OUT"
    ;;
  backtest)
    need_install; set_defaults
    [ $# -ge 3 ] || die "usage: $0 backtest TICKERS START END [every_n_days]"
    "$VENV/bin/tradingagents" backtest "$1" --start "$2" --end "$3" --every "${4:-7}" </dev/null
    ;;
  *) sed -n 2,8p "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
