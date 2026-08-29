# windows-setup-2026

Windows 11 のクリーンインストール後に、必要最小限の Windows / WSL 開発環境を再構築するための個人用ガイドです。

対象は Git / GitHub、Node.js / TypeScript、Python / uv、Docker、Playwright、Codex、Claude Code と、日本語入力を含む Windows の個人設定です。インストール済みアプリをすべて再現することは目的にしません。

## セットアップを始める

[Windows Setup 2026](https://koumatsumoto.github.io/windows-setup-2026/) を開き、5段階の必須手順を上から進めます。GitHub 上で読む場合は [index.md](index.md) が入口です。

安全に自動化できる導入処理は `scripts/windows/` と `scripts/wsl/` にあります。アカウント作成、認証、OneDrive、IME などは手動確認を残しています。

## 対象外

- ディスク消去前のバックアップ、無人インストール、OOBE やユーザー削除の自動化
- 秘密値、認証情報、SSH 鍵、API キーの保存や移行
- Windows 側の開発ランタイムや、復旧条件に直接必要ないアプリ・CLI
- OneDrive アプリのアンインストール

サイトのローカル確認と執筆ルールは [AUTHORING.md](AUTHORING.md) を参照してください。
