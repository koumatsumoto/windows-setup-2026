---
title: 03. Windows 開発環境構築
permalink: /docs/03-WINDOWS-DEVELOPMENT-SETUP/
---

# 03. Windows 開発環境構築

Windows 側で使うアプリを入れ、WSL と Ubuntu を開発用に使える状態にする手順。

基本的な開発は Ubuntu 側で進める前提だが、Flutter など一部のアプリは Windows 側で開発する場合があるため、Windows 側の Git もここでセットアップする。

## 前提

- [02. Windows 設定]({{ '/docs/02-WINDOWS-SETUP/' | relative_url }}) が完了している

## このドキュメントの完了条件

- Git、VS Code、Docker Desktop など Windows 側アプリが入っている
- Windows 側の Git 設定が完了している
- npm のセキュリティ設定が完了している
- pip のセキュリティ設定が完了している
- WSL と Ubuntu がインストール済みである
- Ubuntu を初回起動し、Linux ユーザー作成まで終わっている
- VS Code と WSL の連携が完了している

## 1. winget でアプリインストール

PowerShell で実行する。

```powershell
winget install -e --id Git.Git
winget install -e --id Google.Chrome
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Docker.DockerDesktop
winget install -e --id Oracle.MySQLWorkbench
winget install -e --id Logitech.GHUB
winget install -e --id Discord.Discord
winget install -e --id 7zip.7zip
```

### すべてのアプリを更新

```powershell
winget upgrade --all
```

## 2. Git 設定

Git Bash で実行する。

```sh
vim --version
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your-email@example.com"
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global pull.ff only
git config --global rebase.autoStash true
git config --global core.editor vim
git config --global core.autocrlf true
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

## 3. npm セキュリティ設定

Git Bash で実行する。

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

## 4. pip セキュリティ設定

Windows の pip は `%APPDATA%\pip\pip.ini` を参照する。Git Bash では `$APPDATA` でアクセスできる。

```sh
mkdir -p "$APPDATA/pip"
cat > "$APPDATA/pip/pip.ini" <<'EOF'
[global]
require-virtualenv = true
EOF
```

| 設定 | 効果 |
| --- | --- |
| `require-virtualenv = true` | 仮想環境の外での `pip install` を禁止し、システム Python の汚染を防ぐ |

- システム全体にパッケージを入れたい場合は `PIP_REQUIRE_VIRTUALENV=false pip install ...` で一時的に回避できる

## 5. WSL インストール

PowerShell を管理者で開いて実行する。

```powershell
wsl --install
```

Ubuntu を明示する場合:

```powershell
wsl --install -d Ubuntu
```

インストール後、PC を再起動する。

### 補足

- `wsl --install` は Ubuntu を既定のディストリビューションとして入れる
- すでに WSL が入っていてヘルプが出る場合は `wsl --list --online` で利用可能なディストリビューションを確認する

## 6. Ubuntu の初回起動

1. スタートメニューから `Ubuntu` を起動する
2. 展開完了を待つ
3. Linux 側のユーザー名とパスワードを設定する

ここまで終わると、Ubuntu 側のセットアップを始められる。

## 7. VS Code と WSL の連携

1. Windows 側で VS Code を起動する
2. WSL 内でプロジェクトディレクトリに移動する
3. 以下を実行する

```bash
code .
```

初回実行時に VS Code Server と WSL 拡張機能（Remote - WSL）が自動でインストールされる。

## 次に読む

Ubuntu 側の CLI とランタイムのセットアップは [04. Ubuntu 側の開発環境セットアップ]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) に進む。
