#!/bin/bash

# Script to create directory structure for a single lesson
# Usage: ./scripts/create-lesson-structure.sh <number> <id> "<title>"
# Example: ./scripts/create-lesson-structure.sh 01 introduction-agents "Introduzione agli Agenti AI"

set -e

# Source common functions and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Verify parameters
if [ $# -lt 3 ]; then
    log_error "Insufficient parameters"
    echo "Usage: $0 <number> <id> \"<title>\""
    echo ""
    echo "Parameters:"
    echo "  <number>   : Lesson number (e.g.: 01, 02, ..., 23)"
    echo "  <id>       : Lesson identifier (e.g.: introduction-agents)"
    echo "  <title>    : Full lesson title (in quotes)"
    echo ""
    echo "Example:"
    echo "  $0 01 introduction-agents \"Introduzione agli Agenti AI\""
    exit 1
fi

LESSON_NUMBER=$1
LESSON_ID=$2
LESSON_TITLE=$3

# Lesson number validation
if ! [[ "$LESSON_NUMBER" =~ ^[0-9]{2}$ ]]; then
    log_error "Lesson number must be two digits (01-23)"
    exit 1
fi

if [ "$LESSON_NUMBER" -lt 1 ] || [ "$LESSON_NUMBER" -gt 23 ]; then
    log_error "Lesson number must be between 01 and 23"
    exit 1
fi

# Lesson ID validation
if ! [[ "$LESSON_ID" =~ ^[a-z0-9-]+$ ]]; then
    log_error "Lesson ID must contain only lowercase letters, numbers and hyphens"
    exit 1
fi

# Base directories
PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
LESSONS_DIR="$(get_lessons_dir "$PROJECT_ROOT")"
LESSON_DIR="$LESSONS_DIR/lesson-${LESSON_NUMBER}-${LESSON_ID}"

log_info "Creating structure for lesson #${LESSON_NUMBER}: ${LESSON_TITLE}"
log_info "Directory: $LESSON_DIR"

# Check if directory already exists
if [ -d "$LESSON_DIR" ]; then
    log_warning "Directory $LESSON_DIR already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled"
        exit 0
    fi
    log_info "Removing existing directory..."
    rm -rf "$LESSON_DIR"
fi

# Create directory structure
log_info "Creating directory structure..."
mkdir -p "$LESSON_DIR/.lesson/artifacts/highlights"
mkdir -p "$LESSON_DIR/.lesson/artifacts/discourse"
mkdir -p "$LESSON_DIR/.lesson/artifacts/slides"

# Read common metadata
CONFIG_FILE="$PROJECT_ROOT/.lesson-config.json"
METADATA_FILE="$LESSONS_DIR/COURSE_METADATA.md"

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Extract metadata from JSON
if has_jq; then
    INSTRUCTOR_NAME=$(get_config_value "$CONFIG_FILE" '.course.instructor.name')
    INSTRUCTOR_EMAIL=$(get_config_value "$CONFIG_FILE" '.course.instructor.email')
    LEVEL=$(get_config_value "$CONFIG_FILE" '.course.metadata.level')
    LANGUAGE=$(get_config_value "$CONFIG_FILE" '.course.metadata.language')
    DURATION=$(get_config_value "$CONFIG_FILE" '.course.metadata.duration_per_lesson')
    MODULE=$(get_config_value "$CONFIG_FILE" ".lessons[] | select(.number == $LESSON_NUMBER) | .module")
else
    # Fallback values when jq is not available
    log_warning "jq not found, using default values"
    INSTRUCTOR_NAME="N/A"
    INSTRUCTOR_EMAIL="N/A"
    LEVEL="Avanzato"
    LANGUAGE="Italiano"
    DURATION="60"
    MODULE="N/A"
fi

# Create lesson README.md
log_info "Creating lesson README.md..."
cat > "$LESSON_DIR/README.md" << EOF
# Lezione ${LESSON_NUMBER}: ${LESSON_TITLE}

**Corso**: Approcci Agentici nell'Intelligenza Artificiale  
**Modulo**: ${MODULE}  
**Durata**: ${DURATION} minuti  
**Livello**: ${LEVEL}  
**Lingua**: ${LANGUAGE}

---

## 👤 Istruttore

**${INSTRUCTOR_NAME}**  
📧 ${INSTRUCTOR_EMAIL}

---

## 📋 Informazioni sulla Lezione

### Status
⏳ **Da iniziare**

### Prerequisiti
<!-- Aggiungere qui i prerequisiti specifici per questa lezione -->
- Completamento lezioni precedenti (se applicabile)
- Conoscenze richieste (da specificare)

### Obiettivi di Apprendimento
<!-- Questi verranno popolati dal discussion-moderator -->
Al termine di questa lezione, lo studente sarà in grado di:
1. [Da definire]
2. [Da definire]
3. [Da definire]

---

## 📂 Struttura dei File

\`\`\`
lesson-${LESSON_NUMBER}-${LESSON_ID}/
├── README.md                           # Questo file
├── SLIDES.pdf                          # Presentazione esportata (generato)
└── .lesson/
    └── artifacts/
        ├── highlights/                 # Piano strutturato
        │   ├── 01-section.md
        │   └── ...
        ├── discourse/                  # Narrazione dettagliata
        │   ├── README.md
        │   ├── 01-section.md
        │   └── ...
        └── slides/                     # Sorgenti MARP
            ├── 00-header.md
            ├── 01-title.md
            └── ...
\`\`\`

---

## 🚀 Come Generare i Contenuti

### 1. Generare Highlights
\`\`\`
@discussion-moderator Prepara la lezione #${LESSON_NUMBER}: ${LESSON_TITLE}
\`\`\`

### 2. Generare Discourse (opzionale)
\`\`\`
@lesson-planner Crea il discourse per la lezione #${LESSON_NUMBER}
\`\`\`

### 3. Generare Slides
\`\`\`
@slides-maker Crea le slides per la lezione #${LESSON_NUMBER}
\`\`\`

### 4. Esportare PDF
\`\`\`bash
cd /workspaces/ai-lesson-template
./scripts/generate-slides-pdf.sh lessons/lesson-${LESSON_NUMBER}-${LESSON_ID}
\`\`\`

---

## 📊 Contenuti della Lezione

_(Questa sezione verrà popolata dopo la generazione degli highlights)_

### Sezioni
1. [Da definire]
2. [Da definire]
3. [Da definire]

### Tipologie di Contenuto
- 📖 **Teoria**: Concetti fondamentali
- 🖥️ **Demo**: Dimostrazioni pratiche
- 💻 **Hands-on**: Esercizi interattivi
- 💰 **Cost Tips**: Ottimizzazioni e costi

---

## 📝 Note

_(Aggiungi qui note specifiche per questa lezione)_

---

## 🔗 Collegamenti

- [Indice del Corso](../README.md)
- [Metadati del Corso](../COURSE_METADATA.md)
- [Configurazione](./../.lesson-config.json)

---

**Creato**: $(date +%Y-%m-%d)  
**Ultimo aggiornamento**: $(date +%Y-%m-%d)
EOF

# Create .gitkeep files to maintain empty directories in git
log_info "Creating .gitkeep files..."
touch "$LESSON_DIR/.lesson/artifacts/highlights/.gitkeep"
touch "$LESSON_DIR/.lesson/artifacts/discourse/.gitkeep"
touch "$LESSON_DIR/.lesson/artifacts/slides/.gitkeep"

# Create local lesson configuration file
log_info "Creating local lesson configuration..."
cat > "$LESSON_DIR/.lesson/config.json" << EOF
{
  "lesson": {
    "number": ${LESSON_NUMBER},
    "id": "${LESSON_ID}",
    "title": "${LESSON_TITLE}",
    "module": "${MODULE}",
    "status": "not-started",
    "metadata": {
      "level": "${LEVEL}",
      "language": "${LANGUAGE}",
      "duration": ${DURATION}
    },
    "instructor": {
      "name": "${INSTRUCTOR_NAME}",
      "email": "${INSTRUCTOR_EMAIL}"
    },
    "created": "$(date -I)",
    "last_updated": "$(date -I)"
  }
}
EOF

# Final summary
log_success "Lesson structure created successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Lezione #${LESSON_NUMBER}: ${LESSON_TITLE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 Directory: $LESSON_DIR"
echo "👤 Istruttore: ${INSTRUCTOR_NAME}"
echo "📧 Email: ${INSTRUCTOR_EMAIL}"
echo "🎓 Livello: ${LEVEL}"
echo "🌍 Lingua: ${LANGUAGE}"
echo "⏱️  Durata: ${DURATION} minuti"
echo "📚 Modulo: ${MODULE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ Next steps:"
echo "1. Generate highlights: @discussion-moderator Prepara la lezione #${LESSON_NUMBER}"
echo "2. Generate discourse: @lesson-planner (optional)"
echo "3. Generate slides: @slides-maker"
echo "4. Export PDF: ./scripts/generate-slides-pdf.sh $LESSON_DIR"
echo ""
log_success "Ready to generate content!"
