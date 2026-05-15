#!/usr/bin/env bash
# validate-translation.sh
# Checks structural consistency between Japanese (JP) and English (EN) chapter files.
#
# Usage:
#   ./scripts/validate-translation.sh [chapter]
#   ./scripts/validate-translation.sh            # check all chapters
#   ./scripts/validate-translation.sh Chapter02  # check single chapter
#
# Exit codes:
#   0 = all checks passed
#   1 = one or more checks failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
JP_DIR="${REPO_ROOT}"
EN_DIR="${REPO_ROOT}/en"
GLOSSARY="${EN_DIR}/GLOSSARY.md"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

pass()    { echo -e "  ${GREEN}PASS${NC}  $1"; }
fail()    { echo -e "  ${RED}FAIL${NC}  $1"; ERRORS=$((ERRORS+1)); }
warn()    { echo -e "  ${YELLOW}WARN${NC}  $1"; WARNINGS=$((WARNINGS+1)); }

check_chapter() {
    local chapter="$1"   # e.g. "Chapter02"
    local jp="${JP_DIR}/${chapter}.md"
    local en="${EN_DIR}/${chapter}.md"

    echo ""
    echo "=== ${chapter} ==="

    # File existence
    if [[ ! -f "${jp}" ]]; then
        fail "JP file not found: ${jp}"
        return
    fi
    if [[ ! -f "${en}" ]]; then
        fail "EN file not found: ${en} (not yet translated)"
        return
    fi

    # 1. Heading count must match
    local jp_headings en_headings
    jp_headings=$(grep -c '^#' "${jp}" || true)
    en_headings=$(grep -c '^#' "${en}" || true)
    if [[ "${jp_headings}" -eq "${en_headings}" ]]; then
        pass "Heading count: JP=${jp_headings}, EN=${en_headings}"
    else
        fail "Heading count mismatch: JP=${jp_headings}, EN=${en_headings}"
    fi

    # 2. Heading depth profile must match (compare sorted heading prefixes)
    local jp_profile en_profile
    jp_profile=$(grep '^#' "${jp}" | sed 's/[^#].*$//' | sort | uniq -c | sort -k2)
    en_profile=$(grep '^#' "${en}" | sed 's/[^#].*$//' | sort | uniq -c | sort -k2)
    if [[ "${jp_profile}" == "${en_profile}" ]]; then
        pass "Heading depth profile matches"
    else
        fail "Heading depth profile mismatch:"
        echo "      JP: $(echo "${jp_profile}" | tr '\n' '|')"
        echo "      EN: $(echo "${en_profile}" | tr '\n' '|')"
    fi

    # 3. Code block count must match (and be even)
    # Use awk instead of grep to avoid GNU grep treating \` as a start-of-buffer anchor
    local jp_codeblocks en_codeblocks
    jp_codeblocks=$(awk '/^```/{n++} END{print n+0}' "${jp}")
    en_codeblocks=$(awk '/^```/{n++} END{print n+0}' "${en}")
    if [[ "${jp_codeblocks}" -eq "${en_codeblocks}" ]]; then
        pass "Code block markers: JP=${jp_codeblocks}, EN=${en_codeblocks}"
    else
        fail "Code block marker count mismatch: JP=${jp_codeblocks}, EN=${en_codeblocks}"
    fi
    if (( en_codeblocks % 2 != 0 )); then
        fail "EN code block markers are not even (${en_codeblocks}) - unclosed block?"
    fi

    # 4. Pandoc attributes count must match {.xxx}
    local jp_attrs en_attrs
    jp_attrs=$(grep -c '{\..*}' "${jp}" || true)
    en_attrs=$(grep -c '{\..*}' "${en}" || true)
    if [[ "${jp_attrs}" -eq "${en_attrs}" ]]; then
        pass "Pandoc attributes count: JP=${jp_attrs}, EN=${en_attrs}"
    else
        fail "Pandoc attributes count mismatch: JP=${jp_attrs}, EN=${en_attrs}"
    fi

    # 5. Check for Japanese characters remaining in EN prose (outside code blocks)
    # Extract non-code-block lines and check for CJK unicode range
    local jp_chars_in_en
    jp_chars_in_en=$(python3 - "${en}" <<'PYEOF'
import sys, re
in_code = False
jp_lines = []
with open(sys.argv[1], encoding='utf-8') as f:
    for i, line in enumerate(f, 1):
        if line.startswith('```'):
            in_code = not in_code
            continue
        if not in_code:
            # CJK Unified Ideographs, Hiragana, Katakana ranges
            if re.search(r'[\u3000-\u9fff\uff00-\uffef]', line):
                jp_lines.append(f"  line {i}: {line.rstrip()}")
print('\n'.join(jp_lines))
PYEOF
    )
    if [[ -z "${jp_chars_in_en}" ]]; then
        pass "No Japanese characters in EN prose"
    else
        warn "Japanese characters found in EN prose (may be intentional in examples):"
        echo "${jp_chars_in_en}" | head -10
    fi

    # 6. Glossary term consistency check: JP terms should not appear as-is in EN prose
    if [[ -f "${GLOSSARY}" ]]; then
        local glossary_violations=""
        while IFS='|' read -r jp_term en_term notes; do
            jp_term="${jp_term// /}"
            # Skip header rows and empty lines
            [[ "${jp_term}" =~ ^[-=|#\ ]*$ ]] && continue
            [[ -z "${jp_term}" ]] && continue
            [[ "${jp_term}" == "Japanese" ]] && continue
            # Check if JP term appears in EN prose (outside code blocks)
            if grep -q "${jp_term}" "${en}" 2>/dev/null; then
                local occurrences
                occurrences=$(grep -c "${jp_term}" "${en}" || true)
                glossary_violations+="    '${jp_term}' found ${occurrences}x\n"
            fi
        done < <(grep '|' "${GLOSSARY}" | grep -v '```')
        if [[ -z "${glossary_violations}" ]]; then
            pass "No glossary JP terms in EN text"
        else
            warn "Glossary JP terms found in EN text (check if in code blocks):"
            echo -e "${glossary_violations}" | head -10
        fi
    fi

    # 7. Line count ratio (EN should be 40-130% of JP)
    local jp_lines en_lines ratio
    jp_lines=$(wc -l < "${jp}")
    en_lines=$(wc -l < "${en}")
    if [[ "${jp_lines}" -gt 0 ]]; then
        ratio=$(awk "BEGIN{printf \"%.1f\", ${en_lines}*100/${jp_lines}}")
        ok=$(awk "BEGIN{print (${ratio}>=40 && ${ratio}<=130) ? 1 : 0}")
        if [[ "${ok}" -eq 1 ]]; then
            pass "Line count ratio: EN/JP = ${ratio}% (JP=${jp_lines}, EN=${en_lines})"
        else
            warn "Unusual line count ratio: EN/JP = ${ratio}% (JP=${jp_lines}, EN=${en_lines})"
        fi
    fi
}

# Main
TARGET="${1:-}"

if [[ -n "${TARGET}" ]]; then
    check_chapter "${TARGET}"
else
    for jp_file in "${JP_DIR}"/Chapter*.md; do
        chapter=$(basename "${jp_file}" .md)
        check_chapter "${chapter}"
    done
fi

echo ""
echo "================================================"
if [[ "${ERRORS}" -eq 0 && "${WARNINGS}" -eq 0 ]]; then
    echo -e "${GREEN}All checks passed.${NC}"
elif [[ "${ERRORS}" -eq 0 ]]; then
    echo -e "${YELLOW}Passed with ${WARNINGS} warning(s).${NC}"
else
    echo -e "${RED}FAILED: ${ERRORS} error(s), ${WARNINGS} warning(s).${NC}"
fi
echo "================================================"

exit "${ERRORS}"
