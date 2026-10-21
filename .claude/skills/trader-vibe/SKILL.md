---
name: trader-vibe
description: >-
  Quant Lab. Uses HKUDS/Vibe-Trading's read-only MCP server (the
  mcp__vibe-trading__* tools) for what the rest of the pack does not do:
  backtest a strategy over years of daily bars with full metrics, technical
  indicators and pattern engines (candlestick, SMC/ICT, Ichimoku, Elliott,
  harmonic), US options chains with Greeks and payoff analysis, VaR and
  drawdown math, and a diagnosis of your own trade journal. Also loads any of
  its 90 methodology skills on demand. Never places an order. Use when the
  user says "backtest this strategy", "does RSI mean reversion work on
  SPY", "what patterns are on the TSLA chart", "options chain", "payoff of
  this spread", "Greeks", "analyze my trade journal", "what am I doing
  wrong", "set up Vibe-Trading", or wants a method the pack lacks.
argument-hint: "[what to research]"
---

# trader-vibe

[Vibe-Trading](https://github.com/HKUDS/Vibe-Trading) (MIT, `vibe-trading-ai`
pinned to 0.1.16) ships an MCP server with 74 research tools. This repo's
`.mcp.json` starts it as `vibe-trading`, so its tools appear as
`mcp__vibe-trading__<tool>`. The rest of this pack stays the trade pipeline;
this skill is the lab you use around it.

`${CLAUDE_SKILL_DIR}` below is this skill's folder (where this SKILL.md lives).

## Setup (once)

```bash
bash "${CLAUDE_SKILL_DIR}/vibe.sh" install   # .venv-vibe-trading/, Python 3.11+, several minutes
```

Then restart Claude Code and approve the `vibe-trading` server from
`.mcp.json` when asked. If its tools are missing, check `/mcp`; the usual
cause is the install not having run. No API key is needed for the tools
below. Backtest code and written files are confined to `trader/vibe/`.

## Which tool for which job

| Job | Tool(s) |
| --- | --- |
| Backtest a rule on daily bars (years, not one session) | `backtest`; then `read_run_artifact` / `get_run_result` |
| Why a backtest looks wrong | `load_skill("backtest-diagnose")` |
| Indicators and chart patterns | `technical_indicators`, `pattern_recognition` |
| Options chain, Greeks, payoff, breakevens | `get_options_chain`, `analyze_options`, `analyze_options_payoff` |
| VaR, drawdown, return math | `quantlib_call`, `cashflow_performance` |
| Your own trading habits | `analyze_trade_journal` on a CSV export |
| Market data, news, filings, holders | `get_market_data`, `get_stock_news`, `get_sec_filings`, `get_institutional_holdings`, `etf_holdings` |
| A method the pack lacks | `list_skills`, then `load_skill(name)` |

Methodology skills worth loading for US day trading: `minute-analysis`,
`candlestick`, `smc`, `technical-basic`, `market-microstructure`,
`execution-model`, `volatility`, `seasonal`, `risk-analysis`,
`trade-journal`, `research-discipline`, `options-payoff`. Many of its other
skills (Tushare, A-shares, northbound flow) are for Chinese markets; skip them
for US tickers.

## Where it fits

- **Before trusting a setup:** `/trader-timemachine` gives the odds for
  today's session from 60 days of 5-minute bars. `backtest` answers the
  longer question: has this rule made money over years of daily bars, after
  costs? Use both; say plainly when they disagree.
- **After trading:** point `analyze_trade_journal` at a CSV of your fills
  (export from your broker, or build one from the `/trader-broker` trade log
  under `trader/`). Report its behaviour diagnoses in plain words.
- **Data:** its quotes, like the pack's, are free and unofficial. When its
  numbers and the pack's tools differ, say so and prefer the pack's for the
  live trade (they feed `/trader-risk`).

## What it does not do

- It cannot place, cancel or change an order. Vibe-Trading refuses to expose
  any order tool over MCP; `trading_*` tools only read a connected account,
  and `paper_trade_step` only matches orders on paper. Only `/trader-broker`
  leads to an order, after `/trader-risk` and the user's yes.
- Avoid `run_swarm`, `qveris_*` and `iwencai_search` unless the user asks:
  the first needs an LLM key and runs many model calls, the others are paid
  or China-only data.
- A backtest is history, not a forecast. Say so with every result.

Not financial advice.
