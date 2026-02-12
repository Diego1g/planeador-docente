# Scripts

Utility scripts for lesson setup, content generation workflow, PDF export, and GitHub authentication.

## Requirements

- Bash
- `jq` (optional, used for JSON metadata updates)
- `gh` (required by `prepare-git.sh`)
- `marp` CLI (required by `generate-slides-pdf.sh`)

## Available Scripts

### `create-artifacts-structure.sh`
Creates the lesson artifacts directory structure in the current path:
- `.lesson/artifacts/highlights/`
- `.lesson/artifacts/discourse/`
- `.lesson/artifacts/slides/`

Usage:
```bash
./scripts/create-artifacts-structure.sh
```

---

### `create-lesson-structure.sh`
Creates a new lesson folder under `lessons/` with base files and local config.

Usage:
```bash
./scripts/create-lesson-structure.sh <number> <id> "<title>"
```

Example:
```bash
./scripts/create-lesson-structure.sh 01 introduction-agents "Introduction to AI Agents"
```

---

### `generate-lesson.sh`
Wrapper around lesson setup:
1. creates lesson structure
2. updates course lesson status in `lessons/README.md`
3. updates `.lesson-config.json` status (when `jq` is available)

Usage:
```bash
./scripts/generate-lesson.sh <number> <id> "<title>"
```

Example:
```bash
./scripts/generate-lesson.sh 01 introduction-agents "Introduction to AI Agents"
```

---

### `generate-course-scaffolding.sh`
Creates scaffolding for all lessons declared in `.lesson-config.json`.

Usage:
```bash
./scripts/generate-course-scaffolding.sh
```

Force overwrite existing lesson directories:
```bash
./scripts/generate-course-scaffolding.sh --force
```

---

### `generate-slides-pdf.sh`
Builds `SLIDES.pdf` from markdown files in `.lesson/artifacts/slides/` using MARP.

Usage (current directory):
```bash
./scripts/generate-slides-pdf.sh
```

Usage (specific lesson path):
```bash
./scripts/generate-slides-pdf.sh lessons/lesson-01-introduction-agents
```

---

### `prepare-git.sh`
Prepares GitHub authentication for repository operations:
- clears `GITHUB_TOKEN`
- checks or runs `gh auth login`
- runs `gh auth setup-git`

Usage:
```bash
./scripts/prepare-git.sh
```

## Typical Workflow

```bash
# 1) Create or generate lesson structure
./scripts/generate-lesson.sh 01 introduction-agents "Introduction to AI Agents"

# Alternative: scaffold all lessons from .lesson-config.json
./scripts/generate-course-scaffolding.sh

# 2) Generate lesson content via agents (from VS Code chat)
# @discussion-moderator ...
# @lesson-planner ...
# @slides-maker ...

# 3) Export slides to PDF
./scripts/generate-slides-pdf.sh lessons/lesson-01-introduction-agents
```
