#!/usr/bin/env bash
# Builds assets/fonts/PipEmoji.ttf: Noto Color Emoji (SIL OFL 1.1) cut down to
# the emoji the app uses (tool/emoji_used.txt from vocab_table.py + tool/emoji_extra.txt).
# Placeholder art only. TODO(asset): replace with illustrations.
# Needs: pip install fonttools; a NotoColorEmoji.ttf (default: Debian/Ubuntu fonts-noto-color-emoji).
set -euo pipefail
cd "$(dirname "$0")/.."
src="${NOTO_EMOJI:-/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf}"
cat tool/emoji_used.txt tool/emoji_extra.txt > /tmp/pip_emoji.txt
pyftsubset "$src" --text-file=/tmp/pip_emoji.txt --unicodes=U+FE0F,U+200D \
  --output-file=assets/fonts/PipEmoji.ttf --no-hinting --layout-features='*'
ls -l assets/fonts/PipEmoji.ttf
