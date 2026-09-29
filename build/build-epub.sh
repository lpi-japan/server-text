#!/usr/bin/env bash
set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${TOOL_DIR}/.." && pwd)"
# shellcheck source=git-metadata.sh
source "${TOOL_DIR}/git-metadata.sh"

usage() {
  echo "usage: $0 <main|ubuntu|main-en>" >&2
  exit 2
}

VARIANT="${1:-}"
if [[ -z "${VARIANT}" ]]; then
  base="$(basename "$(pwd)")"
  case "${base}" in
    main|ubuntu|main-en) VARIANT="${base}" ;;
    *) usage ;;
  esac
fi

case "${VARIANT}" in
  main|ubuntu|main-en) ;;
  *) usage ;;
esac

SRC_DIR="${ROOT_DIR}/${VARIANT}"
OUT_DIR="${ROOT_DIR}/tmp"
HL_CSS_KINDLE="${OUT_DIR}/.highlighting-kindle.css"
VER="$(grep -oP 'Ver\.\d+\.\d+\.\d+' "${SRC_DIR}/config-epub.yaml" | head -1 | sed 's/^Ver\.//')"
OUTPUT="${OUT_DIR}/servertext_${VARIANT}_${VER}.epub"
EPUB_BUILD="${SRC_DIR}/.epub-build"

if [[ "${VARIANT}" == "main-en" ]]; then
  CROSSREF="../crossref-en.yaml"
else
  CROSSREF="../crossref.yaml"
fi

if ! command -v pandoc >/dev/null 2>&1 || ! command -v pandoc-crossref >/dev/null 2>&1; then
  exec "${TOOL_DIR}/with-build-image.sh" "./build/build-epub.sh ${VARIANT}"
fi

mkdir -p "${OUT_DIR}" "${EPUB_BUILD}"
rm -rf "${EPUB_BUILD:?}/"*

# PDF と同様、原稿を結合せず複数入力で渡す。
inputs=()
for f in $(ls -1 "${SRC_DIR}"/Chapter*.md | LC_ALL=C sort -V); do
  base="$(basename "${f}")"
  sed 's/^####.*/#& {-}/' "${f}" > "${EPUB_BUILD}/${base}"
  inputs+=("${EPUB_BUILD}/${base}")
done

if ((${#inputs[@]} == 0)); then
  echo "no chapter markdown files found in ${SRC_DIR}" >&2
  exit 1
fi

# Kindle Previewer doubles skylighting lines when display:inline-block (pandoc#8528).
prepare_kindle_highlighting_css() {
  local sample_md hl_tpl hl_default
  sample_md="${OUT_DIR}/.hl-sample.md"
  hl_tpl="${OUT_DIR}/.hl-extract.tpl"
  hl_default="${OUT_DIR}/.highlighting-default.css"
  printf '%s\n' '```bash' 'x' '```' > "${sample_md}"
  printf '%s\n' '$highlighting-css$' > "${hl_tpl}"
  pandoc "${sample_md}" --template="${hl_tpl}" -t html -o "${hl_default}"
  python3 - "${hl_default}" "${HL_CSS_KINDLE}" <<'PY'
import sys
from pathlib import Path

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
old = "pre > code.sourceCode > span { display: inline-block; line-height: 1.25; }"
new = "pre > code.sourceCode > span { display: inline; line-height: 1.25; }"
text = src.read_text(encoding="utf-8")
if old not in text:
    raise SystemExit(f"expected skylighting rule not found in {src}")
dst.write_text(text.replace(old, new), encoding="utf-8")
print(f"Prepared Kindle-safe highlighting CSS: {dst}")
PY
}

prepare_kindle_highlighting_css

epub_extra=()
if meta="$(git_build_metadata "${ROOT_DIR}" 2>/dev/null)"; then
  epub_extra=(-M "description=${meta}")
fi

(
  cd "${SRC_DIR}"
  pandoc "${inputs[@]}" \
    -t epub3 \
    -F pandoc-crossref \
    -o "${OUTPUT}" \
    -N \
    -M "crossrefYaml=${CROSSREF}" \
    "${epub_extra[@]}" \
    --metadata-file=config-epub.yaml \
    --epub-cover-image=image/Cover/電子版表紙_300dpi_2480x3508.png \
    --css=../epub.css \
    -V highlighting-css="$(cat "${HL_CSS_KINDLE}")"
)

echo "Output: ${OUTPUT}"
ls -lh "${OUTPUT}"
