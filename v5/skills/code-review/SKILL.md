---
name: code-review
description: Method and per-language criteria for reviewing a diff or a merge request before it is raised - detecting which languages changed, loading the matching checklist, and classifying findings by severity. Use when reviewing uncommitted changes, a branch diff, or an MR.
argument-hint: the diff, branch or MR to review
user-invocable: true
---

# Reviewing a change

## Method

**1. Get the actual diff.** `git diff`, `git diff <base>...HEAD`, or `glab mr diff`. Review what changed, not what the description claims changed.

**2. Detect which languages changed, and load only those checklists.**

| Changed files | Load |
|---|---|
| `*.java` | `reference/java.md` |
| `*.sql`, migration files | `reference/sql.md` |

A mixed diff loads more than one. Do not apply a checklist for a language that did not change.

No checklist exists for a language in the diff (TypeScript, Python, YAML, shell): review it on general principles, and say in your output which languages had no checklist. Do not look for a reference file that is not listed above.

**3. Read enough context to judge.** A diff hunk alone hides the bug as often as it shows it. Open the surrounding method, the caller, and the test. Reviewing a diff in isolation produces confident wrong findings.

**4. Check for reinvention, in every language.** Any new hand-rolled helper doing generic work (collection, string, date, retry, hashing, IO) that duplicates the standard library, a declared dependency, or an existing utility in the repo. Check the build file for what is already available. Flag it with the replacement one-liner.

**5. Classify by what it would cost in production.**
- **BLOCKER** - wrong results, data corruption, a security hole, a broken contract, or a resource leak. Something that must not merge.
- **SHOULD-FIX** - a real defect with a smaller blast radius, a missing test for changed behaviour, or a maintainability trap that will bite.
- **NIT** - genuinely optional. If you have more than two or three, you are padding.

Skip anything a formatter or linter already catches. A review full of style notes buries the finding that mattered.

**6. State what you could not check.** Code you did not read, behaviour that needs the running system, a dependency you could not inspect. A review that implies full coverage it did not have is worse than a short one.

## Output

Findings grouped BLOCKER / SHOULD-FIX / NIT, each with `file:line`, the problem in one sentence, and the suggested fix in one or two lines. Then the not-checked note. If the change is clean, say so in a line - do not manufacture findings to look thorough.
