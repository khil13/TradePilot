---
name: trader-agents
description: >-
  Trading Desk. Runs TauricResearch/TradingAgents, a multi-agent LLM
  research desk: market, sentiment, news and fundamentals analysts work in
  parallel, bull and bear researchers debate their reports, a trader drafts
  a plan, a risk team argues it, and a portfolio manager gives one rating
  (Buy / Overweight / Hold / Underweight / Sell) with its reasoning. Saves
  the full report (Markdown plus one HTML page) under trader/agents/. Also
  backtests that desk over a grid of tickers and dates. A second opinion
  before a trade, never an order. Use when the user says "what do the agents
  think", "run TradingAgents", "get a second opinion on TSLA", "bull and
  bear case", "deep dive on NVDA", "should I hold this", "run the trading
  desk", or "backtest the agents".
argument-hint: "[ticker] [date]"
---

# trader-agents

The rest of this pack is arithmetic on public data. This skill is the
opposite: it hands a ticker to a desk of LLM agents
([TradingAgents](https://github.com/TauricResearch/TradingAgents), Apache-2.0,
pinned to v0.7.0) and brings back their argued-out view. Use it as a second
opinion next to the scanner, news and analyst, never as a trigger.

`${CLAUDE_SKILL_DIR}` below is this skill's folder (where this SKILL.md lives).

```bash
bash "${CLAUDE_SKILL_DIR}/run.sh" install                          # once: .venv-tradingagents/
bash "${CLAUDE_SKILL_DIR}/run.sh" analyze TSLA                     # today, all four analysts
bash "${CLAUDE_SKILL_DIR}/run.sh" analyze TSLA 2026-10-19 market,news
bash "${CLAUDE_SKILL_DIR}/run.sh" backtest TSLA,NVDA 2026-06-01 2026-09-01 7
```

Run it from the project root. It needs Python 3.11+ (unlike the rest of
the pack) and network access to PyPI and GitHub for the install.

## Before the first run

1. **An LLM key.** Default is Claude on both tiers: `ANTHROPIC_API_KEY`,
   analysts on `claude-sonnet-5-5`, managers on `claude-opus-5-5`. Any other
   provider works through TradingAgents' own variables, e.g.
   `TRADINGAGENTS_LLM_PROVIDER=openai` with `OPENAI_API_KEY`,
   `TRADINGAGENTS_QUICK_THINK_LLM` and `TRADINGAGENTS_DEEP_THINK_LLM`. Keys live
   in the environment or a git-ignored `.env`, never in the chat. Never ask
   the user to paste a key.
2. **Cost.** One analysis is dozens of LLM calls (four analysts, a debate,
   a risk round, two managers). Debate and risk rounds default to 1 to keep
   it cheap; say so before raising `TRADINGAGENTS_MAX_DEBATE_ROUNDS`. A
   backtest is one full analysis per ticker per date: count the cells and tell
   the user before running one.
3. **Time.** A run takes minutes, not seconds. Run it in the background and
   keep working.
4. **SEC.** `SEC_USER_AGENT` from the rest of the pack is passed on as
   `SEC_EDGAR_USER_AGENT`.

## Reading the result

The report folder under `trader/agents/` has each analyst's report, the
bull/bear debate, the trader's plan, the risk debate and the portfolio
manager's final decision, plus `complete_report.html`. Summarise for the user:

- The **rating** and the one-paragraph reason the portfolio manager gave.
- The strongest bull point and the strongest bear point, one line each.
- Anything that conflicts with what the pack's own tools found (a headline
  `/trader-news` flagged that the desk missed, an earnings date
  `/trader-analyst` shows inside the trade, a price level off from the
  scanner's). Say which source to trust: the pack's numbers come straight
  from the data; the desk's prose comes from a model.
- The path to `complete_report.html`.

## Where it fits

```
scanner -> news -> [agents: second opinion] -> entry -> exit -> timemachine -> budget -> risk -> broker
```

TradingAgents' horizon is days to weeks, not one session. For a day trade its
rating is context, not a signal: an intraday entry still comes from
`/trader-entry`, the plan from `/trader-exit`, the odds from
`/trader-timemachine`. A Sell from the desk is a good reason to skip a long
day trade; a Buy is not a reason to take one.

## What it does not do

- It never places, sizes or approves an order. Its "trader" and "portfolio
  manager" are LLM roles writing a report, not connected to any broker. Only
  `/trader-broker` leads to an order, after `/trader-risk` and the user's yes.
- It does not pass your positions to the desk unless the user asks. If they
  do, write a portfolio JSON (`{"cash": ..., "currency": "USD", "positions":
  [{"ticker", "quantity", "average_price"}]}`) under `trader/` and run the
  installed CLI with `--portfolio`.
- TradingAgents keeps its own memory log and cache in `~/.tradingagents/`;
  each run settles past decisions and reflects on them.

Not financial advice. TradingAgents' authors describe it as a research
framework; LLM output varies run to run and can be confidently wrong.
