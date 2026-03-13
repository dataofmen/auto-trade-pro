# SYSTEM_HEALTH.md - Honest Health Scoring

> **Core Principle**: A health score that lies is worse than no score at all.
> **Rule**: Integrity failures must drag down the overall score.

---

## Why This Exists

A system can show "94/100 healthy" while critical components are broken. Stale scores and averaging hide real problems.

**The Problem:**
- Health score calculated hours ago
- Critical failure hidden by averaging
- "Everything looks good" when it's not

**The Fix:**
- Freshness checks on all scores
- Integrity multiplier that can't be averaged away
- Hard gates that fail the whole system

---

## Health Score Components

### Layer 1: Letter Grade (Quick Read)
```
A = All critical gates pass, integrity 100%
B = Minor issues, integrity 80%+
C = Some issues, integrity 60%+
D = Significant issues, integrity 40%+
F = Critical failure or integrity < 40%
```

### Layer 2: Category Scores (Debug Detail)
```
├── Context Integrity     [0-100]  ← Are DECISIONS/memory loaded?
├── Evidence Compliance   [0-100]  ← Are "done" claims backed?
├── Configuration Health  [0-100]  ← Are configs valid?
├── Session Continuity    [0-100]  ← Is context preserved?
└── Tool Availability     [0-100]  ← Are required tools working?
```

### Layer 3: Integrity Multiplier
```
Integrity Check      | Multiplier
---------------------|------------
All pass             | 1.00 (100%)
Warning state        | 0.67 (67%)
Failure state        | 0.33 (33%)
```

**Final Score = Base Score × Integrity Multiplier**

---

## Critical Gates (Cannot Be Averaged Away)

These failures set the entire system to F, regardless of other scores:

| Gate | Failure Condition | Impact |
|------|-------------------|--------|
| Context Gate | DECISIONS.md not loaded in last session | Integrity = 0.33 |
| Evidence Gate | "Done" claimed without proof | Score = min(30, current) |
| Config Integrity | Duplicate/missing configs | Integrity = 0.67 |
| Memory Freshness | No memory update in 7+ days | Category score = 0 |

---

## Score Calculation Example

```
Category Scores:
  Context Integrity:    85
  Evidence Compliance: 70
  Configuration Health: 95
  Session Continuity:   80
  Tool Availability:    90

Base Score: (85+70+95+80+90) / 5 = 84

Integrity Check:
  DECISIONS loaded? ✓
  memory fresh? ✓
  Evidence backed? ⚠ (one unverified claim)

Integrity Multiplier: 0.67 (warning)

Final Score: 84 × 0.67 = 56.28 → Grade D
```

---

## Freshness Requirements

| Component | Freshness Check | Stale Threshold |
|-----------|----------------|-----------------|
| DECISIONS.md | Last session loaded | Never → Warning |
| memory/ | Last write date | 7 days → Stale |
| Health Score | Calculation time | 1 hour → Recalculate |
| Config Check | Last verification | 24 hours → Re-verify |

---

## Reporting Format

When reporting system health:

```markdown
## System Health: B (76/100)

### Category Scores
- Context Integrity: 90 ✓
- Evidence Compliance: 65 ⚠
- Configuration Health: 95 ✓
- Session Continuity: 80 ✓
- Tool Availability: 50 ⚠

### Integrity
- DECISIONS loaded: ✓
- Memory fresh: ✓ (2 days)
- Evidence backed: ⚠ (1 unverified claim)

### Issues
- Tool Availability low: Slack connection intermittent
- Evidence Compliance: 2 "done" claims without receipts
```

---

## Anti-Patterns (What NOT to Do)

❌ "Health score: 94" (with no breakdown)
✅ Full breakdown with integrity multiplier

❌ Averaging away critical failures
✅ Critical gates force score down

❌ Stale scores from hours ago
✅ Freshness checks before reporting

---

## Integration

- CONTEXT_GATE loads this file and checks freshness
- Every "done" claim updates Evidence Compliance
- Session end updates Session Continuity
- Health score recalculated on demand