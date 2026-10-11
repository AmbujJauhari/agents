# Schema map

Fill this in. It is the highest-value file in the skill: a correct join key here
prevents a whole class of wrong answers.

## Core tables
| Table | What one row is | Primary key | Notes / gotchas |
|---|---|---|---|
|  |  |  |  |

## Join keys (authoritative - do not infer from column names)
| From | To | Join on | Cardinality | Gotcha |
|---|---|---|---|---|
|  |  |  |  |  |

## Date columns
| Table.column | Business date or system timestamp? | Timezone | Notes |
|---|---|---|---|
|  |  |  |  |

## Amount columns
| Table.column | Scale | Currency column | Notes |
|---|---|---|---|
|  |  |  |  |

## Tables to avoid scanning
Large or unindexed tables, and what to filter on instead.

## Deprecated / shadow tables
Tables that look right but are no longer written to.
