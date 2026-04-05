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
- `grb` を Bash 関数、Git alias、またはスクリプトとして運用できる

## 1. パッケージ更新

```bash
sudo apt update -y && sudo apt full-upgrade -y
```

## 2. Git インストール

```bash
sudo apt install -y git
```

## 3. Git グローバル設定

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your-email@example.com"
git config --global user.name "$GIT_USER_NAME" && git config --global user.email "$GIT_USER_EMAIL"
```

推奨設定までまとめて入れる場合:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your-email@example.com"
git config --global user.name "$GIT_USER_NAME" && git config --global user.email "$GIT_USER_EMAIL" && git config --global init.defaultBranch main && git config --global fetch.prune true && git config --global pull.ff only && git config --global rebase.autoStash true && git config --global core.editor "code --wait" && git config --global core.autocrlf input
```

入れておくとよい設定:

- `init.defaultBranch main`: 新規リポジトリの既定ブランチ名を `main` に統一する
- `fetch.prune true`: リモートで削除済みのブランチ参照を整理する
- `pull.ff only`: 意図しない merge commit を防ぐ
- `rebase.autoStash true`: 作業ツリーに変更がある状態でも rebase しやすくする
- `core.editor "code --wait"`: Git のコミットメッセージ編集を VS Code で開く
- `core.autocrlf input`: Linux 側では LF のまま扱い、コミット時だけ CRLF を正規化する

設定確認:

```bash
git config --global --list
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

## 8. Git カスタマイズ

### `grb` を Bash 関数として使う

対話シェルでは `.bashrc` または `.zshrc` に次を入れる。

```bash
grb() {
  git switch main && git pull origin main && git branch --merged main | grep -v "^[* ]*main$" | xargs -r git branch -d
}
```

この方法は対話シェルの初期化に依存するため、Codex CLI のように `.bashrc` を読まない実行環境ではそのまま使えないことがある。

### `grb` を Git alias として使う

`git` サブコマンドとして使えればよいなら、`~/.gitconfig` に shell 実行 alias を追加する。

```ini
[alias]
  rb = "!git switch main && git pull origin main && git branch --merged main | grep -v '^[* ]*main$' | xargs -r git branch -d"
```

この場合は `git rb` で実行する。

### 注意

- 既定ブランチが `main` ではないリポジトリでは、このままだと動かない
- `git branch --merged main` は `main` にマージ済みのローカルブランチだけを削除する
- 不安があれば `git branch --merged main` の出力を確認してから削除する
