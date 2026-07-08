export function slugify(text) {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 48) || 'lesson-topic';
}

export function padLessonNumber(n) {
  return String(n).padStart(2, '0');
}

export function statusEmoji(status) {
  const map = {
    'not-started': '⏳ Not started',
    'in-progress': '🔄 In progress',
    completed: '✅ Completed'
  };
  return map[status] || status;
}

export function buildLessonConfig(state) {
  return {
    course: state.course,
    lessons: state.lessons.map((l) => ({
      number: l.number,
      id: l.id,
      title: l.title,
      module: l.module,
      status: l.status
    }))
  };
}

export function buildCourseReadme(state) {
  const { course, lessons } = state;
  const rows = lessons
    .map((l) => {
      const num = padLessonNumber(l.number);
      return `| ${num} | \`${l.id}\` | ${l.title} | ${l.module || '—'} | ${statusEmoji(l.status)} |`;
    })
    .join('\n');

  return `# ${course.title || 'Course Title'}

## Summary

${course.metadata.audience ? `**Audience:** ${course.metadata.audience}  \n` : ''}**Level:** ${course.metadata.level}  
**Language:** ${course.metadata.language}  
**Duration per lesson:** ${course.metadata.duration_per_lesson} minutes  
**Instructor:** ${course.instructor.name || '—'} (${course.instructor.email || '—'})

## Lesson Index

| # | ID | Title | Module | Status |
|---|-----|-------|--------|--------|
${rows || '| — | — | Add lessons in the planner | — | — |'}

## Workflow

1. Generate highlights with \`@discussion-moderator\`
2. Generate discourse (optional) with \`@lesson-planner\`
3. Generate slides with \`@slides-maker\`
4. Export PDF with \`./scripts/generate-slides-pdf.sh\`
`;
}

export function buildLessonReadme(state, lesson) {
  const { course } = state;
  const num = padLessonNumber(lesson.number);
  const folder = `lesson-${num}-${lesson.id}`;

  return `# Lesson ${num}: ${lesson.title}

**Course:** ${course.title}  
**Module:** ${lesson.module || '—'}  
**Duration:** ${course.metadata.duration_per_lesson} minutes  
**Level:** ${course.metadata.level}  
**Language:** ${course.metadata.language}

---

## Instructor

**${course.instructor.name || '—'}**  
${course.instructor.email || '—'}

---

## Status

${statusEmoji(lesson.status)}

## Generate Content

\`\`\`
@discussion-moderator Prepare lesson #${num}: ${lesson.title}
@lesson-planner Create discourse for lesson #${num}
@slides-maker Create slides for lesson #${num}
\`\`\`

## Structure

\`\`\`
${folder}/
├── README.md
└── .lesson/artifacts/
    ├── highlights/HIGHLIGHTS.md
    ├── discourse/DISCOURSE.md
    └── slides/SLIDES.md
\`\`\`
`;
}

export function defaultHighlights(state, lesson) {
  const { course } = state;
  const num = padLessonNumber(lesson.number);
  return `# HIGHLIGHTS — Co-Teacher Discussion Summary (Lesson ${num}: ${lesson.title})

## Context

- Course: ${course.title}
- Module: ${lesson.module || 'Module 1'}
- Lesson number: ${num}
- Target audience: ${course.metadata.audience || 'Students'}
- Level: ${course.metadata.level}
- Language: ${course.metadata.language}
- Duration: ${course.metadata.duration_per_lesson} minutes
- Instructor: ${course.instructor.name} (${course.instructor.email})

## Learning Objectives

1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

## Section 1 — [Title] ([minutes] min)

- 📖 Theory: [content]
- 🖥️ Demo: [content]
- 💻 Hands-on: [content]

## Section 2 — [Title] ([minutes] min)

- 📖 Theory: [content]
- 🖥️ Demo: [content]
- 💻 Hands-on: [content]

## Section 3 — [Title] ([minutes] min)

- 📖 Theory: [content]
- 🖥️ Demo: [content]
- 💻 Hands-on: [content]
`;
}

export function defaultDiscourse(state, lesson) {
  const { course } = state;
  const num = padLessonNumber(lesson.number);
  return `# DISCOURSE — Lesson ${num}: ${lesson.title}

## Context

- Course: ${course.title}
- Module: ${lesson.module || 'Module 1'}
- Language: ${course.metadata.language}
- Duration: ${course.metadata.duration_per_lesson} minutes

## Section 1 — [Title]

### Speaker script

[Write the spoken narrative here]

### Slide cues

- Must-have bullets:
  1. [Bullet 1]
  2. [Bullet 2]
  3. [Bullet 3]

## Section 2 — [Title]

### Speaker script

[Write the spoken narrative here]

## Section 3 — [Title]

### Speaker script

[Write the spoken narrative here]

## Assessment and Wrap-up

- Exit question: [question]
`;
}

export function defaultSlides(state, lesson) {
  const { course } = state;
  const num = padLessonNumber(lesson.number);
  return `---
marp: true
theme: default
paginate: true
size: 16:9
---

# ${lesson.title}

## ${course.title}

**Lesson ${num}**  
${lesson.module || 'Module 1'}

${course.instructor.name}  
${course.instructor.email}

---

# Learning Objectives

1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

---

# Agenda

1. Section 1
2. Section 2
3. Section 3
4. Wrap-up and Q&A

---

# Section 1

## Key idea

[Key idea]

---

# Section 2

## Key idea

[Key idea]

---

# Section 3

## Key idea

[Key idea]

---

# Recap

- [Takeaway 1]
- [Takeaway 2]
- [Takeaway 3]

---

# Q&A

Any questions?
`;
}

export function handoffPrompts(lesson) {
  const num = padLessonNumber(lesson.number);
  return [
    `@discussion-moderator Prepare lesson #${num}: ${lesson.title}`,
    `@lesson-planner Create discourse for lesson #${num}`,
    `@slides-maker Create slides for lesson #${num}`
  ];
}