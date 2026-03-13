# CONTEXT_GATE.md - Load Before Responding

> **Core Principle**: Never respond with stale or missing context.
> **Rule**: Read required files BEFORE any substantive response.

---

## Why This Exists

Agents can give "cold answers" — responding without checking recent decisions, corrections, or memory. This creates repetitive questions and ignored instructions.

**The Problem:**
- Session starts fresh
- Agent doesn't load previous context
- User has to repeat instructions every session
- Corrections from yesterday are forgotten

**The Fix:**
- Mandatory context loading before responding
- Defined priority order for file loading
- No response until context is loaded

---

## Context Loading Priority

Load these files in order BEFORE substantive responses:

```
1. DECISIONS.md    → Active decisions, corrections, deprioritized items
2. memory/*.md      → Session-specific memories (today's and recent)
3. USER.md         → User preferences, context
4. SOUL.md         → Core personality and principles
5. IDENTITY.md     → Who this agent is
```

---

## Loading Protocol

### At Session Start

```
1. Read DECISIONS.md
   - Check for active decisions
   - Note any corrections given
   - Identify deprioritized items

2. Check memory/ directory
   - Load today's log (if exists)
   - Load yesterday's log (if exists)

3. Read USER.md for preferences

4. Now you may respond
```

### Before Substantive Responses

Before providing analysis, recommendations, or taking action:

```
☐ Have I read DECISIONS.md this session?
☐ Have I checked memory/ for relevant context?
☐ Are there any corrections that apply to this request?
☐ Is this request about something deprioritized?
```

---

## Response Rules

### DO NOT respond substantively until:
- [ ] DECISIONS.md has been loaded
- [ ] Relevant memory files have been read
- [ ] User preferences from USER.md are known

### If context is missing:
- State what context you're loading
- Load it before continuing
- Then proceed with the response

### Example:
```
"Let me load recent context first...

[Reading DECISIONS.md and memory/]

Based on recent decisions, I see that X was deprioritized.
Moving on to your actual request..."
```

---

## What Counts as "Substantive"

**Requires context loading:**
- Analysis or recommendations
- Code changes or file modifications
- Task planning or execution
- Multi-step workflows

**Does NOT require context loading:**
- Simple greetings
- Direct factual questions
- "What files are in this directory?"

---

## Integration Points

| File | Purpose | When to Load |
|------|---------|--------------|
| DECISIONS.md | Active corrections | Every session start |
| memory/*.md | Recent context | Every session start |
| USER.md | User preferences | Every session start |
| SOUL.md | Core principles | Every session start |

---

## Session End Protocol

At session end (or before major breaks):

1. **Update memory** - Write what happened this session
2. **Log decisions** - Any new decisions go in DECISIONS.md
3. **Note corrections** - If user corrected you, log it

This ensures the next session has full context.