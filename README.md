# TradePilot

## Skills

`.claude/skills/` holds the eleven `trader-*` skills from
[Jakeschincariol/day-trader-skill](https://github.com/Jakeschincariol/day-trader-skill)
(MIT, see `.claude/skills/LICENSE-day-trader-skill`). Open this repo in Claude
Code and they're available as `/trader-scanner`, `/trader-news`,
`/trader-entry`, `/trader-exit`, `/trader-timemachine`, `/trader-budget`,
`/trader-risk`, `/trader-broker`, `/trader-alerts`, `/trader-analyst` and
`/trader-pelosi`.

`/trader-agents` wraps
[TauricResearch/TradingAgents](https://github.com/TauricResearch/TradingAgents)
(Apache-2.0, pinned to v0.7.0): a multi-agent LLM desk (analysts, a bull/bear
debate, a risk team, a portfolio manager) that gives a second-opinion rating
and report under `trader/agents/`. It never places orders. It needs Python
3.11+ and an LLM key (`ANTHROPIC_API_KEY` by default); install once with
`bash .claude/skills/trader-agents/run.sh install`.

They need Python 3.8+ (no pip installs). The SEC tools need
`SEC_USER_AGENT="Your Name you@example.com"` or `sec_user_agent` in
`trader/config.json`. Runtime state goes in `trader/`, which is git-ignored.
Paper trading is the default, and no order is placed without your explicit yes.

Not financial advice.
