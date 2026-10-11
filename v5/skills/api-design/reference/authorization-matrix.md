# Authorization matrix

One row per resource-action. Fill for each new endpoint. Entitlement is
resource-level: "may call the endpoint" is not the same as "may act on THIS
counterparty's margin call".

| Resource | Action | Who may | Scoped by | Checked where | Audited? |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Data classification
| Field | Class (public/internal/PII/MNPI) | May appear in logs? | May appear in error messages? |
|---|---|---|---|
|  |  |  |  |

## Abuse check
| Scenario | Behaviour | Mitigation |
|---|---|---|
| Replayed request |  |  |
| ID enumeration |  |  |
| Another party's identifier |  |  |
| Called out of sequence |  |  |
| Concurrent duplicate calls |  |  |
