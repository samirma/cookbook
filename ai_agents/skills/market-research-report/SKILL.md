---
name: market-research-report
description: >
  Research any tradable asset — cryptocurrency, stock, ETF, index, commodity, FX pair, or
  anything else with a quoted price — and return a source-cited, self-verified JSON market
  report with probability-weighted price predictions over a caller-supplied list of
  prediction horizons, expressed however the caller likes so long as each resolves to a
  future UTC instant. Research areas may be supplied by the caller, or left to the skill to
  derive a reasonable set for that asset class. Use when asked to research, analyse, or
  forecast an asset's price movement, or to produce market report data. Returns the JSON
  only — it does not write files, does not render HTML, and depends on no other skill.
---

# Market Research Report

Research **one asset** over **one ordered list of prediction horizons** and return a single
JSON object conforming to `assets/market_report.schema.json` (schema_version "2"). The
schema is authoritative; every object sets `additionalProperties: false`, so an invented
field is invalid.

The report is informational only, not financial advice.

## Inputs

1. **Asset** *(required)* — anything with a quoted price. Supplied as `name`, `symbol`,
   `asset_class` (`crypto` | `equity` | `etf` | `equity_index` | `commodity` | `fx` |
   `rates` | `other`), `quote_currency`, `price_unit`.

2. **Timeframes** *(required)* — an ordered list of prediction horizons. **Accept any
   phrasing that resolves to a single future UTC instant** — these are illustrations, not a
   closed list:
   - `next 5 hours`, `next 30 minutes`, `next 3 days`, `end of this week`
   - `next Wednesday at 11:00 UTC`, `Friday close`
   - `2026-08-20 14:00 UTC`, `2026-09-01`, `2026-09-01T09:30-04:00`

   If an entry is genuinely unresolvable, say which entry and why rather than guessing.

3. **Research areas** *(optional)* — the topics to investigate, as **short names** (a few
   words each; the schema caps them at 80 characters). A caller may pair each name with
   guidance text — the guidance steers the research but only the **short name** goes into
   `research_areas` and findings.
   - **Caller supplies a list** → use it verbatim, same order, one `research_findings`
     entry per area. Never drop or merge an area: if one cannot be covered, still emit its
     entry, say why in its `notes`, and add a `data_quality_notes` line. Set
     `research_areas_source: "caller"` (also when you extended a partial caller list).
   - **Caller supplies nothing** → derive a reasonable set for the asset class and set
     `research_areas_source: "derived"`.

Stop and say so if the asset or the timeframes are missing. Do not invent an asset, and do
not add, drop, or reorder horizons.

## Suggested research areas

Defaults for when the caller names none — adapt to the asset, drop what does not apply.

**Any asset** — recent high-impact events; upcoming catalysts (timing + probability);
macro backdrop (rates, inflation, growth, the dollar, credit spreads, correlation);
positioning and flows of the largest holders; sentiment (headline gauge + supporting
reads); technical structure (trend, support/resistance, volatility, liquidity).

**crypto** — protocol upgrades and forks; regulatory actions; spot-ETF flows, approvals,
listings; exchange outages and security incidents; unlock schedules and halving cycles;
on-chain whale transfers, exchange reserves, miner and long-term-holder behaviour; funding
rates, open interest, liquidations; Crypto Fear & Greed.

**equity / etf** — earnings dates, results, guidance; analyst revisions; short interest;
lockups, splits, dividends, offerings; index inclusion; sector-relative performance; 13F
filings, insider transactions, buybacks; for an ETF also its underlying, tracking
difference and premium/discount.

**equity_index** — central-bank decisions and macro prints; heavyweight earnings; index
rebalances; quad witching and option expiry; Treasury auctions and fiscal deadlines; CFTC
Commitment of Traders positioning; ETF creations/redemptions; dealer gamma; CNN Fear &
Greed, VIX term structure, put/call, breadth.

**commodity / fx / rates** — inventories, quotas, weather (commodity); rate differentials,
intervention risk, carry (fx); auctions, curve shape, issuance (rates); CFTC positioning
and implied volatility for sentiment.

## Research method

Use whatever web search and fetch tools this host provides, and check what works before
relying on it. Prefer directly accessed primary sources over search-result summaries. Log
every failed attempt in `sources.access_failed` with its UTC time and reason. **Never
fabricate a source, a price, or a retrieval time.**

Regardless of the research areas, always establish:

- **Current level** — price from a primary source *and* an independent cross-check on a
  different provider and hostname, both retrieved within 15 minutes of generation. If no
  second vendor quotes the same instrument, cross-check a tracking ETF or front-month
  future, set `price_cross_check_instrument` and `price_cross_check_is_proxy: true`, and
  explain the basis in `data_quality_notes`.
- **Market status** — `open`, `closed`, `pre_market` or `after_hours` right now. When not
  open, set `last_close_utc` and `next_open_utc` (the schema enforces this), and use the
  last session close as `price_observed_at_utc`. Never present a stale close as a live
  tick.
- **Price action** — a short and a long window, each named in its `window_label`, each with
  the likely reasons for the movement.

Fill one `research_findings` entry per area, in order: `summary`, discrete `observations`,
citations; numeric or dated readings go in `data_points`. When a sentiment area yields a
headline gauge, also fill the top-level `sentiment_index` with its scale declared
explicitly.

Every finding, observation and prediction must cite URLs listed in
`sources.successfully_accessed`. Include only claims the accessed source directly supports.
Distinguish observed facts, probability assessments and assumptions; state uncertainty
instead of inferring past it.

## Predictions and confidence

For each timeframe, in order, give a probability-weighted prediction:

- `timeframe_id` — lowercase the entry, replace each run of non-alphanumeric characters
  with `_`, trim leading and trailing `_`.
- `timeframe_label` — the entry text exactly, optionally plus one parenthesized annotation.
- `horizon_end_utc` — the resolved UTC cutoff, after `generated_at_utc`. Ambiguous entries
  take the **nearest future occurrence**; date-only entries take 23:59:59 UTC; market
  moments ("Friday close") take that venue's actual session boundary; non-UTC offsets are
  converted. Record every judgement call in `notes`.
- **`baseline_price`** — the price the move is measured FROM: normally
  `metadata.asset_price`; the last regular-session close when the market is closed; any
  other baseline must be explained in `notes`. `predicted_move_pct` means
  `((price at horizon) − baseline_price) / baseline_price × 100`, resolved at the last
  available print if the venue is closed at the horizon.
- Scenarios: each states one numeric `expected_move_pct`; probabilities total 100 (within
  0.5); `predicted_move_pct` equals the probability-weighted mean within **0.05
  percentage points and with the same sign**; any `range_pct` has `min ≤ predicted ≤ max`.
- Confidence: each timeframe is scored 0–100 against a fixed rubric — evidence freshness,
  agreement between independent sources, research-area coverage, and horizon ambiguity —
  by the **confidence critic**, never by the agent that built the prediction (see Agent
  workflow below). Scores below 60 trigger the improvement loop. **Never inflate a score
  to exceed 60** — an honest low score with the gap described is correct; a padded 60 is
  not. When nothing is below 60, set `triggered: false` and state the basis in `notes`.

## Agent workflow — the gauntlet

When the host can spawn subagents, run the work as a gauntlet: split it into judgeable
pieces, give every judgement a concrete bar, never let a builder grade its own work, and
keep builder and critic in separate, fresh contexts.

1. **Plan the research.** One planner agent maps every research area against every
   timeframe and writes the evidence plan: what must be known, per area, for each horizon.
   A 5-hour horizon needs the intraday tape and imminent catalysts; a multi-day horizon
   needs the event calendar through its cutoff.
2. **Fan out researchers.** One researcher per area executes its slice of the plan and
   returns findings with citations. Researchers run in parallel and do not see each
   other's conclusions.
3. **Reason to predictions.** A single reasoning agent — the builder — takes the assembled
   evidence dossier and produces every prediction: baseline, scenarios, weighted
   arithmetic, one per timeframe, in order. **It does not score its own confidence.**
4. **Blind confidence critic.** A fresh-context critic receives only the evidence dossier
   and the draft predictions — none of the reasoner's deliberation or justifications. It
   scores each timeframe 0–100 against the rubric, asking: *would this prediction survive
   an independent audit on this evidence alone?* Its first-pass scores are recorded
   verbatim as `confidence_protocol.initial_confidence_scores`.
5. **The gate.** Every score ≥ 60 → go to assembly. Any score < 60 → set
   `triggered: true`; the critic must name the **single biggest evidence gap** per weak
   timeframe — a named, fetchable thing ("no second source for the ETF flow figure",
   "funding data is 3 days stale"), never "research more".
6. **Improvement plan → execution.** A fresh planner turns the named gaps into concrete
   retrieval steps; executor agents carry them out; every executed step is recorded in
   `plan_executed`.
7. **Loop.** The reasoning agent re-evaluates its predictions with the new evidence, and a
   **fresh critic instance** re-scores. At most **2 improvement rounds**; after that,
   deliver with the scores as they honestly stand and the unresolved gaps described in the
   prediction `notes` and `data_quality_notes`. The critic owns the scores — the reasoner
   can never raise one, and nobody rounds a 58 up to pass the gate. The loop exists to
   improve the *evidence*, not the number.
8. **Assemble and verify.** One assembler agent builds the final JSON from the pieces and
   runs the entire **Verify before returning** section below on the assembled result — the
   smoothing pass. Never concatenate fragments from parallel agents into the output
   without this final single-point verification.

**Single-agent fallback.** If the host cannot spawn subagents, play the roles in sequence
while keeping their discipline: plan before researching; research before reasoning; write
the confidence critique from the evidence alone, before re-reading your own prediction
rationale; and score before you argue with the score.

## Verify before returning — mandatory

The assembler agent — or the single agent in fallback mode — must run these checks on the
final result before it is returned. Do this even under time pressure; a report that fails
them must be fixed, not returned.

1. **Recompute the arithmetic** for every prediction, from the actual numbers in your
   draft: scenario probabilities sum to 100 ± 0.5; `Σ(probability × move) / 100` matches
   `predicted_move_pct` within 0.05pp **and in sign** — if they disagree, the weighted mean
   wins: recompute `predicted_move_pct` from the scenarios, never adjust a scenario to
   rescue a headline number; `range_pct.min ≤ predicted_move_pct ≤ range_pct.max`.
2. **Check the correspondences**: `predictions[i]` ↔ `request.timeframes[i]` (slug match,
   same order); `research_findings[i].area` == `request.research_areas[i]` (same order);
   every cited URL present in `sources.successfully_accessed`.
3. **Check the invariants**: `executive_summary.asset_price` == `metadata.asset_price`;
   `report_date_utc` matches the date of `generated_at_utc`; every timestamp has an
   explicit zero UTC offset; `horizon_end_utc` after `generated_at_utc`;
   `metadata.schema_version` is `"2"`.
4. **Validate against the schema** when Python is available, without writing any file:

   ```bash
   python3 -c "import json,sys,jsonschema; jsonschema.validate(json.loads(sys.stdin.read()), json.load(open('SCHEMA_PATH')))" <<'JSON'
   { ...your draft... }
   JSON
   ```

   where `SCHEMA_PATH` is this skill's `assets/market_report.schema.json`. Fix every
   reported error and re-validate — up to 3 rounds. If it still fails, return the error
   list instead of a non-conforming object.

## Output

Return the JSON object itself — no file writes, no HTML, no commentary wrapped around it.
Echo the inputs verbatim into `metadata.request` so the document is self-describing.
Percentages are plain numbers (`1.5` = +1.5%); prices are in the asset's `quote_currency`,
or plain points for an index.
