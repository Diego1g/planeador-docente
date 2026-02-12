# Workflow

This project follows a chat-first multi-agent flow.

## End-to-End Flow

1. `@course-planner`
   - plans the course outline
   - updates `.lesson-config.json` and course-level structure
2. `@discussion-moderator`
   - runs co-teacher discussion
   - produces highlights artifacts
3. `@lesson-planner` (optional)
   - expands highlights into detailed discourse
4. `@slides-maker`
   - generates MARP slide artifacts from highlights/discourse
5. `./scripts/generate-slides-pdf.sh`
   - exports `SLIDES.pdf` for a lesson

## Core Rules

- Language: metadata default, user override always wins.
- Section count: decided in planning/highlights/user input; templates are not fixed counts.
- Paths: store outputs under `lessons/lesson-XX-id/.lesson/artifacts/`.

## Key Commands

```bash
./scripts/generate-lesson.sh 01 intro-topic "Intro Topic"
./scripts/generate-course-scaffolding.sh
./scripts/generate-slides-pdf.sh lessons/lesson-01-intro-topic
```
