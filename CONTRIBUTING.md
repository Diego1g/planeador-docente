# Contributing

Thanks for your interest in contributing to this project.

This repository is a chat-first toolkit for course/lesson planning with custom Copilot agents, templates, and helper scripts.

## Contribution Flow

1. Open an issue (bug, improvement, or proposal).
2. Create a focused branch from `main`.
3. Make small, scoped changes.
4. Validate locally (see checks below).
5. Open a Pull Request with clear context.

## Project-Specific Rules

- Follow the chat-first workflow: `@course-planner` -> `@discussion-moderator` -> `@lesson-planner` (optional) -> `@slides-maker`.
- Keep lesson artifacts under `lessons/lesson-{number}-{id}/.lesson/artifacts/`.
- Treat templates in `.lesson/templates/` as structure baselines, not fixed content.
- Respect language policy:
  - default to English,
  - honor explicit user language override,
  - use metadata language when required by the lesson flow.
- Respect section-count policy:
  - use the section count decided in planning/highlights/user input,
  - do not force template example section counts.

## Naming and Validation

- Lesson number format: `01..23` (two digits).
- Lesson id format: lowercase kebab-case (`[a-z0-9-]+`).
- Keep consistency between `lessons/README.md` and `.lesson-config.json`.

## Local Checks

Run relevant checks before opening a PR:

```bash
bash -n scripts/*.sh
jq . .lesson/templates/.lesson-config.json >/dev/null
```

When testing script flows:

```bash
./scripts/generate-lesson.sh 01 sample-lesson "Sample Lesson"
./scripts/generate-slides-pdf.sh lessons/lesson-01-sample-lesson
```

For full-course scaffolding:

```bash
./scripts/generate-course-scaffolding.sh
# or
./scripts/generate-course-scaffolding.sh --force
```

## Pull Request Checklist

- [ ] Change is scoped and documented
- [ ] Paths and naming conventions are respected
- [ ] Language and section-count rules are preserved
- [ ] Relevant script checks were run
- [ ] No unrelated files or generated artifacts are included unintentionally

## Security and Publishing Notes

- Before GitHub operations, run:

```bash
./scripts/prepare-git.sh
```

- Do not include secrets/tokens in files, commits, or logs.
- Respect `.gitignore` and publishing constraints.
