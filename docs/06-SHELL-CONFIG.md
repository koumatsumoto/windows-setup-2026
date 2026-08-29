---
title: 管理対象のシェル初期化
permalink: /docs/06-SHELL-CONFIG/
nav_order: 120
nav_label: 管理対象のシェル初期化
nav_section: reference
---

# 管理対象のシェル初期化

`scripts/wsl/install.sh` は既存の `~/.bashrc` を維持し、次の1行だけを追加します。

```bash
[ -f "$HOME/.config/windows-setup/env.sh" ] && . "$HOME/.config/windows-setup/env.sh"
```

管理対象フラグメントは次だけを担当します。

- `~/.local/bin`、fnm、Codex の実行パス
- `fnm env --use-on-cd --shell bash` による Node.js の切り替え

エイリアス、プロンプト、Git 操作、apt 更新、Windows アプリ起動などの個人用関数は復旧条件に含めません。必要になった時点で自分の dotfiles として別管理します。

## 確認

```bash
grep -F '.config/windows-setup/env.sh' ~/.bashrc
sed -n '1,80p' ~/.config/windows-setup/env.sh
type fnm node uv codex claude playwright-cli
```

source 行が1件だけであることを確認します。再実行時にも重複しません。

[04. WSL 開発環境]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) に戻ります。
