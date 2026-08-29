---
title: Git の最小設定
permalink: /docs/05-DEV-TOOL-CONFIG/
nav_order: 110
nav_label: Git の最小設定
nav_section: reference
---

# Git の最小設定

WSL 上の Git に本人情報だけを設定します。エディター、改行、ignore、認証方法、署名などはプロジェクトや必要性が決まってから追加します。

```bash
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR EMAIL"
git config --global init.defaultBranch main
```

GitHub の commit メールを公開したくない場合は、GitHub の Settings → Emails に表示される noreply アドレスを使います。

```bash
git config --global --list --show-origin
```

期待しない既存設定がある場合は、上の出力で設定元を確認して個別に判断します。このガイドは `.gitconfig` 全体を置換しません。

[04. WSL 開発環境]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) に戻ります。
