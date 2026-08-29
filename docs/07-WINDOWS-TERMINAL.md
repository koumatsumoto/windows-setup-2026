---
title: Windows Terminal の最小設定
permalink: /docs/07-WINDOWS-TERMINAL/
nav_order: 130
nav_label: Windows Terminal の最小設定
nav_section: reference
---

# Windows Terminal の最小設定

Windows Terminal が生成・更新する `settings.json` 全体は置換しません。必要な設定だけを画面から変更します。

## 推奨する設定

1. Windows Terminal を開き、`Ctrl + ,` で設定を開く。
2. スタートアップ → 既定のプロファイルで `Ubuntu-26.04` を選ぶ。
3. 操作 → 複数行の貼り付け警告と大量テキストの貼り付け警告を有効にする。
4. コピーの書式はプレーンテキストにする。

AI が生成した複数行コマンドを意図せず一括実行しないことが目的です。追加プロファイル、フォント、配色、キーバインドは必須設定にしません。

## 確認

Windows Terminal を開き直し、新しいタブが `Ubuntu-26.04` になることを確認します。複数行テキストを貼り付け、実行前に警告が出ることも確認します。

[03. Windows アプリ・WSL・Docker]({{ '/docs/03-WINDOWS-DEVELOPMENT-SETUP/' | relative_url }}) に戻ります。
