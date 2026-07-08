import {
  buildCourseReadme,
  buildLessonConfig,
  buildLessonReadme,
  padLessonNumber
} from './templates.js';

function downloadText(filename, content, mime = 'text/plain') {
  const blob = new Blob([content], { type: mime });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

export function exportLessonConfig(state) {
  downloadText('.lesson-config.json', JSON.stringify(buildLessonConfig(state), null, 2), 'application/json');
}

export function exportCourseReadme(state) {
  downloadText('lessons-README.md', buildCourseReadme(state), 'text/markdown');
}

export function exportLessonBundle(state, lesson) {
  const num = padLessonNumber(lesson.number);
  const base = `lesson-${num}-${lesson.id}`;

  downloadText(`${base}-README.md`, buildLessonReadme(state, lesson), 'text/markdown');

  setTimeout(() => {
    downloadText(`${base}-HIGHLIGHTS.md`, lesson.artifacts?.highlights || '', 'text/markdown');
  }, 200);
  setTimeout(() => {
    downloadText(`${base}-DISCOURSE.md`, lesson.artifacts?.discourse || '', 'text/markdown');
  }, 400);
  setTimeout(() => {
    downloadText(`${base}-SLIDES.md`, lesson.artifacts?.slides || '', 'text/markdown');
  }, 600);
}

export async function exportFullCourseZip(state) {
  const JSZip = (await import('https://cdn.jsdelivr.net/npm/jszip@3.10.1/+esm')).default;
  const zip = new JSZip();

  zip.file('.lesson-config.json', JSON.stringify(buildLessonConfig(state), null, 2));
  zip.file('lessons/README.md', buildCourseReadme(state));

  for (const lesson of state.lessons) {
    const num = padLessonNumber(lesson.number);
    const folder = `lessons/lesson-${num}-${lesson.id}`;
    zip.file(`${folder}/README.md`, buildLessonReadme(state, lesson));
    zip.file(`${folder}/.lesson/artifacts/highlights/HIGHLIGHTS.md`, lesson.artifacts?.highlights || '');
    zip.file(`${folder}/.lesson/artifacts/discourse/DISCOURSE.md`, lesson.artifacts?.discourse || '');
    zip.file(`${folder}/.lesson/artifacts/slides/SLIDES.md`, lesson.artifacts?.slides || '');
    zip.file(`${folder}/.lesson/config.json`, JSON.stringify({
      lesson: {
        number: lesson.number,
        id: lesson.id,
        title: lesson.title,
        module: lesson.module,
        status: lesson.status
      }
    }, null, 2));
  }

  const blob = await zip.generateAsync({ type: 'blob' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${(state.course.title || 'course').replace(/[^a-z0-9]+/gi, '-').toLowerCase()}-export.zip`;
  a.click();
  URL.revokeObjectURL(url);
}

export function importLessonConfig(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const data = JSON.parse(reader.result);
        if (!data.course || !Array.isArray(data.lessons)) {
          reject(new Error('Invalid .lesson-config.json structure'));
          return;
        }
        resolve({
          course: data.course,
          lessons: data.lessons.map((l) => ({
            ...l,
            artifacts: l.artifacts || { highlights: '', discourse: '', slides: '' }
          }))
        });
      } catch (err) {
        reject(err);
      }
    };
    reader.onerror = () => reject(reader.error);
    reader.readAsText(file);
  });
}