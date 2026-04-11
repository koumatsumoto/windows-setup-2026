---
title: 04. Ubuntu 側の開発環境セットアップ
permalink: /docs/04-UBUNTU-SETUP/
---

# 04. Ubuntu 側の開発環境セットアップ

WSL 上の Ubuntu に、開発で使う CLI とランタイムを入れる手順。

## 前提

- [03. Windows 開発環境構築]({{ '/docs/03-WINDOWS-DEVELOPMENT-SETUP/' | relative_url }}) が完了している
- Ubuntu を起動し、Linux ユーザーが作成済みである

## このドキュメントの完了条件

- Ubuntu 側で Git と GitHub CLI が使える
- Node.js 開発に必要な基本パッケージが入っている
- `fnm` のシェル初期化が済んでいる
- npm のセキュリティ設定が済んでいる
- pip のセキュリティ設定が済んでいる

## 1. パッケージ更新

```bash
sudo apt update -y && sudo apt full-upgrade -y
```

## 2. Git インストール

```bash
sudo apt install -y git
```

## 3. Git グローバル設定

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
git config --global core.autocrlf input
git config --global core.excludesfile ~/.gitglobalignore
git config --global alias.rb '!git switch main && git pull --ff-only origin main && git branch --merged main | grep -v '"'"'^[* ]*main$'"'"' | xargs -r git branch -d'
```

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

## 4. GitHub CLI（gh）

公式手順: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

インストール後に認証する。

```bash
gh auth login
gh auth setup-git
```

## 5. Node.js 開発の基本パッケージ

`fnm` の導入とネイティブモジュールのビルドに必要なパッケージ:

```bash
sudo apt install -y curl unzip build-essential python3
```

| パッケージ      | 用途                                         |
| --------------- | -------------------------------------------- |
| curl            | `fnm` インストールスクリプトのダウンロード   |
| unzip           | `fnm` パッケージの展開                       |
| build-essential | ネイティブモジュール（node-gyp）のコンパイル |
| python3         | node-gyp 10+ で必須                          |

## 6. Node.js バージョン管理（fnm）

公式手順: https://github.com/Schniz/fnm

インストール後、Bash では `.bashrc` に以下を追加する。

```bash
eval "$(fnm env --use-on-cd --shell bash)"
```

## 7. npm セキュリティ設定

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

## 8. pip セキュリティ設定

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

## 9. Playwright ブラウザ依存パッケージ

Node.js インストール後に依存パッケージをインストールする。

```bash
npx playwright install-deps
```
