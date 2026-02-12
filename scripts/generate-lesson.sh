#!/bin/bash

# Wrapper script to create a lesson and update the index
# Usage: ./scripts/generate-lesson.sh <number> <id> "<title>"
# Example: ./scripts/generate-lesson.sh 01 introduction-agents "Introduzione agli Agenti AI"

set -e

# Source common functions and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Verify parameters
if [ $# -lt 3 ]; then
    log_error "Insufficient parameters"
    echo "Usage: $0 <number> <id> \"<title>\""
    echo ""
    echo "Example:"
    echo "  $0 01 introduction-agents \"Introduzione agli Agenti AI\""
    exit 1
fi

LESSON_NUMBER=$1
LESSON_ID=$2
LESSON_TITLE=$3

# Base directories
PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
LESSONS_DIR="$(get_lessons_dir "$PROJECT_ROOT")"
README_FILE="$LESSONS_DIR/README.md"

log_info "Starting lesson generation #${LESSON_NUMBER}: ${LESSON_TITLE}"

# 1. Create lesson structure
log_info "Step 1/2: Creating directory structure..."
"$SCRIPT_DIR/create-lesson-structure.sh" "$LESSON_NUMBER" "$LESSON_ID" "$LESSON_TITLE"

if [ $? -ne 0 ]; then
    log_error "Error creating structure"
    exit 1
fi

# 2. Update README with "In Progress" status
log_info "Step 2/2: Updating course index..."

if [ ! -f "$README_FILE" ]; then
    log_error "README.md file not found: $README_FILE"
    exit 1
fi

# Find the corresponding lesson line and update status
# Pattern: | XX | `lesson-id` | Title | ... | ⏳ Da iniziare |
# Replace with: | XX | `lesson-id` | Title | ... | 🔄 In corso |

# Use sed to update status (Linux/macOS compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/| ${LESSON_NUMBER} | \`${LESSON_ID}\` | \(.*\) | \(.*\) | ⏳ Da iniziare |/| ${LESSON_NUMBER} | \`${LESSON_ID}\` | \1 | \2 | 🔄 In corso |/g" "$README_FILE"
else
    # Linux
    sed -i "s/| ${LESSON_NUMBER} | \`${LESSON_ID}\` | \(.*\) | \(.*\) | ⏳ Da iniziare |/| ${LESSON_NUMBER} | \`${LESSON_ID}\` | \1 | \2 | 🔄 In corso |/g" "$README_FILE"
fi

log_success "Course index updated"

# 3. Update JSON configuration file
CONFIG_FILE="$PROJECT_ROOT/.lesson-config.json"

if has_jq; then
    log_info "Updating JSON configuration..."
    
    # Create a temporary file with updated status
    jq "(.lessons[] | select(.number == $LESSON_NUMBER) | .status) = \"in-progress\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    
    log_success "JSON configuration updated"
else
    log_info "jq not available, skipping JSON update (manual update required)"
fi

# Final summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "Lesson #${LESSON_NUMBER} setup completed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 README updated: $README_FILE"
echo "⚙️  Config updated: $CONFIG_FILE"
echo ""
echo "✨ Next steps to generate content:"
echo ""
echo "1️⃣  Generate HIGHLIGHTS (required):"
echo "   @discussion-moderator Prepara la lezione #${LESSON_NUMBER}: ${LESSON_TITLE}"
echo ""
echo "2️⃣  Generate DISCOURSE (optional):"
echo "   @lesson-planner Crea il discourse per la lezione #${LESSON_NUMBER}"
echo ""
echo "3️⃣  Generate SLIDES (required):"
echo "   @slides-maker Crea le slides per la lezione #${LESSON_NUMBER}"
echo ""
echo "4️⃣  Export PDF:"
echo "   ./scripts/generate-slides-pdf.sh lessons/lesson-${LESSON_NUMBER}-${LESSON_ID}"
echo ""
echo "5️⃣  When complete, update status to ✅:"
echo "   Manually edit $README_FILE"
echo "   Change status from '🔄 In corso' to '✅ Completata'"
echo ""
log_success "Good work! 🚀"
