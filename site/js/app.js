import { loadState, saveState, resetState } from './storage.js';
import {
  defaultDiscourse,
  defaultHighlights,
  defaultSlides,
  handoffPrompts,
  padLessonNumber,
  slugify,
  statusEmoji
} from './templates.js';
import {
  exportCourseReadme,
  exportFullCourseZip,
  exportLessonBundle,
  exportLessonConfig,
  importLessonConfig
} from './export.js';

let state = loadState();
let activeLessonId = null;

const views = {
  course: document.getElementById('view-course'),
  lessons: document.getElementById('view-lessons'),
  editor: document.getElementById('view-editor'),
  export: document.getElementById('view-export')
};

function persist() {
  saveState(state);
}

function showView(name) {
  Object.entries(views).forEach(([key, el]) => {
    el.hidden = key !== name;
  });
  document.querySelectorAll('[data-nav]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.nav === name);
  });
  location.hash = name;
}

function navigate() {
  const hash = location.hash.replace('#', '') || 'course';
  if (hash === 'editor' && activeLessonId) {
    showView('editor');
    renderEditor();
  } else if (views[hash]) {
    showView(hash);
    if (hash === 'lessons') renderLessons();
    if (hash === 'export') renderExport();
  } else {
    showView('course');
  }
}

function bindCourseForm() {
  const form = document.getElementById('course-form');
  const fields = {
    title: form.querySelector('[name="title"]'),
    name: form.querySelector('[name="instructor_name"]'),
    email: form.querySelector('[name="instructor_email"]'),
    level: form.querySelector('[name="level"]'),
    language: form.querySelector('[name="language"]'),
    duration: form.querySelector('[name="duration"]'),
    audience: form.querySelector('[name="audience"]')
  };

  const sync = () => {
    state.course.title = fields.title.value.trim();
    state.course.instructor.name = fields.name.value.trim();
    state.course.instructor.email = fields.email.value.trim();
    state.course.metadata.level = fields.level.value;
    state.course.metadata.language = fields.language.value;
    state.course.metadata.duration_per_lesson = Number(fields.duration.value) || 60;
    state.course.metadata.audience = fields.audience.value.trim();
    persist();
    updateStats();
  };

  Object.values(fields).forEach((el) => el.addEventListener('input', sync));

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    sync();
    showToast('Course saved');
  });

  fields.title.value = state.course.title;
  fields.name.value = state.course.instructor.name;
  fields.email.value = state.course.instructor.email;
  fields.level.value = state.course.metadata.level;
  fields.language.value = state.course.metadata.language;
  fields.duration.value = state.course.metadata.duration_per_lesson;
  fields.audience.value = state.course.metadata.audience;
}

function updateStats() {
  const total = state.lessons.length;
  const done = state.lessons.filter((l) => l.status === 'completed').length;
  const progress = state.lessons.filter((l) => l.status === 'in-progress').length;
  document.getElementById('stat-total').textContent = total;
  document.getElementById('stat-done').textContent = done;
  document.getElementById('stat-progress').textContent = progress;
}

function addLesson(partial = {}) {
  const number = partial.number ?? state.lessons.length + 1;
  const title = partial.title ?? `Lesson ${number}`;
  const lesson = {
    number,
    id: partial.id ?? slugify(title),
    title,
    module: partial.module ?? `Module ${Math.ceil(number / 3)}`,
    status: partial.status ?? 'not-started',
    artifacts: {
      highlights: partial.artifacts?.highlights ?? '',
      discourse: partial.artifacts?.discourse ?? '',
      slides: partial.artifacts?.slides ?? ''
    }
  };
  state.lessons.push(lesson);
  persist();
  renderLessons();
  updateStats();
}

function scaffoldLessons(count, prefix = 'Lesson') {
  const start = state.lessons.length;
  for (let i = 1; i <= count; i++) {
    const number = start + i;
    const title = `${prefix} ${number}`;
    addLesson({ number, title, id: slugify(title) });
  }
}

function renderLessons() {
  const tbody = document.getElementById('lessons-tbody');
  tbody.innerHTML = '';

  state.lessons
    .slice()
    .sort((a, b) => a.number - b.number)
    .forEach((lesson) => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td><input type="number" min="1" max="99" value="${lesson.number}" data-field="number" aria-label="Lesson number"></td>
        <td><input type="text" value="${lesson.id}" data-field="id" pattern="[a-z0-9-]+" aria-label="Lesson ID"></td>
        <td><input type="text" value="${escapeHtml(lesson.title)}" data-field="title" aria-label="Lesson title"></td>
        <td><input type="text" value="${escapeHtml(lesson.module)}" data-field="module" aria-label="Module"></td>
        <td>
          <select data-field="status" aria-label="Status">
            <option value="not-started" ${lesson.status === 'not-started' ? 'selected' : ''}>Not started</option>
            <option value="in-progress" ${lesson.status === 'in-progress' ? 'selected' : ''}>In progress</option>
            <option value="completed" ${lesson.status === 'completed' ? 'selected' : ''}>Completed</option>
          </select>
        </td>
        <td class="actions">
          <button type="button" class="btn btn-sm" data-action="edit">Edit</button>
          <button type="button" class="btn btn-sm btn-secondary" data-action="scaffold">Scaffold</button>
          <button type="button" class="btn btn-sm btn-danger" data-action="remove">Remove</button>
        </td>
      `;

      tr.querySelectorAll('input, select').forEach((el) => {
        el.addEventListener('change', () => {
          const field = el.dataset.field;
          if (field === 'number') lesson.number = Number(el.value);
          else if (field === 'id') lesson.id = el.value.trim().toLowerCase();
          else lesson[field] = el.value.trim();
          persist();
          updateStats();
        });
      });

      tr.querySelector('[data-action="edit"]').addEventListener('click', () => {
        activeLessonId = lesson.id;
        showView('editor');
        renderEditor();
        location.hash = 'editor';
      });

      tr.querySelector('[data-action="scaffold"]').addEventListener('click', () => {
        lesson.status = 'in-progress';
        if (!lesson.artifacts.highlights) lesson.artifacts.highlights = defaultHighlights(state, lesson);
        if (!lesson.artifacts.discourse) lesson.artifacts.discourse = defaultDiscourse(state, lesson);
        if (!lesson.artifacts.slides) lesson.artifacts.slides = defaultSlides(state, lesson);
        persist();
        renderLessons();
        showToast(`Scaffolded lesson #${padLessonNumber(lesson.number)}`);
      });

      tr.querySelector('[data-action="remove"]').addEventListener('click', () => {
        if (!confirm(`Remove lesson "${lesson.title}"?`)) return;
        state.lessons = state.lessons.filter((l) => l.id !== lesson.id);
        persist();
        renderLessons();
        updateStats();
      });

      tbody.appendChild(tr);
    });
}

function getActiveLesson() {
  return state.lessons.find((l) => l.id === activeLessonId);
}

function renderEditor() {
  const lesson = getActiveLesson();
  if (!lesson) {
    document.getElementById('editor-empty').hidden = false;
    document.getElementById('editor-panel').hidden = true;
    return;
  }

  document.getElementById('editor-empty').hidden = true;
  document.getElementById('editor-panel').hidden = false;

  const num = padLessonNumber(lesson.number);
  document.getElementById('editor-title').textContent = `Lesson ${num}: ${lesson.title}`;
  document.getElementById('editor-status').textContent = statusEmoji(lesson.status);

  const fields = ['highlights', 'discourse', 'slides'];
  fields.forEach((key) => {
    const ta = document.getElementById(`artifact-${key}`);
    ta.value = lesson.artifacts[key] || '';
    ta.oninput = () => {
      lesson.artifacts[key] = ta.value;
      persist();
    };
  });

  const promptsEl = document.getElementById('handoff-prompts');
  promptsEl.innerHTML = handoffPrompts(lesson)
    .map((p) => `<div class="prompt-row"><code>${escapeHtml(p)}</code><button type="button" class="btn btn-sm btn-secondary" data-copy="${escapeAttr(p)}">Copy</button></div>`)
    .join('');

  promptsEl.querySelectorAll('[data-copy]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      await navigator.clipboard.writeText(btn.dataset.copy);
      showToast('Copied to clipboard');
    });
  });
}

function renderExport() {
  document.getElementById('export-summary').textContent =
    `${state.lessons.length} lessons · ${state.course.title || 'Untitled course'}`;
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function escapeAttr(str) {
  return escapeHtml(str).replace(/'/g, '&#39;');
}

function showToast(message) {
  const el = document.getElementById('toast');
  el.textContent = message;
  el.classList.add('show');
  clearTimeout(showToast._timer);
  showToast._timer = setTimeout(() => el.classList.remove('show'), 2400);
}

function bindGlobalActions() {
  document.querySelectorAll('[data-nav]').forEach((btn) => {
    btn.addEventListener('click', () => {
      showView(btn.dataset.nav);
      if (btn.dataset.nav === 'lessons') renderLessons();
      if (btn.dataset.nav === 'export') renderExport();
      location.hash = btn.dataset.nav;
    });
  });

  document.getElementById('btn-add-lesson').addEventListener('click', () => addLesson());
  document.getElementById('btn-bulk-add').addEventListener('click', () => {
    const count = Number(document.getElementById('bulk-count').value) || 1;
    const prefix = document.getElementById('bulk-prefix').value.trim() || 'Lesson';
    scaffoldLessons(count, prefix);
  });
  document.getElementById('btn-scaffold-all').addEventListener('click', () => {
    state.lessons.forEach((lesson) => {
      lesson.status = lesson.status === 'not-started' ? 'in-progress' : lesson.status;
      if (!lesson.artifacts.highlights) lesson.artifacts.highlights = defaultHighlights(state, lesson);
      if (!lesson.artifacts.discourse) lesson.artifacts.discourse = defaultDiscourse(state, lesson);
      if (!lesson.artifacts.slides) lesson.artifacts.slides = defaultSlides(state, lesson);
    });
    persist();
    renderLessons();
    showToast('All lessons scaffolded');
  });

  document.getElementById('btn-init-templates').addEventListener('click', () => {
    const lesson = getActiveLesson();
    if (!lesson) return;
    lesson.artifacts.highlights = defaultHighlights(state, lesson);
    lesson.artifacts.discourse = defaultDiscourse(state, lesson);
    lesson.artifacts.slides = defaultSlides(state, lesson);
    persist();
    renderEditor();
    showToast('Templates reset');
  });

  document.getElementById('btn-export-config').addEventListener('click', () => exportLessonConfig(state));
  document.getElementById('btn-export-readme').addEventListener('click', () => exportCourseReadme(state));
  document.getElementById('btn-export-zip').addEventListener('click', () => exportFullCourseZip(state));
  document.getElementById('btn-export-lesson').addEventListener('click', () => {
    const lesson = getActiveLesson();
    if (lesson) exportLessonBundle(state, lesson);
  });

  document.getElementById('import-config').addEventListener('change', async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    try {
      const imported = await importLessonConfig(file);
      state = { ...state, ...imported };
      persist();
      bindCourseForm();
      renderLessons();
      updateStats();
      showToast('Config imported');
    } catch (err) {
      alert(err.message || 'Import failed');
    }
    e.target.value = '';
  });

  document.getElementById('btn-reset').addEventListener('click', () => {
    if (!confirm('Reset all course data? This cannot be undone.')) return;
    resetState();
    state = loadState();
    activeLessonId = null;
    bindCourseForm();
    renderLessons();
    renderEditor();
    updateStats();
    showToast('Data reset');
  });

  document.querySelectorAll('[data-tab]').forEach((btn) => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('[data-tab]').forEach((b) => b.classList.remove('active'));
      document.querySelectorAll('[data-panel]').forEach((p) => p.hidden = true);
      btn.classList.add('active');
      document.getElementById(btn.dataset.tab).hidden = false;
    });
  });
}

bindCourseForm();
bindGlobalActions();
updateStats();
window.addEventListener('hashchange', navigate);
navigate();