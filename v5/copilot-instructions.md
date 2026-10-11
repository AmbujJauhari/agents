## Delegation (subagent routing)
Delegate to custom agents instead of doing these tasks inline, and keep only their summaries in context:
- Version control: local git (status, diff, commit, rebase, branches, push) AND GitLab (MRs, pipelines, CI logs, issues) -> git-ops
- Running builds or tests -> build-runner
- Writing or fixing unit/slice tests -> test-writer
- Reviewing a diff before commit or MR -> code-reviewer
- Kubernetes/AKS investigation -> k8s-ops
Do planning, design and production code changes in the main session.
Typical flow: locate code (direct search or explorer, see below) -> implement -> build-runner -> test-writer -> code-reviewer -> git-ops (commit, push, MR, pipeline).

git-ops never starts watching a pipeline on its own - it reports the URL and asks. Answer it, or say up front "raise the MR and watch the pipeline" to skip the question.

## Code exploration routing
- Known symbol, class, file or config key -> search directly yourself (grep/glob/view). 1-2 tool calls; do not delegate.
- Multi-hop or cross-service questions (tracing a flow across services, finding all consumers/producers of a topic, mapping an unfamiliar module, "where is X decided") -> explorer. Prefer explorer over the built-in Explore agent.
- explorer returns file:line pointers, not conclusions to rely on. Before editing or designing, read the key ranges it points to yourself.
- If explorer's answer is incomplete, send a narrower follow-up question; don't repeat the same request.
- Pass `Start in` and `Skip` hints in the task when you know them, including from the repo's `repo-map.md`.

## Skills
Load the matching skill before these, rather than improvising the approach:
- Designing a new endpoint, resource or event schema -> `api-design`. Produce its design document and get it approved before writing a spec or a controller.
- Branching, committing, raising an MR, watching a pipeline, or triaging a red one -> `git-workflow` (git-ops loads this itself when delegated to). Commit and branch names carry the GitLab issue ID, extracted from the branch - never invented.
- Any Sybase data question beyond a single-table lookup -> `sybase-investigation` (sybase-analyst loads this itself when delegated to).
- Reviewing a diff or an MR -> `code-review` (code-reviewer loads this itself when delegated to; it loads only the per-language checklists the diff touches).
Skills hold procedure; the instructions files hold the rules the result must satisfy. Follow both.

## Sybase routing
Pick by who needs to do the reasoning:
1. You already know the SQL you want -> write it yourself and send it to sybase-query to execute verbatim. Include the SQL in the task.
2. Schema questions or simple single-table lookups -> sybase-query in plain English.
3. Multi-step investigation where you only need the conclusion (joins across tables, tracing a record's lifecycle, explaining an unexpected value) -> sybase-analyst. Review its evidence queries before relying on its findings.
4. Deep dive in the main session: call the Sybase MCP tools directly yourself when any of these hold:
   - the findings will directly drive a code change or design decision,
   - it's a production issue, a reconciliation break, or anything with money/settlement impact,
   - sybase-analyst returned low confidence or conflicting evidence,
   - the user asks to look at the data together.
   Keep row caps tight (<=50), project explicit columns, and suggest /compact with a focus once the deep dive is done.
If sybase-query returns "Needs sybase-analyst" or an SQL error, fix the SQL yourself or escalate; never retry the same request unchanged.