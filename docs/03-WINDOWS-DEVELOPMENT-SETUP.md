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

PowerShell で実行する。

```powershell
git config --global user.name "Name"
git config --global user.email "Email"
```

## 3. WSL インストール

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

## 4. Ubuntu の初回起動

1. スタートメニューから `Ubuntu` を起動する
2. 展開完了を待つ
3. Linux 側のユーザー名とパスワードを設定する

ここまで終わると、Ubuntu 側のセットアップを始められる。

## 5. VS Code と WSL の連携

1. Windows 側で VS Code を起動する
2. WSL 内でプロジェクトディレクトリに移動する
3. 以下を実行する

```bash
code .
```

初回実行時に VS Code Server と WSL 拡張機能（Remote - WSL）が自動でインストールされる。

## 次に読む

Ubuntu 側の CLI とランタイムのセットアップは [04. Ubuntu 側の開発環境セットアップ]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) に進む。
