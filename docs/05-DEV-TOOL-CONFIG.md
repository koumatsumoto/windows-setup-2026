---
title: 05. 開発ツール共通設定
permalink: /docs/05-DEV-TOOL-CONFIG/
nav_order: 50
nav_label: 05. 開発ツール共通設定
---

# 05. 開発ツール共通設定

Windows (Git Bash) と Ubuntu で使う Git・npm・pip 設定手順。大部分は共通だが、OS 固有の差異は本文中で明示する。

## 前提

- Git が利用可能である
- Windows の場合は Git Bash を使う

## このドキュメントの完了条件

- Git のグローバル設定が完了している
- `.gitglobalignore` が作成されている
- npm のセキュリティ設定（`~/.npmrc`）が作成されている
- Windows の場合は `script-shell` が `.npmrc` に設定されている
- pip のセキュリティ設定が作成されている

## 1. Git グローバル設定

```sh
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your-email@example.com"
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global pull.ff only
git config --global rebase.autoStash true
git config --global core.editor vim
git config --global core.excludesfile ~/.gitglobalignore
git config --global alias.rb '!git switch main && git pull --ff-only origin main && git branch --merged main | grep -v '"'"'^[* ]*main$'"'"' | xargs -r git branch -d'
```

`core.autocrlf` は OS ごとに異なる値を設定する。

| OS | コマンド | 理由 |
| --- | --- | --- |
| Windows | `git config --global core.autocrlf true` | チェックアウト時に LF→CRLF、コミット時に CRLF→LF |
| Ubuntu | `git config --global core.autocrlf input` | コミット時のみ CRLF→LF に正規化 |

## 2. .gitglobalignore

```sh
cat > ~/.gitglobalignore <<'EOF'
.DS_Store
Thumbs.db
Desktop.ini
*.swp
*.swo
*~
Session.vim
.netrwhist
.env
.env.*
*.local
.venv/
venv/
__pycache__/
*.py[cod]
.pytest_cache/
.mypy_cache/
.ruff_cache/
.python-version
node_modules/
.npm/
.pnpm-store/
.yarn/cache/
.yarn/install-state.gz
.parcel-cache/
.next/
.nuxt/
.svelte-kit/
dist/
EOF
```

## 3. npm セキュリティ設定

```sh
cat > ~/.npmrc <<'EOF'
engine-strict=true
ignore-scripts=true
audit=true
audit-level=high
min-release-age=7
save-exact=true
strict-peer-deps=true
fund=false
allow-git=root
EOF
```

| 設定 | 効果 |
| --- | --- |
| `engine-strict=true` | `engines` フィールドに合わないパッケージのインストールを拒否する |
| `ignore-scripts=true` | postinstall 等のライフサイクルスクリプトを無効化し、サプライチェーン攻撃を防ぐ |
| `audit=true` | `npm install` 時に既知の脆弱性を自動チェックする（デフォルト有効、明示） |
| `audit-level=high` | high 以上の脆弱性で非ゼロ終了し、低リスクの警告でワークフローを止めない |
| `min-release-age=7` | 公開から 7 日未満のバージョンを除外し、ゼロデイ汚染パッケージを回避する（npm v11.10+） |
| `save-exact=true` | `^` や `~` なしの固定バージョンで保存し、意図しないバージョン変動を防ぐ |
| `strict-peer-deps=true` | peer dependency の競合をエラーにし、曖昧な解決を許さない |
| `fund=false` | funding メッセージを抑制し、出力のノイズを減らす |
| `allow-git=root` | Git 依存を root の package.json のみ許可し、推移的な Git 依存による任意コード実行を防ぐ（npm v11.10+） |

- `ignore-scripts=true` の環境で一部パッケージ（sharp, bcrypt, esbuild 等）を使う場合は `npm install --ignore-scripts=false` で個別対応する
- `min-release-age` は npm v11.10+、`allow-git` は npm v11.9+ で利用可能

### Windows 固有: script-shell の設定

Windows では npm のライフサイクルスクリプトがデフォルトで `cmd.exe` で実行される。Git Bash に統一するために `.npmrc` に追記する。

```sh
echo 'script-shell="C:\\Program Files\\Git\\bin\\bash.exe"' >> ~/.npmrc
```

| 設定 | 効果 |
| --- | --- |
| `script-shell` | npm スクリプトの実行シェルを Git Bash に変更し、シェル構文の互換性を確保する |

Ubuntu では不要。デフォルトで `/bin/sh` が使われる。

## 4. pip セキュリティ設定

設定ファイルのパスは OS ごとに異なる。

| OS | パス |
| --- | --- |
| Windows | `%APPDATA%\pip\pip.ini`（Git Bash では `$APPDATA/pip/pip.ini`） |
| Ubuntu | `~/.config/pip/pip.conf` |

Windows:

```sh
mkdir -p "$APPDATA/pip"
cat > "$APPDATA/pip/pip.ini" <<'EOF'
[global]
require-virtualenv = true
EOF
```

Ubuntu:

```sh
mkdir -p ~/.config/pip
cat > ~/.config/pip/pip.conf <<'EOF'
[global]
require-virtualenv = true
EOF
```

| 設定 | 効果 |
| --- | --- |
| `require-virtualenv = true` | 仮想環境の外での `pip install` を禁止し、システム Python の汚染を防ぐ |

- システム全体にパッケージを入れたい場合は `PIP_REQUIRE_VIRTUALENV=false pip install ...` で一時的に回避できる
