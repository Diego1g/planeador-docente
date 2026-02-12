#!/bin/bash

# Script to scaffold all lesson folders for a course using .lesson-config.json
# Usage: ./scripts/generate-course-scaffolding.sh [--force]
# Example: ./scripts/generate-course-scaffolding.sh --force

set -e

# Source common functions and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

FORCE_OVERWRITE=false

if [ "$#" -gt 1 ]; then
    log_error "Too many arguments"
    echo "Usage: $0 [--force]"
    exit 1
fi

if [ "$#" -eq 1 ]; then
    if [ "$1" = "--force" ]; then
        FORCE_OVERWRITE=true
    else
        log_error "Unknown option: $1"
        echo "Usage: $0 [--force]"
        exit 1
    fi
fi

PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
LESSONS_DIR="$(get_lessons_dir "$PROJECT_ROOT")"
CONFIG_FILE="$PROJECT_ROOT/.lesson-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Configuration file not found: $CONFIG_FILE"
    log_info "Generate or update it first with @course-planner"
    exit 1
fi

if ! has_jq; then
    log_error "jq is required to scaffold a full course"
    log_info "Install jq, then retry"
    exit 1
fi

LESSON_COUNT=$(jq '.lessons | length' "$CONFIG_FILE")
if [ "$LESSON_COUNT" -eq 0 ]; then
    log_warning "No lessons found in $CONFIG_FILE"
    exit 0
fi

mkdir -p "$LESSONS_DIR"

log_info "Starting full course scaffolding from $CONFIG_FILE"
log_info "Total lessons to process: $LESSON_COUNT"
if [ "$FORCE_OVERWRITE" = true ]; then
    log_warning "Force mode enabled: existing lesson folders will be overwritten"
fi

CREATED=0
SKIPPED=0
FAILED=0

while IFS='|' read -r RAW_NUMBER LESSON_ID LESSON_TITLE; do
    LESSON_NUMBER=$(printf "%02d" "$RAW_NUMBER")
    LESSON_DIR="$LESSONS_DIR/lesson-${LESSON_NUMBER}-${LESSON_ID}"

    log_info "Processing lesson #${LESSON_NUMBER}: ${LESSON_TITLE}"

    if [ -d "$LESSON_DIR" ]; then
        if [ "$FORCE_OVERWRITE" = true ]; then
            log_warning "Overwriting existing directory: $LESSON_DIR"
            rm -rf "$LESSON_DIR"
        else
            log_warning "Skipping existing directory: $LESSON_DIR"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi
    fi

    if "$SCRIPT_DIR/create-lesson-structure.sh" "$LESSON_NUMBER" "$LESSON_ID" "$LESSON_TITLE"; then
        CREATED=$((CREATED + 1))
    else
        log_error "Failed to scaffold lesson #${LESSON_NUMBER}: ${LESSON_TITLE}"
        FAILED=$((FAILED + 1))
    fi
done < <(jq -r '.lessons[] | "\(.number)|\(.id)|\(.title)"' "$CONFIG_FILE")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Course scaffolding summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Created: $CREATED"
echo "⏭️  Skipped: $SKIPPED"
echo "❌ Failed: $FAILED"
echo "📂 Lessons directory: $LESSONS_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAILED" -gt 0 ]; then
    log_error "Course scaffolding completed with errors"
    exit 1
fi

log_success "Course scaffolding completed successfully"
