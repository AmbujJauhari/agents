---
name: api-design
description: Phased process for designing a new API endpoint or event before writing any code - consumer intake, resource modelling, security artifacts, operational envelope, evolution plan, and an ADR of rejected alternatives. Produces a design document for approval, then the OpenAPI spec. Use when designing a new endpoint, resource or event schema.
argument-hint: the capability or endpoint to design
user-invocable: true
---

# Designing an API

Two-phase rule: **produce the design document, get it approved, and only then write the spec and the code.** Starting from a controller anchors the whole design to the first guess. If asked to skip to implementation, say what the risk is and ask once.

The coding rules the result must satisfy live in the API instructions file (validation, error model, pagination, idempotency, compatibility). This skill is the process that produces the design, not the rules it must obey.

## Phase 1 - Consumer intake

Do not proceed until these are answered. Ask; do not invent.
- Who calls this, and from what workflow? Name the caller.
- What do they do with the response, and what do they do when it fails?
- Is the caller internal, another desk, a vendor, or external? That decides the compatibility and auth posture.
- Expected volume, peak, and latency tolerance.
- Is this replacing something? What happens to the existing path?

List every assumption you had to make explicitly, in the document. An endpoint designed without a named caller becomes a generic query API nobody can safely change.

## Phase 2 - Resource modelling

- Model resources and state transitions, not RPC verbs. `POST /margin-calls/{id}/disputes` rather than `POST /raiseDispute`.
- Identify the state machine: what states exist, which transitions are legal, which are terminal. Most endpoint bugs are illegal-transition bugs.
- Use HTTP semantics properly - correct status codes, conditional requests where they apply, `Retry-After` on 429. "REST not RPC" is about resource modelling, not about avoiding HTTP features.
- No hypermedia links unless a named consumer will follow them.

## Phase 3 - Security artifacts

Produce these as output, not as a reassurance that security was considered. Template in `reference/authorization-matrix.md`.
- **Authorisation matrix** - per resource and action, who may act, and on whose counterparty, agreement or account. Resource-level, not endpoint-level.
- **Data classification** - every field marked public / internal / PII / MNPI. This decides logging, error messages and audit content.
- **Abuse check** - what happens if the call is replayed, enumerated (sequential IDs), called with another party's identifier, called out of sequence, or called concurrently with itself.

## Phase 4 - Operational envelope

- Sync or async? If async, what is the status resource and how does the caller learn the outcome?
- Timeout, retry policy (idempotent operations only), and backpressure behaviour.
- Partial failure: if a downstream call fails midway, what state is the resource left in, and who reconciles it?
- What is audited, and with what correlation identifier.

## Phase 5 - Evolution plan

- Which fields are optional now so they can become meaningful later.
- What a breaking change would look like for this resource, and the deprecation path.
- How unknown enum values must be handled by consumers. State it in the contract.

## Phase 6 - Alternatives and non-goals

Short ADR using `reference/adr-template.md`: what else was considered, why it was rejected, and what this design explicitly does not do. This is the part reviewers argue with, which is the point.

## Output

A design document with one section per phase, then - after approval - the OpenAPI fragment and the error codes added to `reference/error-catalogue.md`. Flag anything you could not answer rather than filling it with a plausible default.
