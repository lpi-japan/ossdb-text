# OSS-DB標準教科書

## ローカルビルド

日本語原稿はリポジトリ直下、英語は `en/`。Docker / pandoc スクリプトは `build/`。

```bash
docker build -t ghcr.io/lpi-japan/ossdb-text:local build
./build/build-pdf.sh         # tmp/ossdbtext_<ver>.pdf と _no_cover.pdf
./build/build-epub.sh        # tmp/ossdbtext_<ver>.epub
./build/build-pdf.sh en      # tmp/ossdbtext_en_<ver>.pdf
./build/build-epub.sh en     # tmp/ossdbtext_en_<ver>.epub
```

ホストに pandoc / lualatex が無い場合、スクリプトが上記イメージ内で再実行する。

ビルド時に Git の先頭コミット（12 文字、`git=<sha>`、未コミット変更時は `-dirty`）をメタデータに載せる。版面には出ない。

- PDF: `Keywords`（`pdfinfo ... | grep Keywords` / `exiftool -Keywords`）
- EPUB: `Description`（`exiftool -Description ...`）
