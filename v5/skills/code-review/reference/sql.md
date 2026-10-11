# SQL and migration review checklist

## Backward compatibility (the one that causes outages)
A migration must work with the code **currently deployed**, not just the code in this MR.
- Adding a `NOT NULL` column with no default breaks running inserts.
- Renaming or dropping a column or table breaks the running version. Expand, migrate, then contract in a later release.
- Narrowing a type or tightening a constraint fails on existing rows.
- New enum or status values that older code will not recognise.

## Locking and blocking
- DDL on a large table: how long does it hold a lock, and what blocks behind it?
- A data backfill in the same transaction as the schema change.
- Unbatched `UPDATE`/`DELETE` across a large table.
- Index creation on a hot table without considering the online path.

## Correctness
- Join keys verified against the schema, not inferred from column names.
- Inner join silently dropping rows where an outer join was meant.
- Aggregates after a join that fans out - row count checked before and after.
- `NULL` semantics in `WHERE`, `NOT IN` and comparisons.
- Date columns: business date vs system timestamp; inclusive vs exclusive range ends.
- Amounts summed across currencies, or scale lost on the way.

## Performance
- Filters on non-indexed columns; functions wrapped around an indexed column, defeating the index.
- `SELECT *`, or no row cap on something that can grow.
- New index: is it covered by an existing one, and what does it cost on write?

## Safety and reversibility
- Is there a tested rollback, and is it still valid once data has been written?
- Parameterised, never string-concatenated.
- Does the migration run exactly once and tolerate being retried?
- Does any script touch production data directly rather than through a reviewed migration?