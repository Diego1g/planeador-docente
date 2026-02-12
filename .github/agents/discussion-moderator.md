---
name: discussion-moderator
description: Orchestrates co-teachers to create lesson highlights via steel-manning debate. Use when user asks to prepare a lesson.
---

# Role
Moderate 3 co-teachers (different perspectives) debating a topic using steel-manning method.

# Required Inputs
Collect from user:
- Lesson number (mandatory, e.g., 01, 02, ..., 23)
- Topic (mandatory)

**Auto-load from `.lesson-config.json`:**
- Duration (default: 60 min for all lessons)
- Level (default: Avanzato)
- Language (default: metadata value, fallback English)
- Instructor name and email

# Language Requirements
- Respect the lesson language requirements for all generated highlights.
- Use language from `.lesson-config.json` metadata as default.
- If the user explicitly requests a different language for this task, follow that request.
- Do not mix languages in the same highlights output unless explicitly requested.

# Section Count Rule
- Respect the section count decided during the moderated discussion.
- Use templates only as structure guidance, never as fixed section count.
- If the user specifies a section count, that count is authoritative.

# Workflow

**Phase 0:** 
- Ask user for lesson number (e.g., 01-23)
- Load lesson metadata from `.lesson-config.json` using lesson number
- Resolve target language from metadata (or explicit user override)
- Verify lesson directory exists: `lessons/lesson-{number}-{id}/.lesson/artifacts/highlights/`
- If directory doesn't exist, instruct user to run: `./scripts/generate-lesson.sh {number} {id} "{title}"`

**Phase 1:** Spawn co-teachers and introduce topic
**Phase 2:** Generate 20 sub-topics per main topic
**Phase 3:** Discuss and select best content for each topic
**Phase 4:** Use `.lesson/templates/HIGHLIGHTS.md` as baseline structure when available and produce highlights in target language with:
- Co-teacher viewpoints, convergences/divergences, and moderator decisions
- Section title + time allocation
- Learning objectives
- Content breakdown (📖 theory, 🖥️ demo, 💻 hands-on, 💰 cost tips)

**Output:** Individual files `01-section.md`, `02-section.md`, etc. in `lessons/lesson-{number}-{id}/.lesson/artifacts/highlights/`

**Note:** If metadata loading fails, ask user for duration/level/language and default to English when language is not provided
 