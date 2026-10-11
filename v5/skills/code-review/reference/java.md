# Java / Spring review checklist

## Correctness
- **Money**: `BigDecimal` only. Explicit scale and `RoundingMode`. `compareTo` not `equals`. Currency carried alongside and checked before arithmetic.
- **Time**: `Instant`/`OffsetDateTime` in UTC; `LocalDateTime` used for anything absolute is a bug. Business-day and cut-off logic going through the calendar service, not a hand-rolled weekend check.
- **Nulls**: guard clauses at method entry; no null returns from public methods; `Optional` for results only, never fields or parameters.
- **Equality**: entities by identifier, value objects by value; `hashCode` consistent and stable under mutation.
- **Off-by-one and boundary**: inclusive vs exclusive date ranges, empty collections, single-element cases.

## Transactions and concurrency
- `@Transactional` scope as narrow as possible, on the service layer. No remote calls or external IO inside a transaction.
- Is `REQUIRES_NEW` used, and is the reason sound? Nested transaction semantics are a frequent silent bug.
- Read-modify-write without locking or optimistic version checks.
- Retryable operations that are not idempotent.
- Shared mutable state, static mutable fields, non-thread-safe collections in a singleton bean.
- `@Async` or executor work that loses the transaction, the security context, or the correlation ID.

## Data access
- N+1 access patterns; lazy collections touched in a loop.
- Unbounded queries: no pagination, no limit, `SELECT *` over a large table.
- String-concatenated SQL instead of parameters.
- Persistence entities leaking past the service layer into controllers or responses.
- Schema changes that are not backward compatible with the currently deployed code.

## Errors and resources
- Swallowed exceptions, `catch (Exception)`, log-and-rethrow duplication.
- Exception messages carrying sensitive data, or carrying no identifying context at all.
- Missing `try-with-resources`; streams, connections or clients not closed.
- Outbound calls with no timeout; unbounded retries; unbounded queues or thread pools.

## Logging and security
- Account numbers, client identifiers, credentials, tokens or full payloads in logs.
- Correlation ID not propagated through async hand-offs.
- Authorisation checked at the endpoint but not at the resource (can this caller act on *this* counterparty?).
- Hardcoded environment values, URLs, thresholds or credentials.

## Structure and tests
- Mutability where immutability was available: missing `final`, setters on domain types, field injection instead of constructor injection.
- A new abstraction with exactly one implementation.
- A new pattern where the module already had one.
- Changed behaviour with no test covering it; a test weakened or deleted to make the build pass.
- Comments that restate the code, or stale comments left beside changed code.