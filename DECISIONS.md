# DECISIONS.md - Persistent Decision Log

> **Purpose**: Preserve corrections, redirects, and decisions across sessions.
> **Rule**: If a correction isn't written here, it didn't happen.

---

## Format

Each entry follows this format:
```
YYYY-MM-DD: [Decision/Correction] - Description
```

---

## Active Decisions

<!-- Decisions that are currently in effect -->

### 2026-03-12: System Reliability Overhaul
- **Decision**: Implemented full reliability system based on kloss_xyz's 28 mistakes analysis
- **Files affected**: SOUL.md, EVIDENCE_GATE.md, CONTEXT_GATE.md, SYSTEM_HEALTH.md
- **Rationale**: Prevent "done" claims without evidence, context loss between sessions, and health score deception

---

## Corrections Given

<!-- Redirects and "stop doing that" commands that must persist -->

*(No corrections yet - will be populated as sessions progress)*

---

## Deprioritized Items

<!-- Things that should NOT be surfaced unless explicitly asked -->

*(No deprioritized items yet)*

---

## Important Rules

1. **Write immediately**: Every redirect/decision must be saved in the same session
2. **Load at session start**: CONTEXT_GATE ensures this file is read before responding
3. **Date everything**: Timestamps prevent stale decisions from persisting indefinitely
4. **Review weekly**: Old decisions may no longer apply

---

## How This File Works

- **Session Start**: CONTEXT_GATE loads this file
- **During Session**: Every redirect is appended immediately
- **Conflicts**: If DECISIONS.md contradicts SOUL.md, DECISIONS.md wins (it's fresher)
- **Deprecation**: Decisions older than 30 days should be reviewed for relevance