# CI failure triage

ORG-WIDE failure signatures only - things that look the same in every repo
because the runners, the artifact repository and the container setup are shared.

Repo-specific facts do NOT belong here. The pipeline's stages, which jobs gate a
merge, expected duration, and which tests are known flaky all live in that repo's
`repo-map.md` (CI section). Read both: this file to classify the failure, the
repo map to know what is normal for that pipeline.

Fill in the real log signatures as you meet them. Each row earns its place by
having been seen at least once.

---

## 1. Infrastructure - not a code problem
Report and stop. Do not investigate the diff.

| Log signature | Meaning | Confirm by | Action |
|---|---|---|---|
| `no matching runner` / job stuck Pending | no runner with the required tag is available | check other pipelines are also stalled | report; platform owns runners |
| `no space left on device` | runner disk full | same job failing across repos | report to platform |
| `ImagePullBackOff` / `manifest unknown` | the job image is missing or the tag was moved | check the image reference in .gitlab-ci.yml | report; may need a pipeline change |

## 2. Dependency resolution - usually an ordering problem
| Log signature | Meaning | Confirm by | Action |
|---|---|---|---|
| `Could not resolve dependencies` / `Could not transfer artifact` | internal artifact repository unreachable, or the version is not published yet | is the missing version a SNAPSHOT from a sibling MR? | if a dependent MR must merge first, say which |
| `401 Unauthorized` from the artifact repository | CI credential expired or rotated | other repos failing the same way | report to platform |
| `Could not find artifact ...:X.Y.Z` where X.Y.Z is a sibling service | release ordering | check that service's pipeline | merge order, not a code fix |

## 3. Test environment and containers
Distinguish "the container never started" from "it started and a test failed".
The first is environment, the second is your code.

| Log signature | Meaning | Confirm by | Action |
|---|---|---|---|
| `Could not start container` / Testcontainers timeout | docker unavailable or image pull failed inside the job | did any test actually execute? | environment - report |
| `port is already allocated` | parallel jobs colliding on a fixed port | does the test hardcode a port? | real defect: the test should use a random port |
| `Connection refused` to a service container | container started but was not ready | is there a wait strategy / health check? | real defect: missing readiness wait |
| Missing environment variable or secret | pipeline variable not set for this branch or environment | compare against a passing pipeline | pipeline config, not code |

## 4. Auth and credentials
| Log signature | Meaning | Confirm by | Action |
|---|---|---|---|
| token acquisition failure at job start | CI identity misconfigured for this project | has this job ever passed on this branch? | report to platform |
| 403 on a resource that worked before | role assignment or scope changed | check when it last passed | report; do not retry |
| Started failing on a date with no code change | a secret or certificate expired | `git log` shows no relevant commit | expiry, not a regression |

## 5. Flaky
A test is flaky only if the repo's `repo-map.md` says so, or you can show the
same job passing on a recent unrelated pipeline. Suspicion is not evidence.

Signals: passes on re-run with no code change; fails only in parallel; depends on
wall-clock time, ordering, or shared state.

**Never retry to make a pipeline green.** Report it as flaky, name the test, and
say it should be fixed or quarantined. A retry hides the next real failure too.

## 6. Genuine failure
An assertion or compile error traceable to the diff. The only class where the fix
is in the code. Report the test, the assertion, and the first stack frame in
project code (file:line).

---

## Escalation
Fill in who owns what, so a report has somewhere to go.

| Area | Owner |
|---|---|
| Runners, artifact repository | |
| Shared test environments | |
| CI identities and secrets | |
