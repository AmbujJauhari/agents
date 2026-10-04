---
applyTo: "**/*.java"
---

## Comments
Default: no comment. Code should explain itself through names and small methods.
Write a comment ONLY when one of these is true:
- Why, not what: a non-obvious decision, trade-off or constraint ("sequential because the vendor API rejects concurrent sessions").
- Business or regulatory rule that cannot be inferred from code, with a reference (ISDA/CSA clause, internal spec, ticket ID).
- Workaround for a bug, library quirk or upstream defect: include the cause and the condition under which it can be removed.
- Concurrency or ordering invariant: what must hold, and what breaks if it doesn't.
- Non-obvious numeric or temporal behaviour: rounding mode and scale, timezone/business-day assumptions, cut-off times.
- A deliberate deviation from these standards.
Never write:
- Restatements of the code (`// increment counter`, `// getter for id`).
- Javadoc that only repeats the signature. Javadoc is for public APIs and library-style utilities, and must add contract information: null behaviour, thrown exceptions, units, valid ranges, thread-safety.
- Commented-out code, changelogs, author tags, or "TODO" without a ticket ID.
When you change code, update or delete the comments around it. A stale comment is worse than none.

## Reuse before writing
Before writing ANY private helper that does generic work (collection chunking/partitioning, diffing, map merging, null-safe string ops, retry/backoff, hashing/encoding, CSV or JSON handling, date ranges, IO), stop and work down this order:
1. JDK standard library.
2. A dependency already on the classpath - see @.github/instructions/available-libraries.md. Zero cost to use, so always check here before hand-rolling.
3. An existing utility in this repo or a shared internal platform library (search for it; do not assume it is absent).
4. A new dependency: propose it and STOP for approval. Never add one unasked; it must exist in the approved internal artifact repository.
5. Hand-rolled: last resort only.
State which step you used. If you hand-roll, say in one line why steps 1-3 did not fit.
Never use a library for domain logic (eligibility, margin, CSA, settlement rules). Libraries are for commodity concerns only.
Example of the failure to avoid: writing a 10-line loop to split a list into batches of 500 when Guava's Lists.partition or Commons Collections' ListUtils.partition is already on the classpath.

## Correctness
- Money: BigDecimal only, never double/float. Set scale and RoundingMode explicitly; never rely on defaults. Never compare with equals(); use compareTo(). Carry an ISO 4217 currency alongside every amount and reject cross-currency arithmetic.
- Time: store and pass Instant/OffsetDateTime in UTC; convert at the edges only. Never use LocalDateTime for anything with an absolute meaning. Business-day and cut-off logic goes through the calendar service, never a hand-rolled weekend check.
- Nulls: no null returns from public methods; use Optional for "may be absent" results or an explicit empty collection. Do not use Optional for fields or parameters. Validate inputs with guard clauses at the top of the method.
- Equality: entities compare by identifier, value objects by value. Keep hashCode consistent and immutable-safe.

## Structure
- Prefer immutability: final fields, constructor injection, records or builders for value objects. No setters on domain types unless the lifecycle requires them.
- Keep methods short and single-purpose; extract when a block needs a comment to explain what it does.
- Never expose persistence entities outside the service layer; map to domain or DTO types.
- Constructor injection only, no field injection. No static mutable state.
- Follow existing patterns in the module before introducing a new one. Do not add an abstraction for a single implementation.

## Errors, transactions and concurrency
- Throw domain-specific exceptions; never swallow, never catch Exception broadly, never log-and-rethrow the same error twice.
- Exception messages must carry identifying context (IDs, state), never sensitive data.
- @Transactional on service methods only, narrowest scope possible. No remote calls, no external I/O inside a transaction. Know whether the flow needs REQUIRES_NEW and say why.
- Operations that can be retried must be idempotent. State it explicitly in the method contract.
- Document thread-safety for anything shared. Prefer stateless components and concurrent collections over synchronized blocks.
- Close resources with try-with-resources. Every outbound call gets a timeout; no unbounded waits, no unbounded queues or fetches.

## Logging and observability
- Structured logging with placeholders, never string concatenation.
- Never log account numbers, client identifiers, credentials, tokens or full payloads. Mask or reference by internal ID.
- INFO for lifecycle and business milestones, WARN for recoverable anomalies, ERROR for failures needing attention with the stack trace. DEBUG for diagnostics, never in hot loops.
- Propagate the correlation/trace ID through every call and every async hand-off.

## Configuration and data access
- No hardcoded environment values, URLs, thresholds or credentials. Use typed configuration properties with validation and sensible defaults.
- Parameterised queries only. Bound every query with pagination or an explicit limit; no unbounded SELECT * over large tables.
- Watch for N+1 access patterns; fetch what is needed in one call.
- Schema changes ship as versioned migrations that are backward compatible with the currently deployed code.
