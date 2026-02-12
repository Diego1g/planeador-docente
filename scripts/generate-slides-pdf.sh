#!/bin/bash

# This script generates a PDF from a generated set of markdown slides using MARP
# Usage: ./scripts/generate-slides-pdf.sh [lesson-path]
# 
# If lesson-path is not specified, uses current directory
# If lesson-path is specified, uses that directory to find slides
#
# Example 1 (from repo root, current directory):
#   ./scripts/generate-slides-pdf.sh
#
# Example 2 (from repo root, specify lesson):
#   ./scripts/generate-slides-pdf.sh lessons/lesson-01-introduction-agents
#
# Example 3 (from lesson directory):
#   cd lessons/lesson-01-introduction-agents
#   ../../scripts/generate-slides-pdf.sh

set -e

# Source common functions and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Determine working directory
if [ $# -eq 0 ]; then
    # No parameter: use current directory
    WORK_DIR="$(pwd)"
    log_info "No path specified, using current directory: $WORK_DIR"
else
    # Parameter specified: use that directory
    LESSON_PATH=$1
    
    # Convert to absolute path if relative
    if [[ "$LESSON_PATH" = /* ]]; then
        WORK_DIR="$LESSON_PATH"
    else
        WORK_DIR="$(pwd)/$LESSON_PATH"
    fi
    
    log_info "Lesson path specified: $WORK_DIR"
fi

# Verify directory exists
if [ ! -d "$WORK_DIR" ]; then
    log_error "Directory not found: $WORK_DIR"
    exit 1
fi

# Determine slides path
SLIDES_DIR="$WORK_DIR/.lesson/artifacts/slides"
OUTPUT_PDF="$WORK_DIR/SLIDES.pdf"

# Verify slides directory exists
if [ ! -d "$SLIDES_DIR" ]; then
    log_error "Slides directory not found: $SLIDES_DIR"
    log_error "Make sure to generate slides before exporting PDF"
    exit 1
fi

# Verify there are markdown files in slides directory
SLIDE_COUNT=$(find "$SLIDES_DIR" -name "*.md" -type f | wc -l)
if [ "$SLIDE_COUNT" -eq 0 ]; then
    log_error "No markdown files found in: $SLIDES_DIR"
    log_error "Generate slides using @slides-maker before exporting PDF"
    exit 1
fi

log_info "Found $SLIDE_COUNT markdown files in $SLIDES_DIR"
log_info "Generating PDF with MARP..."

# Concatenate all markdown files and generate PDF
# Files are processed in alphabetical order (00-header.md, 01-title.md, etc.)
cat "$SLIDES_DIR"/*.md | marp - --pdf --allow-local-files -o "$OUTPUT_PDF"

if [ $? -eq 0 ]; then
    FILE_SIZE=$(du -h "$OUTPUT_PDF" | cut -f1)
    log_success "PDF generato con successo!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 PDF Output: $OUTPUT_PDF"
    echo "📊 Dimensione: $FILE_SIZE"
    echo "📑 Slide files: $SLIDE_COUNT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_success "Ready for presentation! 🎉"
else
    log_error "Error during PDF generation"
    exit 1
fi