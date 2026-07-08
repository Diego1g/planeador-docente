const STORAGE_KEY = 'ai-lesson-planner-v1';

export const DEFAULT_STATE = {
  course: {
    title: '',
    instructor: { name: '', email: '' },
    metadata: {
      level: 'Intermediate',
      language: 'English',
      duration_per_lesson: 60,
      audience: ''
    }
  },
  lessons: []
};

export function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return structuredClone(DEFAULT_STATE);
    const parsed = JSON.parse(raw);
    return {
      course: { ...DEFAULT_STATE.course, ...parsed.course, instructor: { ...DEFAULT_STATE.course.instructor, ...parsed.course?.instructor }, metadata: { ...DEFAULT_STATE.course.metadata, ...parsed.course?.metadata } },
      lessons: Array.isArray(parsed.lessons) ? parsed.lessons : []
    };
  } catch {
    return structuredClone(DEFAULT_STATE);
  }
}

export function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

export function resetState() {
  localStorage.removeItem(STORAGE_KEY);
}