---
applyTo: "**/*Controller.java,**/*Resource.java,**/controller/**/*.java,**/api/**/*.java,**/dto/**/*.java,**/openapi/**/*.yaml,**/openapi/**/*.yml"
---

## Contract first
- Design the contract before the implementation: resources and nouns, not verbs (`/margin-calls/{id}/disputes`, not `/getMarginCall`).
- Keep the OpenAPI spec in the same change as the code. A contract change without a spec change is incomplete.
- DTOs are separate from entities and from each other: request and response types are distinct, and no persistence annotations on them.
- Field names in a stable convention; explicit units and currency in the name or the schema (`notionalAmount` + `currency`, `timeoutSeconds`).

## Compatibility
- Additive changes only within a version: new optional fields, new endpoints. Never rename, remove, retype or tighten a field, and never change the meaning of an existing value.
- New enum values are a breaking change for strict consumers: document how unknown values must be handled.
- Deprecate before removal: mark it in the spec, announce it, and keep it for the agreed window.
- Version in the path (`/v1/`) for breaking changes. Versioning is a last resort, not a default.

## Request and response rules
- Validate everything at the boundary: required fields, ranges, lengths, enum values, currency codes, date ordering. Reject unknown fields rather than ignoring them silently.
- Never trust client-supplied IDs, amounts or status values for authorisation decisions; re-check server-side.
- Amounts as decimal strings with explicit scale plus an ISO 4217 currency, never floating point. Timestamps ISO-8601 with offset, UTC.
- Distinguish absent from null and from empty; document what each means.
- Collections are always paginated (cursor preferred over offset for large or moving data), with a documented default and maximum page size. Never return an unbounded list.
- Idempotency: every non-GET state-changing endpoint accepts an idempotency key and returns the original result on replay. Document the retention window.
- Correct status codes: 200/201 with Location, 202 for accepted async work with a status resource, 400 validation, 401 vs 403, 404, 409 conflict/duplicate, 422 business rule rejection, 429 with Retry-After, 5xx only for genuine server faults.

## Errors
- One error model across all endpoints (RFC 9457 problem details or the existing house model, whichever the repo already uses).
- Every error carries a stable machine-readable code, a human-readable message, the correlation ID, and field-level details for validation failures.
- Never leak stack traces, SQL, internal hostnames, or upstream vendor errors to the client. Log the detail, return the code.
- Error codes are part of the contract: document them and don't change their meaning.

## Security and resilience
- Authorise at the resource level, not just the endpoint: verify the caller may act on this counterparty, account or agreement. Never rely on the UI having hidden the action.
- No sensitive data in URLs or query strings; no PII in logs, error messages or audit events beyond internal references.
- Enforce request size limits, rate limits and timeouts. Every outbound call has a timeout, a bounded retry policy (idempotent operations only) and a defined failure behaviour.
- Anything with money, settlement or instruction impact produces an audit record: who, what, when, before/after, correlation ID.

## Async and events
- Event payloads are contracts too: versioned schemas, additive evolution, no internal entities on the wire.
- Include an event ID, timestamp, correlation ID and a version field. Consumers must be idempotent and tolerate duplicates and out-of-order delivery.
- Document ordering guarantees, retention and the dead-letter path.

## Definition of done for an endpoint
Contract updated, validation complete, errors mapped to the standard model, idempotency handled, pagination bounded, authorisation checked at resource level, audit and correlation wired, timeouts and limits set, tests for happy path plus the rejection cases above.
