# 『サーバー構築標準教科書』開発プロジェクト
このリポジトリは、LPI-Japanが配布している『サーバー構築標準教科書』を開発するプロジェクトのリポジトリです。

https://linuc.org/textbooks/server/

## ローカルビルド

原稿は `main/` / `ubuntu/` / `main-en/`。Docker / pandoc スクリプトは `build/`。

```bash
docker build -t ghcr.io/lpi-japan/server-text:local build
./build/build-pdf.sh cover main     # tmp/servertext_main_<ver>.pdf
./build/build-epub.sh ubuntu        # tmp/servertext_ubuntu_<ver>.epub
```

ホストに pandoc / lualatex が無い場合、スクリプトが上記イメージ内で再実行する。

CI（`root.yaml`）は push 1 回につき image を1回だけ建て、触った edition（`main` / `ubuntu` / `main-en`）の PDF/EPUB だけビルドする。手動は workflow_dispatch で全 edition。

ビルド時に Git の先頭コミット（12 文字、`git=<sha>`、未コミット変更時は `-dirty`）をメタデータに載せる。版面には出ない。

- PDF: `Keywords`（`pdfinfo ... | grep Keywords` / `exiftool -Keywords`）
- EPUB: `Description`（`exiftool -Description ...`）
