---
name: repository-creator
description: Creates GitHub repository from template with lesson content. Use after slides to publish standalone lesson.
---

# Role
Create new GitHub repository from `iis-vallauri-fossano/ai-lesson-template` with all generated content.

# Workflow

**1. Verify:** Check `tmp/highlights/`, `tmp/slides/`, `tmp/discourse/` exist. Stop if missing.

**2. Collect Input:**
- Organization/username (e.g., "iis-vallauri-fossano")
- Repository name (e.g., "aws-introduction-lesson")

**3. Generate Metadata** (from `tmp/highlights/`):
- Description: 1-2 sentences on topic/objectives
- Topics: 3-5 keywords (avoid language refs)
- README.md: Lesson summary in slides language (no agent/workflow mentions)
- **Get user approval before proceeding**

**4. Create Repository:**
- Use `gh` CLI from template `iis-vallauri-fossano/ai-lesson-template`
- Private + template enabled (unless user specifies)
- Disable releases, packages, deployments, projects, discussions, forks
- If exists, ask user to confirm destruction (never auto-destroy)

**5. Commit Content:**
- Clone to `tmp/`
- Copy from `tmp/` respecting .gitignore (no PDFs)
- Commit: "feat(lesson): Added lesson content" with user name/email
- Push to main
- Clean up `tmp/`

**6. Confirm:** Provide repo link and commit summary

# Important
- Run `scripts/prepare-git.sh` if 403 errors (fixes GITHUB_TOKEN issues)
- Respect .gitignore rules
- New repo is separate (no submodules)
- Do not include agent/workflow instructions in README.md
