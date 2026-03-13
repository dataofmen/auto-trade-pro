# SYSTEM_OVERVIEW.md - How Everything Connects

> **Purpose**: Visual guide to the reliability system architecture.
> **Read this**: When setting up a new workspace or debugging system behavior.

---

## 📁 File Hierarchy

```
workspace/
├── SOUL.md           ← Core personality & principles (loaded always)
├── IDENTITY.md       ← Who this agent is (loaded always)
├── USER.md           ← Human context & preferences (loaded always)
├── DECISIONS.md      ← Persistent corrections (loaded first!)
├── CONTEXT_GATE.md   ← Loading protocol
├── EVIDENCE_GATE.md  ← Proof requirements
├── SYSTEM_HEALTH.md  ← Health scoring
├── PLAN.md           ← High-level strategy
├── TASK.md           ← Execution tasks
├── PROOFS.md         ← Task evidence
├── TOOLS.md          ← Available tools
├── AGENTS.md        ← Agent definitions
├── HEARTBEAT.md      ← Health checks
└── memory/           ← Session logs
    └── YYYY-MM-DD.md ← Daily memories
```

---

## 🔄 Loading Order

Every session MUST load files in this order BEFORE substantive responses:

```
1. DECISIONS.md      → Active corrections, redirects
2. memory/today.md   → Today's context
3. memory/yesterday.md → Recent history
4. USER.md           → Human preferences
5. SOUL.md           → Core principles
6. IDENTITY.md       → Agent identity
```

**Rule**: If DECISIONS.md contradicts SOUL.md, DECISIONS.md wins.

---

## 🔗 Dependency Graph

```
                    ┌─────────────────┐
                    │   SOUL.md       │
                    │   (Core Rules)  │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ EVIDENCE_GATE   │ │ CONTEXT_GATE    │ │ SYSTEM_HEALTH   │
│ (Proof Rules)   │ │ (Load Order)    │ │ (Scoring)       │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  DECISIONS.md   │
                    │  (Overrides)    │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ USER.md         │ │ IDENTITY.md     │ │ memory/*.md    │
│ (Human Info)    │ │ (Agent Info)    │ (Session Logs)  │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## 🎯 Core Principles Summary

| Principle | File | What It Means |
|-----------|------|---------------|
| No "done" without proof | EVIDENCE_GATE.md | Every completion claim needs evidence |
| Context before response | CONTEXT_GATE.md | Load decisions before answering |
| Decisions persist | DECISIONS.md | Corrections don't vanish between sessions |
| Health scores must be honest | SYSTEM_HEALTH.md | Integrity multiplier catches lies |
| One problem at a time | SOUL.md | Clean scope, clean output |
| Write before speak | SOUL.md | Persist state before announcing |

---

## ⚡ Quick Reference

### When User Says "Done"
Check EVIDENCE_GATE.md → Provide receipts

### When Session Starts
Check CONTEXT_GATE.md → Load in order

### When User Corrects You
Immediately update DECISIONS.md

### When Reporting Health
Check SYSTEM_HEALTH.md → Include integrity multiplier

### When Considering a New Rule
- Note in DECISIONS.md as proposed
- Explain why it matters
- Ask for approval to make permanent

---

## 🚫 Common Mistakes to Avoid

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| Responding without loading DECISIONS.md | Forgets previous corrections | Load first |
| Claiming "done" without evidence | Work might not be done | Provide receipts |
| Ignoring memory/ files | Re-asks solved problems | Load recent memory |
| Importing others' configs blindly | Context poisoning | Audit first |
| Averaging away critical failures | Hides real problems | Use integrity multiplier |

---

## 📋 Setup Checklist

For a new workspace:

- [ ] Copy SOUL.md, IDENTITY.md, USER.md
- [ ] Create empty DECISIONS.md
- [ ] Create memory/ directory
- [ ] Create first memory file with date
- [ ] Verify CONTEXT_GATE.md exists
- [ ] Verify EVIDENCE_GATE.md exists
- [ ] Verify SYSTEM_HEALTH.md exists
- [ ] Test: Load all files in order
- [ ] Test: Write a decision, verify it persists

---

## 🔧 Maintenance

### Weekly
- Review DECISIONS.md for stale entries
- Check memory/ for gaps
- Verify SYSTEM_HEALTH scores are fresh

### Monthly
- Audit imported configs/skills
- Review and clean up old decisions
- Check for duplicate repos/files

### As Needed
- Update SOUL.md with new learnings
- Add corrections to DECISIONS.md
- Archive old memory files

---

_Last updated: 2026-03-12_
_System version: 1.0 (kloss_xyz reliability overhaul)_