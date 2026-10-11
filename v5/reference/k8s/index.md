# Cluster index

Router only. Read this first, then open the ONE cluster file you need.
Names in this org are opaque - nothing is inferable from them. Anything not
listed here is UNKNOWN: treat it as production.

| Context | File | Alias(es) | Env | Purpose | Criticality | Read without asking? |
|---|---|---|---|---|---|---|
| kd251131d | kd251131d.md | uat margin, collateral uat | UAT | Collateral + margin UAT; shared with ops UAT sign-off | medium - ops testing blocked if down | yes |
| kd77a4e02 | kd77a4e02.md | prod margin, collateral prod | PROD | Collateral + margin production (OTC, Repo, SBL, PB, ETD) | settlement impact - client-facing | ask first |
| ke31b9f45 | ke31b9f45.md | dev sandbox | DEV | Shared developer sandbox; redeployed nightly | none - scratch | yes |

Keep this file short. Detail belongs in the cluster file, not here.

## Decommissioned
Contexts that no longer exist, so a stale kubeconfig entry is recognised rather than queried.

| Context | Was | Gone since |
|---|---|---|
| kd19c0b88 | old UAT before the SEA migration | 2026-04 |
