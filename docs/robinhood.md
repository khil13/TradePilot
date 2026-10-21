# Connecting Robinhood

Notes from researching Robinhood before we connect it, October 2026. Not
connected yet. The facts below come from search summaries of Robinhood's
support pages and newsroom post (sources at the end); confirm them in the app
before building on them.

## What Robinhood offers

**An official MCP server for agents.** Launched May 27, 2026, still in beta,
and rolling out gradually, so not every account has it yet.

- Endpoint: `https://agent.robinhood.com/mcp/trading` (HTTP transport),
  sign-in through Robinhood's own OAuth page.
- Claude Code setup:

  ```bash
  claude mcp add robinhood-trading --transport http https://agent.robinhood.com/mcp/trading
  ```

  then `/mcp`, pick `robinhood-trading`, and sign in.
- Claude Desktop: Settings > Connectors > Add custom connector, paste the URL.

**A dedicated agent account.** On first connect, Robinhood has you open an
"MCP account" (you need a primary individual investing account in good
standing; up to 10 self-directed individual accounts in total). It is a
second account under your own login, owned and funded by you alone, not
shared with anyone. Robinhood requires the agent's trades to happen there,
even though the agent connects through your personal login; your main
account stays out of the agent's reach for orders.

- The agent can **trade only in the MCP account**: long stock, options and
  crypto (crypto needs a separate Robinhood Crypto account tied to it).
- The agent can **read every Robinhood account**: positions, balances, order
  history.
- You can disconnect the agent at any time.

**Order types for outside agents:** market (by shares or by dollars), limit,
stop-limit, stop-market. Robinhood's built-in agent also lists take-profit /
stop-loss; the page for outside agents does not, so assume we don't have it
until the tool list says otherwise.

**Trade approvals** (Robinhood asks you to confirm each order) are **off by
default for outside agents**. Some trades may still ask for approval with the
setting off.

**No paper trading.** Robinhood has no practice account.

**Market order collars** (consumer help pages): market buys are collared up to
about 1%, sells about 5%, and an unfilled market order may be cancelled after
2 minutes.

**Avoid unofficial libraries** such as `robin_stocks` and the MCP servers built
on them: they log in with your Robinhood password and hand it to third-party
code. The official server makes them unnecessary.

## What it means for TradePilot

1. **Turn trade approvals on** in Agent Settings before the first session.
   With the pack's own gates, an order then needs four yeses:
   `/trader-risk` PASS, your typed yes in chat, Claude Code's permission
   prompt (set Robinhood's order tool to ask every time, never "always
   allow"), and Robinhood's approval.
2. **The MCP account's balance is the hard cap.** There's no paper mode, so
   fund it only with money you'd be fine losing. `/trader-risk` limits each
   trade; the balance limits everything else.
3. **Stop and target orders are the main gap.** `/trader-budget` writes one
   bracket order in Alpaca's shape (buy + stop-loss + take-profit, where one
   exit cancels the other). If Robinhood has no bracket or one-cancels-other
   order for outside agents, placing the stop and the target as two separate
   sells risks selling shares twice: the stop fills, and the target order is
   still live. Likely fix: send only the stop to the broker, and let
   `/trader-alerts` watch the target and prompt a sell. Decide once we see the
   real tool list.
4. **Prefer limit orders for entries.** Market orders fill inside the collar,
   not at the price you saw. Stops can fill past their price in a fast market
   or a gap; the pack already treats the stop price as a plan, not a
   guarantee.
5. **Privacy.** The agent can read all your accounts, so balances and
   positions Claude reads end up in the conversation history.
6. **Pattern-day-trader rule.** FINRA dropped the $25,000 minimum in June
   2026, but brokers may phase it in until October 2027. Check whether
   Robinhood still applies it to you; if so, set `"pdt_guard": true`.

## Plan

1. **Paper trade on Alpaca first.** Run the full pack on Alpaca's free paper
   account for a couple of weeks: config, limits, alerts, journal.
2. **First Robinhood session is read-only.** Fund the MCP account small, turn
   trade approvals on, connect, then list the server's tools and check which
   order types it accepts. Place nothing.
3. **Adapt the pack.** Update `/trader-broker` (Robinhood's tool names and
   ticket format) and `/trader-budget` (orders Robinhood accepts, the
   stop/target fix), and keep `/trader-risk` in front of every order.

## Sources

- [Robinhood is Now Open to Agents](https://robinhood.com/newsroom/robinhood-is-now-open-to-agents/) (Robinhood newsroom)
- [Onboarding an external agent](https://robinhood.com/us/en/support/articles/agentic-trading-overview/) (Robinhood support)
- [Trading with your agent](https://robinhood.com/us/en/support/articles/trading-with-your-agent/) (Robinhood support)
- [Robinhood Agents overview](https://robinhood.com/us/en/support/articles/robinhood-agents-overview/) (Robinhood support)
- [Setting up an agent](https://robinhood.com/us/en/support/articles/setting-up-an-agent/) (Robinhood support)
- [Buying and selling crypto](https://robinhood.com/us/en/support/articles/360001298246/) (Robinhood support, order collars)
- [Robinhood agentic trading MCP: setup, scope, and controls](https://vorplabs.com/agent-tools/robinhood-cli) (Vorp Labs)
- [Can You Paper Trade on Robinhood?](https://www.firstcard.app/learn/can-you-paper-trade-on-robinhood) (Firstcard)

Not financial advice.
