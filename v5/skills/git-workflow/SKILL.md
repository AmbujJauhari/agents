---
name: git-workflow
description: House git and GitLab conventions, CI failure triage and pipeline watching - branch, commit and merge request formats with the issue-ID rule, pipeline topology, a decision tree for diagnosing red pipelines by failure class, and how to poll a running pipeline. Use when branching, committing, raising or updating an MR, watching a pipeline, or when a pipeline or job has failed.
argument-hint: the branch, commit, MR or pipeline to work on
user-invocable: true
---

# Git workflow

## Branching, committing, raising an MR

Read `reference/git-conventions.md` before any of the three. It holds the branch,
commit and MR formats, and the rule for extracting the GitLab issue ID from the
branch name - the ID threads through all three, so do not derive it any other way
and never invent one.

Two things that file makes non-negotiable:
- No commit without an issue ID. If the branch name does not yield one, stop and ask.
- No AI or tool attribution in a commit or an MR description, anywhere.

Keep an MR description factual. The diff shows what changed; the description explains why, what was tested, and what breaks if it is wrong.

## Triaging a failed pipeline

Work in this order. Each step is cheap and rules out a class of failure.

**1. Identify the failing job, not the failing pipeline.**
`glab ci status` / `glab ci view` to find which job(s) failed and at which stage. A downstream job failing because an upstream one did is not a separate problem.

**2. Fetch only the log tail.**
Last ~80 lines first. The real error is almost always near the end, and the head of a Maven or Gradle log is noise. Only widen if the tail shows a truncated stack.

**3. Classify before diagnosing.** See `reference/ci-failure-triage.md` for the org-wide failure signatures, and the repo's `repo-map.md` (CI section) for this pipeline's stages and known-flaky tests. The classes to separate:
- **Infrastructure** - runner unavailable, disk full, image pull failure. Not a code problem; report and move on.
- **Dependency resolution** - cannot reach the internal artifact repository, or a version not yet published. Check whether a dependent MR needs merging first.
- **Container / test environment** - Testcontainers or a service container failing to start, port conflicts, missing env. Distinguish "could not start" from "started and the test failed".
- **Flaky** - timing, ordering, or shared-state dependent. Confirm by checking whether the same job passed on a recent unrelated pipeline. Do not retry blindly to make it green.
- **Genuine failure** - an assertion or a compile error traceable to the diff. This is the only class where the fix is in the code.

**4. Report the class, the evidence, and the next action.**
Name the job, the first real error line, the class, and what should happen. Never recommend a retry for anything you classified as a genuine failure.

## Watching a running pipeline

Only when the caller has asked for it. Watching is never the default - a small change does not justify holding a session open.

**Do not use a blocking command.** `glab ci status --live` and similar hold the session. Poll instead.

**Poll, do not stream.**
- Interval: scale to the expected duration in the repo's `repo-map.md` (CI section). Roughly one check per tenth of expected runtime, never more often than every 30 seconds. No stated duration: check every 60 seconds.
- Each check is one `glab ci status` (or `glab ci view` for stage detail). Extract state only - never pull job logs while polling.
- Keep a wall-clock budget: stop at roughly twice the expected duration and report "still running after N minutes" rather than polling indefinitely.

**Terminal states, and what each means.**
| State | Meaning | Action |
|---|---|---|
| success | all required jobs passed | report and stop |
| failed | a required job failed | stop polling, triage, report |
| canceled | someone or something stopped it | report who/what if visible; do not restart |
| skipped | upstream condition not met | report why |
| manual / waiting | a human gate is blocking | report it as needing the caller, not as a failure |

**Report the first real failure immediately.** Do not wait for the whole pipeline to finish. A downstream job failing because an upstream one did is not a second finding.

**A failure report is a triaged report.** Run the triage steps above and give the class, the first real error line and the next action. "Job `unit-test` failed" on its own is not a useful report.

**Never act on what you see.** No retry, no cancel, no merge, even if the failure looks obviously transient or obviously fine. Say what should happen; let the caller do it.
