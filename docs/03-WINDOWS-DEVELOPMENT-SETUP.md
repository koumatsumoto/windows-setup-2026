---
title: 03. Windows アプリ・WSL・Docker
permalink: /docs/03-WINDOWS-DEVELOPMENT-SETUP/
nav_order: 30
nav_label: 03. Windows アプリ・WSL・Docker
nav_section: setup
---

# 03. Windows アプリ・WSL・Docker

Windows 側には GUI と仮想化の境界だけを置き、開発 CLI とランタイムは WSL に集約します。

## 完了条件

- VS Code、Docker Desktop、Chrome、PowerToys、7-Zip が導入されている。
- WSL 2 と `Ubuntu-26.04` が導入され、既定ディストリビューションになっている。
- Docker Desktop の WSL 2 engine と `Ubuntu-26.04` integration が有効である。
- Ubuntu 内から `docker`、`docker compose`、`code .` が使える。

## 1. このリポジトリを取得する

Windows PowerShell で次を実行します。Git を Windows へ入れずに、公開リポジトリの ZIP を展開します。

```powershell
$zip = Join-Path $env:TEMP 'windows-setup.zip'
$destination = Join-Path $env:USERPROFILE 'Downloads\windows-setup'
Invoke-WebRequest 'https://github.com/koumatsumoto/windows-setup/archive/refs/heads/main.zip' -OutFile $zip
Expand-Archive $zip -DestinationPath $destination -Force
Set-Location "$destination\windows-setup-main"
```

## 2. 必須アプリと WSL を導入する

PowerShell を管理者として開き、最初に dry-run を確認します。

```powershell
Set-ExecutionPolicy -Scope Process RemoteSigned
& .\scripts\windows\Install-Setup.ps1 -WhatIf
& .\scripts\windows\Install-Setup.ps1
```

パッケージ ID と Ubuntu 名の正本は `scripts/windows/SetupConfig.psd1` です。スクリプトは導入済みアプリをスキップし、アプリ削除、アカウント操作、OneDrive 設定を行いません。WSL の導入で再起動を求められたら、再起動後に同じスクリプトをもう一度実行します。

`Ubuntu-26.04` の初回起動時に Linux ユーザー名とパスワードを作ります。ユーザー名は `kou` で構いません。

Microsoft の現行 WSL 手順では `wsl --list --online` で配布名を確認し、`wsl --install -d <Distro>` で明示導入できます。このガイドは可変の `Ubuntu` ではなく `Ubuntu-26.04` を固定します。

## 3. Docker Desktop を WSL と接続する

1. Docker Desktop を起動する。
2. Settings → General で「Use the WSL 2 based engine」が表示される場合は有効にする。
3. Settings → Resources → WSL Integration で `Ubuntu-26.04` を有効にする。
4. Apply を選ぶ。

Ubuntu 側へ Docker Engine や `docker.io` を別途インストールしません。Docker 公式も、WSL 内へ直接入れた Engine / CLI との併用は競合しうると説明しています。

Ubuntu で確認します。

```bash
docker version
docker compose version
```

## 4. VS Code を WSL から起動する

Ubuntu のホーム以下に作業ディレクトリを置き、次を実行します。

```bash
mkdir -p ~/work
cd ~/work
code .
```

初回は VS Code が WSL 用サーバーを導入します。画面左下に `WSL: Ubuntu-26.04` が表示されることを確認します。

## 5. Windows 側を検証する

管理者でない通常の PowerShell から read-only 検証を実行します。

```powershell
& .\scripts\windows\Verify-Setup.ps1
```

IME と OneDrive の一部は公開 API だけでは断定できないため、スクリプトが示す「手動確認」も完了させます。

## 次に読む

[04. WSL 開発環境]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) に進みます。[Windows Terminal]({{ '/docs/07-WINDOWS-TERMINAL/' | relative_url }}) の見た目は任意です。
