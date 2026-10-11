# Git conventions

Branch, commit and MR conventions in one file, because the GitLab issue ID
threads through all three.

---

## The issue ID thread

Branch:  `<gitlab issue id>-<short-description>`     e.g. `4821-repo-eligibility-cache`
Commit:  `<gitlab issue id>-<commit message>`        e.g. `4821-add eligibility cache invalidation`
MR:      carries the same ID in the title, and links the issue in the description.

### Extracting the issue ID - do this, do not guess

The ID comes from the branch name. Never invent one, never reuse one from an
earlier commit, never take one from the diff.

    branch=$(git rev-parse --abbrev-ref HEAD)
    id=$(printf '%s' "$branch" | grep -oE '^[0-9]+')

- `id` empty -> **STOP**. Report the branch name and ask for the issue ID. Do not commit without it.
- Detached HEAD, or on `main`/`master`/`develop`/`release/*` -> STOP. You should not be committing there.
- The caller supplied an ID explicitly -> theirs wins, even if it differs from the branch.
- The message the caller gave already starts with the ID -> do not prefix it again.

---

## Commit messages

Format: `<id>-<message>`
- No Conventional Commits type or scope. No `feat:`, no `fix(scope):`.
- One hyphen between the ID and the message, no space: `4821-add eligibility cache invalidation`.
- Message in imperative mood, lower case start, no trailing full stop.
- Subject under 72 characters including the ID prefix.
- Body optional, separated by a blank line, and explains **why** - the diff already shows what.
- One logical change per commit. If the staged set covers two unrelated things, say so and offer to split.

Do not add trailers. No `Co-Authored-By`, no tool or AI attribution, no robot
markers, in the subject, body or footer. Authorship is the configured git user
and nothing else.

---

## Branches

Format: `<gitlab issue id>-<short-description>`
- Description in lower-case kebab-case, a few words, no ticket text copied verbatim.
- No type prefix, no slashes. The ID is always the first characters of the branch name.
- Branch from the current target branch, freshly fetched.

---

## Merge requests

### Title
`<gitlab issue id>-<short summary>` - same ID as the branch and commits.

### Description
```
## Summary
Why this change exists, in two or three sentences.

## Changes
What changed, by area. Not a restatement of the diff.

## Testing
What was run and what it proved. Name the tests.

## Risk / Rollback
What breaks if this is wrong, and how to undo it.
```

### Before raising
- Source branch rebased onto the target, not merged.
- The GitLab issue is linked in the description (`Closes #<id>` or the house keyword).
- Public contract, schema migration, or settlement impact -> stated explicitly in Risk.
- No AI or tool attribution anywhere in the description.

### Labels
Fill in your team's rules.

| Label | When to apply |
|---|---|
|  |  |

### Reviewers and approvals
Fill in: who must approve what (domain owner, platform, security), how many
approvals are required, and when a second reviewer is mandatory (contract
change, schema migration, settlement path).

### Draft convention
Fill in: when to open as draft, and what must be true before marking ready.

### Blocks a merge in this org
Fill in, so these are checked before raising rather than after review.