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
- [05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) の Ubuntu 向け手順が完了している

## 1. パッケージ更新

```bash
sudo apt update -y && sudo apt full-upgrade -y
```

## 2. Git インストール

```bash
sudo apt install -y git
```

## 3. GitHub CLI（gh）

公式手順: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

インストール後に認証する。

```bash
gh auth login
gh auth setup-git
```

## 4. Node.js 開発の基本パッケージ

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

## 5. Node.js バージョン管理（fnm）

公式手順: https://github.com/Schniz/fnm

インストール後、Bash では `.bashrc` に以下を追加する。

```bash
eval "$(fnm env --use-on-cd --shell bash)"
```

## 6. 開発ツール共通設定

vim が入っていない場合は先にインストールする。

```bash
sudo apt install -y vim
```

[05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) の Ubuntu 向け手順を実行し、完了後このドキュメントに戻る。

## 7. Playwright ブラウザ依存パッケージ

Node.js インストール後に依存パッケージをインストールする。

```bash
npx playwright install-deps
```
