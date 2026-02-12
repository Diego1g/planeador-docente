---
name: slides-maker
description: Creates MARP slide presentations from highlights/discourse. Use when user asks to create slides.
---

# Role
Generate MARP (https://marp.app) presentations from lesson artifacts.

# Required Inputs
- Lesson number (mandatory, e.g., 01, 02, ..., 23)

**Auto-load from `.lesson-config.json`:**
- Instructor name (default: loaded from config)
- Email (default: loaded from config)
- Lesson title (loaded from config)
- Language requirements (from course/lesson metadata)

# Language Requirements
- Respect the lesson language requirements for all slide content.
- Use language from `.lesson-config.json` metadata as default.
- If the user explicitly requests a different language for slides, follow that request.
- Do not mix languages within the same deck unless explicitly requested.

# Section Count Rule
- Build slides from the decided lesson section count (from highlights/discourse/user input).
- Use `.lesson/templates/SLIDES.md` only as a layout guide.
- Do not force the template section count when lesson decisions differ.

# Workflow
1. Ask user for lesson number
2. Load lesson metadata from `.lesson-config.json` (instructor, email, title)
3. Resolve target language from metadata (or explicit user override)
4. Find lesson directory: `lessons/lesson-{number}-{id}/`
5. Read section files from `lessons/lesson-{number}-{id}/.lesson/artifacts/highlights/` and optionally `discourse/`
6. Use `.lesson/templates/SLIDES.md` as the structure baseline when available
7. Create `lessons/lesson-{number}-{id}/.lesson/artifacts/slides/00-marp-header.md` with MARP config (theme, paginate, header, footer)
8. For each section, create slide files `01-title.md`, `02-section.md`, etc. with:
   - Title slide (01-title.md): lesson title, instructor name/email, course name
   - Content slides: learning objectives, key concepts, activities, resources
9. Ensure all generated slide text is in the resolved target language
10. Create final section with summary slide (key takeaways)
11. Ask if user wants PDF. If yes, instruct to run: `./scripts/generate-slides-pdf.sh lessons/lesson-{number}-{id}`

# Notes
Keep content simple. If uncertain, spawn co-teacher for feedback.