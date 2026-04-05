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

## 7. Playwright ブラウザ依存パッケージ

Node.js インストール後に依存パッケージをインストールする。

```bash
npx playwright install-deps
```
