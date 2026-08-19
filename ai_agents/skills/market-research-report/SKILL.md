---
name: market-research-report
description: Research one tradable asset across relevant research areas and return a source-checked JSON report with current state and confidence-calibrated price predictions. Use for market research, asset analysis, and price forecasts. Returns JSON only and writes no files.
---

# Market Research Report

Research one asset over an ordered, nonempty list of prediction timeframes. Return one JSON object that conforms to the embedded schema.

The report is informational only and is not financial advice.

## Inputs

- `asset`: one unambiguous tradable asset.
- `timeframes`: an ordered, nonempty list of horizons. Preserve each label and its order, and resolve it to one future UTC instant.
- `research_areas` (optional): an ordered, nonempty list of short names with optional guidance. Preserve caller-supplied names and order. If omitted, derive the smallest useful set from the asset class, market structure, known price drivers, and requested horizons.

Ask for clarification if the asset is ambiguous, an input is missing, a supplied research-area list is empty, or a timeframe cannot resolve to one future instant. Never invent, drop, merge, or reorder inputs.

## Research areas

Cover every selected area with a separate finding in `state.research_areas`. Each finding states what the evidence shows now, its likely price direction, and direct source URLs. An unsupported area fails the gauntlet; do not silently omit it.

When areas are not supplied, adapt these starting points rather than treating them as a fixed checklist:

- Any asset: recent high-impact events, upcoming catalysts, macro conditions, price action, positioning and flows, sentiment, and current metrics.
- Crypto: protocol changes, regulation, ETF flows, security incidents, supply cycles, on-chain holders, exchange reserves, funding, open interest, liquidations, and fear/greed.
- Equity or ETF: earnings and guidance, valuation, analyst revisions, ownership flows, insider activity, short interest, corporate actions, sector performance, and underlying holdings for an ETF.
- Equity index: macro releases, central-bank policy, heavyweight earnings, breadth, volatility, dealer positioning, futures positioning, and index or ETF flows.
- Commodity, FX, or rates: inventories, production, quotas, or weather; rate differentials and intervention; auctions, issuance, and curve shape; positioning and implied volatility.

## External bar and hard checks

Before research, set one named, fetchable, comparable external bar: a professional analyst report or published forecast methodology appropriate to the asset class and horizons. Use a caller-supplied reference when available; otherwise the lead selects the strongest accessible one and records it in the internal dossier. Open the real artifact during this run and compare against it directly, not against a description. If no valid bar is accessible, do not claim Gauntlet completion.

The external comparison does not replace these hard checks. The report also passes only if:

- It has exactly the four top-level fields in the schema.
- It has one prediction per requested timeframe, in the same order.
- It has one finding per selected research area, in the same order.
- Every URL was opened during this run and its exact supporting passage, table, or observation was inspected in context.
- The current price is confirmed by two independent providers on different hostnames, fetched within 15 minutes of final assembly. If they differ by more than 1%, inspect a third provider and require two to agree within 1%.
- A closed-market price is identified as the latest close, never as a live price.
- Every horizon is in the future, every target is inside its range, and every event is relevant by that horizon and backed by a direct source.
- Every numeric forecast comes from a reproducible internal calculation using opened data, explicit assumptions, competing scenarios, and an asset-appropriate base rate or method.
- The final response is valid JSON with no surrounding commentary.

## Gauntlet loop

1. The lead agent splits the work into current price and state, horizon resolution, each selected research area, numerical forecast construction, and final synthesis.
2. A separate researcher builds each area from primary sources. Search snippets, inaccessible landing pages, and another agent's summary are not evidence.
3. Give every completed unit, including price and state, horizon resolution, and each research area, to its own fresh-context harsh critic. The critic independently opens the sources and returns `PASS`, or `FAIL` with the single biggest concrete gap. Route a failure back to that unit's builder, then use a new critic.
4. A prediction builder uses only the passed evidence dossier. It records internal assumptions, inputs, arithmetic, base rates, contradictory evidence, and probability-weighted scenarios. `target_price` is the scenario-weighted central result; `target_range` contains the plausible scenario outcomes.
5. A separate confidence critic, with no builder deliberation, assigns each `confidence_score` as the estimated probability that the realized price at `horizon_end_utc` falls inside `target_range`. It must reproduce the score from an internal ledger covering historical calibration or backtests when available, method validation, evidence freshness, independent leading indicators, contradictions, volatility, regime stability, event uncertainty, and horizon length. The range must remain informative relative to historical volatility; never widen it merely to inflate confidence. Lower any score the critic cannot reproduce.
6. A fresh harsh forecast critic compares the actual internal forecast packet with the external bar side by side and blind where practical. It chooses which is stronger for evidence rigor, asset-driver coverage, reproducibility, and uncertainty calibration. A tie or a win by the bar is `FAIL`; it returns the single biggest gap to the builder.
7. A separate assembler builds the JSON. A final fresh critic inspects it against the schema and all hard checks, then returns `PASS` or `FAIL` with only the single biggest concrete gap. Send that gap to the responsible builder and repeat with a new critic.
8. Keep looping with no fixed round count until every unit and the final report pass, or the user stops. If required evidence remains inaccessible after materially different retrieval paths, stop and report the blocker instead of emitting a report that appears to have passed.

Report quality and forecast confidence are separate. A supported low-confidence forecast can pass. `confidence_score` is range-coverage probability, not the probability of hitting the exact target and not a report-quality score. Current-price agreement alone does not increase it. High confidence requires asset-relevant historical calibration, multiple independent leading indicators, and stable assumptions. Never raise confidence merely to pass the quality gate.

For each event, `probability_pct` is the chance that the event occurs as described before the horizon. Use `expected_at_utc: null` only when a source gives a time window rather than an instant, and state the window in `impact_summary`. Use an empty event list when no relevant event is supported.

Research notes, failed retrievals, calculations, benchmark details, and criticism remain internal. Never fabricate a source, price, timestamp, event, or probability. The gauntlet improves research rigor and confidence calibration; it cannot guarantee that a future price prediction will be correct.

In Claude Code:

`/loop` until every critic passes.

Fan out subagents and ultracode.

## Portability

`/loop` and `ultracode` are Claude Code features. `/loop` reruns a prompt until you stop it, and `ultracode` opts a turn into multi-agent orchestration.

For any other agent, swap the last two instructions for: "Keep looping until the critic passes ours. Run the builders and critics as parallel subagents." The structure carries over unchanged.

## Output schema

This Draft 2020-12 JSON Schema is authoritative:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Market Research Report",
  "type": "object",
  "additionalProperties": false,
  "required": ["asset", "current_price", "state", "predictions"],
  "properties": {
    "asset": {
      "type": "object",
      "additionalProperties": false,
      "required": ["name", "symbol", "asset_class", "quote_currency"],
      "properties": {
        "name": { "type": "string", "minLength": 1 },
        "symbol": { "type": "string", "minLength": 1 },
        "asset_class": {
          "type": "string",
          "enum": ["crypto", "equity", "etf", "equity_index", "commodity", "fx", "rates", "other"]
        },
        "quote_currency": { "type": "string", "minLength": 1 }
      }
    },
    "current_price": {
      "type": "object",
      "additionalProperties": false,
      "required": ["value", "observed_at_utc", "source_urls"],
      "properties": {
        "value": { "type": "number", "exclusiveMinimum": 0 },
        "observed_at_utc": { "$ref": "#/$defs/utc" },
        "source_urls": {
          "type": "array",
          "minItems": 2,
          "uniqueItems": true,
          "items": { "$ref": "#/$defs/url" }
        }
      }
    },
    "state": {
      "type": "object",
      "additionalProperties": false,
      "required": ["market_status", "summary", "research_areas"],
      "properties": {
        "market_status": {
          "type": "string",
          "enum": ["open", "closed", "pre_market", "after_hours"]
        },
        "summary": { "type": "string", "minLength": 1, "maxLength": 500 },
        "research_areas": {
          "type": "array",
          "minItems": 1,
          "items": { "$ref": "#/$defs/research_area" }
        }
      }
    },
    "predictions": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["timeframe", "horizon_end_utc", "target_price", "target_range", "confidence_score", "upcoming_events"],
        "properties": {
          "timeframe": { "type": "string", "minLength": 1 },
          "horizon_end_utc": { "$ref": "#/$defs/utc" },
          "target_price": { "type": "number", "exclusiveMinimum": 0 },
          "target_range": {
            "type": "object",
            "additionalProperties": false,
            "required": ["low", "high"],
            "properties": {
              "low": { "type": "number", "exclusiveMinimum": 0 },
              "high": { "type": "number", "exclusiveMinimum": 0 }
            }
          },
          "confidence_score": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100,
            "description": "Estimated probability, in percent, that the realized price at horizon_end_utc falls within target_range."
          },
          "upcoming_events": {
            "type": "array",
            "items": { "$ref": "#/$defs/event" }
          }
        }
      }
    }
  },
  "$defs": {
    "utc": {
      "type": "string",
      "format": "date-time",
      "pattern": "Z$"
    },
    "url": {
      "type": "string",
      "format": "uri",
      "pattern": "^https?://"
    },
    "research_area": {
      "type": "object",
      "additionalProperties": false,
      "required": ["area", "summary", "impact_direction", "source_urls"],
      "properties": {
        "area": { "type": "string", "minLength": 1, "maxLength": 80 },
        "summary": { "type": "string", "minLength": 1, "maxLength": 1000 },
        "impact_direction": {
          "type": "string",
          "enum": ["positive", "negative", "mixed"]
        },
        "source_urls": {
          "type": "array",
          "minItems": 1,
          "uniqueItems": true,
          "items": { "$ref": "#/$defs/url" }
        }
      }
    },
    "event": {
      "type": "object",
      "additionalProperties": false,
      "required": ["name", "expected_at_utc", "probability_pct", "impact_direction", "impact_summary", "source_url"],
      "properties": {
        "name": { "type": "string", "minLength": 1 },
        "expected_at_utc": {
          "oneOf": [
            { "$ref": "#/$defs/utc" },
            { "type": "null" }
          ]
        },
        "probability_pct": {
          "type": "number",
          "minimum": 0,
          "maximum": 100
        },
        "impact_direction": {
          "type": "string",
          "enum": ["positive", "negative", "mixed"]
        },
        "impact_summary": { "type": "string", "minLength": 1, "maxLength": 500 },
        "source_url": { "$ref": "#/$defs/url" }
      }
    }
  }
}
```

Before returning, inspect the assembled object against every schema rule and hard check. Also verify the requested order of predictions and research areas, and `target_range.low <= target_price <= target_range.high`, because JSON Schema cannot express these cross-field checks directly.

## Output

For a completed report, return only the report object as valid JSON. Do not add a Markdown fence, preamble, explanation, or trailing commentary. Do not write the report to a file. A preflight clarification or an irreducible blocker is not a completed report; return it as concise text and do not emit report-shaped JSON.
