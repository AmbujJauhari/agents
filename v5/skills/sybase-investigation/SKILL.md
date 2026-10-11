---
name: sybase-investigation
description: Method for investigating data in the legacy Sybase ASE databases - establishing schema and join keys before querying, hypothesis-driven iteration, catching join fan-out, and interpreting status and amount columns. Use when answering a data question that needs more than a single-table lookup.
argument-hint: the data question to investigate
user-invocable: true
---

# Investigating Sybase data

Read `reference/schema-map.md` first. It is the difference between a correct join and a plausible-looking wrong one. Do not infer join keys from column names.

## Method

**1. Establish the ground truth before querying for an answer.**
- `sp_help <table>` for the tables involved; `sp_helptext <proc>` where logic lives in a proc.
- Confirm join keys from `reference/schema-map.md`, then from indexes and FK metadata. Names lie in legacy schemas: two `trade_id` columns may not be the same key, and the real join may need a second column (book, cob date, source system).
- Check `reference/status-codes.md` before filtering on any status or type column. A wrong status filter produces a confident empty result.

**2. Count before you select.**
Start with `SELECT COUNT(*)` under the filter you intend. If the count is zero, the filter is wrong more often than the data is absent. If it is huge, narrow before fetching rows.

**3. One query, one hypothesis.**
State the hypothesis, run the query that would falsify it, record whether it held. Do not batch unrelated questions into one wide query - you cannot tell which part was wrong.

**4. Verify every join.**
Compare row counts before and after joining. More rows means fan-out (a one-to-many you did not expect); fewer means rows dropped (inner join hiding nulls, or a key mismatch). Either invalidates an aggregate. Say in your output that you checked.

**5. Read the code when values need interpreting.**
Entity mappings, DAO SQL and enum classes explain what a column means far better than guessing. Use them before asserting business meaning.

## Query discipline

- Explicit columns, never `SELECT *`. Cap with `SET ROWCOUNT 50` unless aggregating.
- Filter on indexed columns; check `showplan` before a query over a large table.
- Date and cob-date columns: confirm whether the column is a business date or a system timestamp before comparing. Mixing them silently drops rows.
- Amounts: confirm scale and the currency column before summing. Never sum across currencies.
- `reference/query-patterns.sql` has known-good starting points - prefer adapting one over writing from scratch.

## Reporting

- Key finding first, then the 2-4 decisive queries as evidence.
- State confidence and what you could not verify. An investigation with an unverified assumption is incomplete, not finished.
- Mask account numbers and personal data.
- If the evidence is ambiguous, say so and name the next query. Do not resolve ambiguity by picking the likelier story.
