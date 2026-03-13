# EVIDENCE_GATE.md - Proof Before "Done"

> **Core Principle**: An agent saying "done" is worthless without receipts.
> **Rule**: No task can be marked complete without verifiable evidence.

---

## Why This Exists

Agents can claim completion without actually completing anything. This gate forces verification before claiming success.

**The Problem:**
- Agent says "task complete"
- Nothing actually happened
- You waste time manually checking every single time

**The Fix:**
- Evidence is mandatory
- No proof = not done
- Structure prevents deception (intentional or not)

---

## Evidence Requirements

Before marking any task as "done," provide:

### For Code Changes
```markdown
✅ **Evidence Required:**
- Repository: [repo name]
- Branch: [branch name]
- Commit hash: [full hash]
- Files changed: [list]
- Verification: [how to verify it works]
```

### For Configuration Changes
```markdown
✅ **Evidence Required:**
- File modified: [path]
- Before: [key value before]
- After: [key value after]
- Verification: [command to verify]
```

### For Research/Analysis
```markdown
✅ **Evidence Required:**
- Files read: [list]
- Key findings: [bullet points]
- Artifacts created: [any docs/notes]
```

### For UI Changes
```markdown
✅ **Evidence Required:**
- Screenshot: [before/after]
- URL: [where to view]
- Verification: [test steps]
```

---

## Evidence Gate Checklist

Before responding with "done" or "complete":

- [ ] What repository/branch was affected?
- [ ] What specific files changed?
- [ ] Can the change be verified?
- [ ] Is there a commit hash or artifact?
- [ ] If UI, is there a screenshot?

**If any answer is "I don't know" or "not applicable" — the task is NOT done.**

---

## Anti-Patterns (What NOT to Do)

❌ "I've completed the task."
✅ "I've completed the task. Evidence: commit abc123, files changed: X, Y, Z"

❌ "The config is updated."
✅ "Config updated. Before: X=false, After: X=true. Verify with: cat config.yml"

❌ "It should work now."
✅ "Verified working. Test output: [actual output showing success]"

---

## Session Memory Integration

- This file is loaded by CONTEXT_GATE at session start
- Violations are logged in DECISIONS.md as corrections
- Pattern: "Evidence gate violation" → immediate correction required