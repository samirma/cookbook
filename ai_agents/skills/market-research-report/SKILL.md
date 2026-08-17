---
name: market-research-report
description: >
  Research any tradable asset — cryptocurrency, stock, ETF, index, commodity, FX pair, or
  anything else with a quoted price — and return a source-cited JSON market report with
  probability-weighted price predictions over a caller-supplied list of prediction
  horizons, expressed however the caller likes so long as each resolves to a future UTC
  instant. Research areas may be supplied by the caller, or left to the skill to derive a
  reasonable set for that asset class. Use when asked to research, analyse, or forecast an
  asset's price movement, or to produce market report data. Returns the JSON only — it does
  not write files, does not render HTML, and depends on no other skill.
---

# Market Research Report

Research **one asset** over **one ordered list of prediction horizons** and return a single
JSON object conforming to `assets/market_report.schema.json`.

The report is informational only, not financial advice.

## Inputs

1. **Asset** *(required)* — anything with a quoted price: a cryptocurrency, a listed stock,
   an ETF, an index, a commodity, an FX pair, a rates instrument. Supplied as `name`,
   `symbol`, `asset_class` (`crypto` | `equity` | `etf` | `equity_index` | `commodity` |
   `fx` | `rates` | `other`), `quote_currency`, `price_unit`.

2. **Timeframes** *(required)* — an ordered list of prediction horizons. **Accept any
   phrasing that resolves to a single future UTC instant.** The forms below are
   illustrations, not a closed list — do not reject an entry because it does not look like
   one of them:
   - `next 5 hours`, `next 30 minutes`, `next 3 days`, `end of this week`
   - `next Wednesday at 11:00 UTC`, `Friday close`
   - `2026-08-20 14:00 UTC`, `2026-09-01`, `2026-09-01T09:30-04:00`

   If an entry is genuinely unresolvable, say which entry and why rather than guessing.

3. **Research areas** *(optional)* — the topics to investigate.
   - **If the caller supplies a list**, use it as given: same wording, same order, one
     `research_findings` entry per area. Do not silently drop or merge areas. If an area
     cannot be covered, still emit its entry, say so in its `notes`, and add a
     `data_quality_notes` line. Set `research_areas_source` to `caller`.
   - **If the caller supplies nothing**, derive a reasonable set for this asset class using
     the suggestions below, and set `research_areas_source` to `derived`.
   - **If the caller supplies a partial list** and asks you to extend it, keep their entries
     first and in order, append what the asset class warrants, and set the source to
     `caller`.

   Either way, record the areas actually used in `metadata.request.research_areas`.

Stop and say so if the asset or the timeframes are missing. Do not invent an asset, and do
not add, drop, or reorder horizons.

## Suggested research areas

These are defaults to reach for when the caller names none — a starting point to adapt to
the asset, not a fixed checklist. Drop what does not apply and add what the asset warrants.

**Any asset**

- Recent high-impact events — news that measurably moved the price, and by how much
- Upcoming catalysts — scheduled or plausible events, with timing and probability
- Macro backdrop — policy rates, inflation, growth, the dollar, credit spreads,
  cross-asset correlation
- Positioning and flows — what the largest and best-informed holders are doing
- Sentiment — a headline gauge plus supporting indicators
- Technical structure — trend, key support and resistance, volatility regime, liquidity

**crypto** — protocol upgrades and forks; regulatory actions and enforcement; spot-ETF
flows, approvals and listings; exchange outages and security incidents; token unlock
schedules and halving cycles; on-chain whale transfers, exchange reserves, miner and
long-term-holder behaviour; funding rates, open interest, liquidations; Crypto Fear & Greed.

**equity / etf** — earnings dates, results and guidance; analyst revisions; short interest;
lockups, splits, dividends and offerings; index inclusion; sector-relative performance;
13F filings, insider transactions, buybacks; fund creations/redemptions and dark-pool
prints; for an ETF also its underlying, tracking difference and premium/discount.

**equity_index** — central-bank decisions and macro prints; earnings from index
heavyweights; index rebalances and additions/deletions; quad witching and option expiry;
Treasury auctions and fiscal deadlines; CFTC Commitment of Traders positioning; ETF
creations/redemptions; dealer gamma; CNN Fear & Greed, VIX term structure, put/call,
breadth.

**commodity** — inventories and storage, production quotas and outages, weather and
seasonality, freight and spreads, CFTC positioning, the dollar.

**fx** — rate differentials and central-bank guidance, intervention risk, carry, terms of
trade, positioning.

**rates** — auction results, curve shape, issuance calendar, central-bank balance sheet,
inflation expectations.

## Research method

Use whatever web search and fetch tools this host actually provides, and check what works
before relying on it. Prefer directly accessed primary sources over search-result
summaries. Log every failed attempt in `sources.access_failed` with its UTC time and
reason. **Never fabricate a source, a price, or a retrieval time.**

Regardless of the research areas, always establish:

- **Current level** — the price from a primary source *and* an independent cross-check on a
  different provider and hostname, both retrieved within 15 minutes of generation. If no
  second vendor quotes the same instrument — common for an index — cross-check against a
  tracking ETF or front-month future, set `price_cross_check_instrument` and
  `price_cross_check_is_proxy: true`, and explain the basis in `data_quality_notes`.
- **Market status** — `open`, `closed`, `pre_market` or `after_hours` right now. Anything
  other than a 24/7 venue closes: set `last_close_utc` and `next_open_utc`, and use the last
  session close as `price_observed_at_utc`. Never present a stale close as a live tick.
- **Price action** — a short window and a long window, each named in its `window_label`
  ("last hour", "last 24 hours", "final hour of the most recent session", "last full
  trading session"), each with the likely reasons for the movement.

Fill one `research_findings` entry per area, in the order of `research_areas`, each with a
`summary`, discrete `observations`, and citations. Put numeric or dated readings — a
scheduled release, an index level, a net flow — in `data_points`. When a sentiment area
yields a headline gauge, also fill the top-level `sentiment_index` with its scale declared
explicitly, so a 0–100 Fear & Greed index, a VIX level and a put/call ratio all fit.

Every finding, observation and prediction must cite URLs that appear in
`sources.successfully_accessed`. Include only claims the accessed source directly supports.
If a reading is stale, contradictory or excluded, say why in `data_quality_notes` rather
than leaning on it. Distinguish observed facts, probability assessments and assumptions;
state uncertainty instead of inferring past it.

## Predictions and confidence

For each timeframe, give a probability-weighted prediction from the research findings,
current price action, market structure, known catalysts and invalidation risks.

1. Each scenario states one numeric `expected_move_pct`. `predicted_move_pct` must equal
   `Σ(probability_pct × expected_move_pct) / 100`.
2. Scenario probabilities must total 100. Any `range_pct` needs `min <= max`.
3. Score confidence from evidence freshness, agreement between independent sources,
   coverage of the research areas, and horizon ambiguity.
4. If any initial score is below 60, set `confidence_protocol.triggered` to `true`, record
   the initial scores, identify what is missing, gather that evidence, and list the steps in
   `plan_executed`. Then reassess.
5. **Do not inflate a score to exceed 60.** An honest score below 60 with the gap described
   is a correct report; a padded 60 is not.
6. When no initial score is below 60, set `triggered` to `false` and state the basis in
   `notes`.

## Output

Return the JSON object itself. **Do not write it to a file**, do not render HTML, and do
not wrap it in commentary — persisting and presenting the result is the caller's job.

Echo the inputs verbatim into `metadata.request` so the document is self-describing.

Produce **exactly one prediction per timeframe entry, in the same order**. For each:

- `timeframe_id` — lowercase the entry, replace each run of non-alphanumeric characters
  with `_`, trim leading and trailing `_`.
- `timeframe_label` — the entry text exactly, optionally followed by one parenthesized
  annotation, e.g. `next 5 hours (to 13:19 UTC)`.
- `horizon_end_utc` — the resolved UTC cutoff, after `generated_at_utc`. Resolve each entry
  on its own terms, and record any judgement call in `notes`:
  - **Ambiguous** ("next Wednesday" when today is Wednesday) — take the **nearest future
    occurrence**.
  - **No time of day** ("2026-09-01") — take 23:59:59 UTC on that date.
  - **A market moment** ("Friday close") — take that venue's actual session boundary, and
    name the venue.
  - **A non-UTC offset** — convert to UTC.

All timestamps are ISO 8601 with an explicit zero UTC offset (`2026-08-17T08:19:38Z`).

`assets/market_report.schema.json` is authoritative. Every object sets
`additionalProperties: false`, so an invented field is invalid. Percentages are plain
numbers (`1.5` = +1.5%). Prices are in the asset's `quote_currency`, or plain points for an
index. `executive_summary.asset_price` must equal `metadata.asset_price`, and
`executive_summary.report_date_utc` must match the date of `generated_at_utc`.
