#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${BUILD_DIR}/.." && pwd)"
# shellcheck source=git-metadata.sh
source "${BUILD_DIR}/git-metadata.sh"

usage() {
  echo "usage: $0 [cover|no-cover|all] [en]" >&2
  exit 2
}

MODE="all"
SUBDIR=""
if [[ $# -eq 1 ]]; then
  case "$1" in
    cover|no-cover|all) MODE="$1" ;;
    en) SUBDIR="en" ;;
    *) usage ;;
  esac
elif [[ $# -eq 2 ]]; then
  MODE="$1"
  SUBDIR="$2"
elif [[ $# -gt 2 ]]; then
  usage
fi

case "${MODE}" in
  cover|no-cover|all) ;;
  *) usage ;;
esac

if [[ -z "${SUBDIR}" ]]; then
  if [[ "$(basename "$(pwd)")" == "en" ]]; then
    SUBDIR="en"
  fi
fi

case "${SUBDIR}" in
  ""|en) ;;
  *) usage ;;
esac

if [[ "${SUBDIR}" == "en" ]]; then
  SRC_DIR="${ROOT_DIR}/en"
  PREFIX="ossdbtext_en_"
  TEMPLATE="../template.tex"
else
  SRC_DIR="${ROOT_DIR}"
  PREFIX="ossdbtext_"
  TEMPLATE="template.tex"
fi

OUT_DIR="${ROOT_DIR}/tmp"
VER="$(grep -oP 'Ver\.\d+\.\d+\.\d+' "${SRC_DIR}/config-pdf.yaml" | head -1 | sed 's/^Ver\.//')"
OUTPUT_PDF="${OUT_DIR}/${PREFIX}${VER}.pdf"
OUTPUT_NO_COVER="${OUT_DIR}/${PREFIX}${VER}_no_cover.pdf"

if ! command -v pandoc >/dev/null 2>&1 || ! command -v lualatex >/dev/null 2>&1; then
  if [[ -n "${SUBDIR}" ]]; then
    exec "${BUILD_DIR}/with-build-image.sh" "./build/build-pdf.sh ${MODE} ${SUBDIR}"
  fi
  exec "${BUILD_DIR}/with-build-image.sh" "./build/build-pdf.sh ${MODE}"
fi

mkdir -p "${OUT_DIR}"

chapters=()
while IFS= read -r -d '' f; do
  chapters+=("$(basename "${f}")")
done < <(find "${SRC_DIR}" -maxdepth 1 -type f -name 'Chapter*.md' ! -name 'Chapter00.md' -print0 | LC_ALL=C sort -z)

if ((${#chapters[@]} == 0)); then
  echo "no chapter markdown files found in ${SRC_DIR}" >&2
  exit 1
fi

build_one() {
  local no_cover="$1"
  local output="$2"
  local -a extra=()
  if [[ "${no_cover}" == "1" ]]; then
    extra=(-M no-cover=true)
  fi
  if meta="$(git_build_metadata "${ROOT_DIR}" 2>/dev/null)"; then
    extra+=(-M "keywords=${meta}")
  fi
  pandoc Chapter00.md -o preface.tex
  pandoc -d config-pdf.yaml --template "${TEMPLATE}" -B preface.tex "${chapters[@]}" \
    "${extra[@]}" -o "${output}"
  rm -f preface.tex
  echo "Output: ${output}"
  ls -lh "${output}"
}

(
  cd "${SRC_DIR}"
  case "${MODE}" in
    cover)
      build_one 0 "${OUTPUT_PDF}"
      ;;
    no-cover)
      build_one 1 "${OUTPUT_NO_COVER}"
      ;;
    all)
      build_one 0 "${OUTPUT_PDF}"
      build_one 1 "${OUTPUT_NO_COVER}"
      ;;
  esac
)
